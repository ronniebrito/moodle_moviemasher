<?php
/*
* The contents of this file are subject to the Mozilla Public
* License Version 1.1 (the "License"); you may not use this
* file except in compliance with the License. You may obtain a
* copy of the License at http://www.mozilla.org/MPL/
* 
* Software distributed under the License is distributed on an
* "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express
* or implied. See the License for the specific language
* governing rights and limitations under the License.
* 
* The Original Code is 'Movie Masher'. The Initial Developer
* of the Original Code is Doug Anarino. Portions created by
* Doug Anarino are Copyright (C) 2007-2011 Syntropo.com, Inc.
* All Rights Reserved.
*/
include_once(dirname(dirname(__FILE__)) . '/Coder.php');


class MovieMasher_Coder_Decoder extends MovieMasher_Coder
{
	var $__menuHeight = 52; // extra pixels for flashplayer's menubar
	var $__mashXML = null; // will contain reformatted mash object
	var $__mashData = array(); // will contain keys with various parsing info
	static $defaultOptions = array(
		
		'DecoderAppletURL' => array(
			'value' => 'URL',
			'description' => "The copy of the Movie Masher applet on your server",	
		),
		'DecoderAudioBitrate' => array(
			'value' => 'NUMBER',
			'description' => "Audio bitrate in k/s. (-ab switch, without 'k') to use in resultant file",	
			'default' => '224',
		),
		'DecoderAudioCodec' => array(
			'value' => 'CODE',
			'description' => "Audio codec (-acodec switch) to use in resultant file",	
			'default' => 'mp2',
		),
		'DecoderAudioFrequency' => array(
			'value' => 'NUMBER',
			'description' => "Audio frequency rate in Hz (-ar switch) to use in resultant file",	
			'default' => '44100',
		),
		'DecoderCacheAllVideoFrames' => array(
			'value' => 'BOOLEAN',
			'description' => "If true, all frames of video used in modules will be created for use in applet",	
			'default' => '0',
			'emptyok' => 1,
		),
		'DecoderConfigURL' => array(
			'value' => 'URL',
			'description' => "Initial XML configuration file",	
		),
		'DecoderDimensions' => array(
			'value' => 'WxH',
			'description' => "Dimensions of output media",
			'default' => '320x240',
		),
		'DecoderExactRender' => array(
			'value' => 'BOOLEAN',
			'description' => "If true, all rendering is done in Flash (slowly, but precisely)",	
			'default' => '0',
			'emptyok' => 1,
		),
		'DecoderExtension' => array(
			'value' => 'EXTENSION',
			'description' => "File extension used for output media",	
			'default' => 'avi',
		),
		'DecoderFPS' => array(
			'value' => 'NUMBER',
			'description' => "Frames Per Second",	
			'default' => '24',
		),
		'DecoderPolicyURL' => array(
			'value' => 'URL',
			'description' => "The copy of moviemasher/crossdomain.xml on your server",	
		),
		'DecoderSwitches' => array(
			'value' => 'STRING',
			'description' => "FFMPEG command line switches",	
			'emptyok' => 1,
			'default' => '',
		),
		'DecoderSwitchesInter' => array(
			'value' => 'STRING',
			'description' => "FFMPEG command line switches",	
			'emptyok' => 1,
			'default' => '',
		),
		'DecoderTimecodeColor' => array(
			'value' => 'STRING',
			'description' => "Six character hex value for debugging timecode string",	
			'default' => '',
			'emptyok' => 1,
		), 
		'DecoderVideoBitrate' => array(
			'value' => 'NUMBER',
			'description' => "Video bitrate in k/s (-b switch, without 'k') in resultant file",	
			'default' => '4000',
		),
		'DecoderVideoBitrateInter' => array(
			'value' => 'NUMBER',
			'description' => "Video bitrate in k/s (-b switch, without 'k') in intermediate files",	
			'default' => '0',
		),
		'DecoderVideoCodec' => array(
			'value' => 'CODE',
			'description' => "Video codec (-vcodec switch) to use in resultant file",	
			'default' => 'mpeg4',
		),
		'DecoderVideoCodecInter' => array(
			'value' => 'CODE',
			'description' => "Video codec (-vcodec switch) to use in intermediate file",	
			'default' => 'mpeg2video',
		),
		'DecoderVideoExtensionInter' => array(
			'value' => 'EXTENSION',
			'description' => "File extension used for intermediate video files",	
			'default' => 'mpg',
		),
		'DecoderVideoFormatInter' => array(
			'value' => 'STRING',
			'description' => "Video format (-f switch) for concatenatable intermediate build files",	
			'default' => 'mpeg',
		),
	);
	function MovieMasher_Coder_Decoder($config = array())
	{
		parent::MovieMasher_Coder($config);
		$this->_coderName = 'Decode';
	}
	static function defaultOption($name)
	{
		$val = '';
		if (! empty(MovieMasher_Coder_Decoder::$defaultOptions[$name]))
		{
			$val = MovieMasher_Coder_Decoder::$defaultOptions[$name]['default'];
		}
		return $val;
	}
	static function mashInfo($xml, $path = 'http://www.example.com/', $fps = 0, $exact = FALSE)
	{	
		if (! $fps) $fps = MovieMasher_Coder_Decoder::defaultOption('DecoderFPS');
		
		$render_clips = array();
		
		$result = array();
		$result['has_audio'] = FALSE;
		$result['has_video'] = FALSE;
		$result['clips'] = array(); // indexed array() of arrays with keys needed for quick sorting and time based retrieval (start, stop)
		$result['render_all'] = $exact; // switch for full flash rendering
		$result['cache_urls'] = array(); // files needing to be cached
		$result['timespans'] = array(); // array(startseconds, stopseconds, startframe, framecount, framecounter)
		$result['media'] = array(); // holds references to all media tags (they may get altered)
		
		$mash_tags = $xml->xpath('//mash');
		if (! sizeof($mash_tags)) throw new UnexpectedValueException('No mash tag found');
		$mash_tag = $mash_tags[0];
		$quantize = floatval($mash_tag['quantize']);
		if (! $quantize) $quantize = floatval(1);
		$result['quantize'] = $quantize;
		// grab all media tags, even nested ones
		$media_tags = $xml->xpath('//media');
		
		$media_count = sizeof($media_tags);
		for ($i = 0; $i < $media_count; $i++)
		{
			$media = $media_tags[$i];
			$result['media'][(string) $media['id']] = $media;
		}
		
		// grab all clip tags within mash, even nested ones
		$clip_tags = $xml->mash->xpath('//clip');
		$clip_count = sizeof($clip_tags);
		$result['duration'] = floatval(0);
		
		for ($i = 0; $i < $clip_count; $i++)
		{
			
			$clip_tag = $clip_tags[$i];
			$id = (string) $clip_tag['id'];
			if (! isset($result['media'][$id])) throw new UnexpectedValueException('No media found for clip ID ' . $id);
			
			$media = $result['media'][$id];
			
			$clip = array();
			$clip['type'] = (string) $media['type'];
			$clip['id'] = (string) $media['id'];
			$clip['track'] = (int) $clip_tag['track'];
			
			// clips with negative tracks will have zero for start - we want to topmost clip's start 
			if ($clip['track'] < 0) $clip['start'] = MovieMasher_Coder_Decoder::nestedStart($clip_tag);
			else $clip['start'] = floatval($clip_tag['start']);
			$clip['start'] = $clip['start'] / $quantize;
			
			$clip['length'] = floatval($clip_tag['length']) / $quantize;
			$clip['stop'] = $clip['start'] + $clip['length'];
			
			// duration of underlying audio/video clip, or zero
			$clip['duration'] = floatval($media['duration']);
			
			// speed defaults to one
			$clip['speed'] = floatval($clip_tag['speed']);
			if (! $clip['speed']) $clip['speed'] = floatval(1);
			
			// loops defaults to one
			$clip['loops'] = floatval($clip_tag['loops']);
			if (! $clip['loops']) $clip['loops'] = floatval(1);

			// will be 0.0 for all but trimmed audio/video
			$clip['trimstart'] = floatval($clip_tag['trimstart']) / $quantize;

			// URLs defaults to empty
			$clip['source'] = '';
			$clip['audio'] = '';
			
			switch ($clip['type'])
			{
				case 'image':
				{
					// so any reference in flash points to hi res source file
					$url = (string) $media['source'];
					$url = MovieMasher_Coder::cleanURL($url);
					if ($url) $media['url'] = $url;
					$clip['source'] = (string) $media['url'];
				} // intentional fallthrough to video 
				case 'video':
				{
					$clip['fill'] = (string) $clip_tag['fill'];
					if (! $clip['fill']) $clip['fill'] = (string) $media['fill'];
					if (! $clip['fill']) $clip['fill'] =  'stretch';
					break;
				}
			}
			
			$clip['audio'] = '';
			
			switch ($clip['type'])
			{
				case 'audio': 
				{
					$audio = (string) $media['source'];
					$audio = MovieMasher_Coder::cleanURL($audio);
					if (empty($audio)) $audio = (string) $media['audio'];
					if (! empty($audio))
					{
						
						// media has an audio url
						$volume = (string) $clip_tag['volume'];
						
						if (empty($volume) || ($volume != '0,0,100,0'))
						{
							// clip has volume and is not muted
							$url = absolute_url(end_with_slash($path), $audio);
							$url = MovieMasher_Coder::cleanURL($url);
					
							$result['cache_urls'][$url] = TRUE;
							$result['has_audio'] = TRUE;
		
							$clip['audio'] = $url;
							$clip['volume'] = $volume; 
						}
					
					}
					break;
				}
				case 'effect':
				{
					$result['has_video'] = TRUE;
					if ($clip['track'] < 0)
					{
						// effect clip is attached to another clip or the mash itself
						$parent_tag = MovieMasher_Coder_Decoder::parentTag($clip_tag);
						if ($parent_tag == NULL) throw new UnexpectedValueException('Could not determine parent of effect');
						if ($parent_tag->getName() == 'mash') $result['render_all'] = 1;
					}
					$render_clips[] = $clip;
					break;
				}
				case 'theme':
					if ($clip['track'] < 0) break;
					// otherwise we're not composited, so fallthrough to transition
				case 'transition':
				{
					$render_clips[] = $clip;
					// fallthrough to other visuals (image and video)
				}
				default:
				{
					$url = (string) $media['source'];
					
					if (! $url) $url = 	(string) $media['url'];
					$url = MovieMasher_Coder::cleanURL($url);
					if ($url) 
					{
						if (file_extension($url) == 'youtube') throw new UnexpectedValueException('YouTube video decoding unsupported: ' . substr($url, 0, -8));
						$url = absolute_url(end_with_slash($path), $url);
						$clip['source'] = $url;
					}
					
					$result['has_video'] = TRUE;
					
					$shifted = ! floatcmp($clip['speed'], floatval(1));
					
					// check for audio=0 in clip tag (composited video with no audio)
					$audio = (string) $clip_tag['audio'];
					if ($audio !== '0')
					{
						$audio = (string) $media['audio']; 
						if ((! $shifted) && (! empty($audio)))
						{
							// media has an audio url
							$volume = (string) $clip_tag['volume'];
							
							// make sure this isn't a composited visual
							if ((empty($volume) || ($volume != '0,0,100,0')))
							{
								// clip has volume and is not muted
								if (! $url)
								{
									// '1' means to use the audio in the video file
									if ($audio == '1') $url = (string) $media['url'];
									else $url = $audio;
								}
								if ($url)
								{
									$url = absolute_url(end_with_slash($path), $url);
									$url = MovieMasher_Coder::cleanURL($url);
					
									$result['cache_urls'][$url] = TRUE;
									$result['has_audio'] = TRUE;
			
									$clip['audio'] = $url;
									$clip['volume'] = $volume;
								}
							}
						}
					}
					// at the moment, timeshifted video clips are handled in flash
						
					if ($shifted && ($clip['type'] == 'video'))
					{
						$render_clips[] = $clip;
					}
				}
			}
			
			$result['duration'] = floatmax($clip['stop'], $result['duration']);
			$result['clips'][] = $clip;
		}
		
		usort($result['clips'], array('MovieMasher_Coder_Decoder', '__sortByStartTime'));

		if (! empty($result['render_all']))
		{

			$result['timespans'][] = array(floatval(0), $result['duration']);
		}
		else
		{
			// determine timespans of all clips requiring flash rendering
			$z = sizeof($render_clips);
			for ($i = 0; $i < $z; $i++)
			{
				
				$clip = $render_clips[$i];
				
				$start = $clip['start'];
				$stop = $clip['stop'];
				$y = sizeof($result['timespans']);
				for ($j = $y - 1; $j > -1; $j--)
				{
					$spanstart = $result['timespans'][$j][0];
					$spanstop = $result['timespans'][$j][1];
					if ( ! (floatgtr($start, $spanstop) || floatgtr($spanstart, $stop)))
					{
						// they touch or overlap, so remove and expand
						$start = floatmin($start, $spanstart);
						$stop = floatmax($stop, $spanstop);
						array_splice($result['timespans'], $j, 1);
					}
				}
				$result['timespans'][] = array($start, $stop);
			}
			usort($result['timespans'], 'floatsort');
			if (sizeof($result['timespans']) == 1)
			{
				if (($result['timespans'][0][0] == floatval(0)) && ($result['timespans'][0][1] == $result['duration']))
				{
					$result['render_all'] = 1;
				}
			}
		}
			
		$z = sizeof($result['timespans']);
		
		$result['timespan_frame_count'] = 0;
		$result['timespan_frame_index'] = 0;
		
		$result['timespan_index'] = 0;
		
		
		if ($z)
		{
			$done = array();
			// initialize timespans and alter media tags
			$float_fps = floatval($fps);
			for ($i = 0; $i < $z; $i++)
			{
				$span = &$result['timespans'][$i];
				
				// save frame for times, as convenience
				$span[2] = intval(floor($span[0] * $float_fps));
				$span[3] = intval(floor($span[1] * $float_fps));
				
				// create a frame counter for span
				$span[4] = $span[2];
				
				// add to global frame count
				$result['timespan_frame_count'] += $span[3] - $span[2];	
				
				// update media tag of video clips within this range with higher resolution media
				$clips = MovieMasher_Coder_Decoder::videoBetween($result['clips'], $span[0], $span[0] + $span[1]);
				$y = sizeof($clips);
				for ($j = 0; $j < $y; $j++)
				{
					$clip = &$clips[$j];
					if ($clip['type'] == 'video')
					{
						$media_tag = $result['media'][$clip['id']];
						
						$url = (string) $media_tag['source'];
						if (! $url) $url = (string) $media_tag['url'];
						$url = MovieMasher_Coder::cleanURL($url);
						$ext = file_extension($url);
						if ($ext)
						{
							
							$url = absolute_url(end_with_slash($path), $url);
							if (empty($done[$clip['id']]))
							{
								$done[$clip['id']] = TRUE;
								$media_tag['zeropadding'] = strlen(floor($float_fps * $clip['duration']));
								$media_tag['pattern'] = '%.jpg';
								$media_tag['fps'] = $fps;		
								$media_tag['source'] = $url;
								$result['cache_urls'][$url] = TRUE;
							}
							$clip['encode'] = TRUE;
						}
					}			
				}
			}
		}
		return $result;
	}
	static function nestedStart($tag)
	{
		$result = FALSE;
		$parent = $tag;
		while (($parent != NULL) && (((int) $parent['track']) < 0))
		{
			$parent = MovieMasher_Coder_Decoder::parentTag($parent);
		}
		if ($parent != NULL)
		{
			$result = floatval((string) $parent['start']);
		}
		return $result;
	}
	static function parentTag($tag)
	{
		$dom = dom_import_simplexml($tag);
		$tag = NULL;
		$dom = $dom->parentNode;
		if ($dom != NULL)
		{
			$tag = simplexml_import_dom($dom);
			//print 'parentTag: ' . htmlspecialchars($tag->asXML()) . '<br />';
		}
		return $tag;
	}
	static function videoBetween(&$clips, $start, $stop)
	{
		$video_clips = array();
		$z = sizeof($clips);
		for ($i = 0; $i < $z; $i++)
		{
			$clip = &$clips[$i];
			switch ($clip['type'])
			{
				case 'theme':
				{
					if ($clip['track'] < 0) break;
					// fallthrough to others if theme is on main track
				}
				case 'video':
				case 'image':
				case 'transition':
				{
					if (! floatgtre($clip['start'], $stop))
					{
						if (floatgtr($clip['stop'], $start))
						{
							$video_clips[] = &$clip;
							$clip['between'] = TRUE;
							$clip = $video_clips[sizeof($video_clips) - 1];
						}
					}
				}
					
			}
		}
		return $video_clips;
	}
	function _codeFile()
	{
		$this->__cleanUpJob();
		
		$file_time = microtime(true);
		
		
		$audio_path = '';
		$video_path = '';
		
		// load configuration URL and make sure it's not empty and can be parsed as XML
		$xml_string = http_get_url($this->_options['DecoderConfigURL']);
		if (! $xml_string) throw new RuntimeException('No response from DecoderConfigURL: ' . $this->_options['DecoderConfigURL']); 
		$this->__mashXML = @simplexml_load_string($xml_string);
		if (! $this->__mashXML) throw new RuntimeException('Unable to parse DecoderConfigURL: ' . $this->_options['DecoderConfigURL']);
		
		// TODO: we should be respecting 'config' attributes in the tags!
		
		$this->__mashData = MovieMasher_Coder_Decoder::mashInfo($this->__mashXML, $this->_options['CoderBaseURL'], $this->_options['DecoderFPS'], $this->_options['DecoderExactRender']);
		
		if (empty($this->__mashData['duration'])) throw new UnexpectedValueException('Unable to determine mash duration: ' . $this->_options['DecoderConfigURL']);
		
		$no_audio = $this->_options['CoderNoAudio'] || (! $this->__mashData['has_audio']);
		$no_video = $this->_options['CoderNoVideo'] || (! $this->__mashData['has_video']);
			
		if ($no_video && $no_audio) throw new UnexpectedValueException('You cannot set both CoderNoVideo and CoderNoAudio');
		
		
		if (! empty($this->_options['Verbose'])) $this->log('MASH: ' . $this->__mashXML->asXML());
		$this->__cacheMedia();
		
		if (! safe_path($this->_buildDir . 'build')) throw new RuntimeException('Could not create path: ' . $this->_buildDir . 'build');
	
		// do flash first, since it's most likely to produce an error
		if (! $no_video) $this->__buildFlash();
		if (! $no_audio) $audio_path = $this->__buildAudio();
		
		if (! $no_video) $video_path = $this->__buildVideo();
		
		$file_name = $this->_buildDir . $this->_options['CoderFilename'] . '.' .  $this->_options['DecoderExtension'];
		$this->__buildMovie($file_name, $audio_path, $video_path);
		
		return $file_name;
	}	
	function _populateDefaults()
	{
		parent::_populateDefaults();
		$this->_configDefaults['PathFlashplayer'] = array(
			'value' => 'PROGRAM',
			'description' => "Path to Flash Player binary",	
			'default' => 'flashplayer',
		);
		$this->_configDefaults['PathEcasound'] = array(
			'value' => 'PROGRAM',
			'description' => "Path to Ecasound binary",	
			'default' => 'ecasound',
		);
		$this->_configDefaults['PathXvfb'] = array(
			'value' => 'PROGRAM',
			'description' => "Path to xvfb run script",	
			'default' => 'xvfb-run',
		);
		$this->_configDefaults['FlashSeconds'] = array(
			'value' => 'NUMBER',
			'description' => "Timeout for launching of Flash Player",	
			'default' => 30,
		);
		foreach(MovieMasher_Coder_Decoder::$defaultOptions as $k => $a)
		{
			$this->_optionsDefaults[$k] = $a;
		}
	}
	function _setupSteps()
	{
		$this->_addStep('CacheFiles');
		if (! $this->_options['CoderNoVideo']) 
		{
			$this->_addStep('LaunchPlayer');
			$this->_addStep('BuildFlash');
		}
		if (! $this->_options['CoderNoAudio']) $this->_addStep('BuildAudio');
		
		$this->_addStep('BuildFile');
	}
	function __cacheMedia() 
	{
		$fps = floatval($this->_options['DecoderFPS']);
		
		// cache frames for all video files used in flash
		$z = sizeof($this->__mashData['timespans']);
		for ($i = 0; $i < $z; $i++)
		{
			$span = $this->__mashData['timespans'][$i];
			$span_start = $span[0];
			$span_end = $span[0] + $span[1];
			$clips = MovieMasher_Coder_Decoder::videoBetween($this->__mashData['clips'], $span_start, $span_end);
			$this->_progressStep('CacheFiles', (1 + round(30 * ($i / $z))), 'Caching Frames');
			foreach($clips as $clip)
			{
				if ( empty($clip['encode'])) continue;
				
				$clip_trim = $this->__clipTrim($clip, $span_start, $span_end, $fps);
				
				if (! $clip_trim) throw new UnexpectedValueException('Could not get clip info: ' . $clip['id']);
				$media_tag = $this->__mashData['media'][$clip['id']];
				
				$url = (string) $media_tag['source'];
				
				$url = absolute_url(end_with_slash($this->_options['CoderBaseURL']), $url);
				
				$ext = file_extension($url);
				if (! $ext) throw new UnexpectedValueException('Media source attributes must have a file extension: ' . $url);
				$vid_file_path = cache_url($url, $this->_options['DirCache']);
				if (! $vid_file_path) throw new UnexpectedValueException('Could not cache URL: ' . $url);
				
				
				
				$options = array();
				
				
				$orig_dimensions = get_file_info('dimensions', $vid_file_path, $this->_options['PathFFmpeg']);
				if (! $orig_dimensions) throw new RuntimeException('Could not read dimensions: ' . $vid_file_path);
			
				$target_dimensions = scale_proud($orig_dimensions, $this->_options['DecoderDimensions']);
				if (! $target_dimensions) $target_dimensions = $this->_options['DecoderDimensions'];
				
				
				$options['dimensions'] = $target_dimensions;		
				
				$options['bitrate'] = 8000; // max?
				
				$options['dimensions_dir'] = $this->_options['DecoderDimensions'];
				$options['duration'] = $clip['duration'];
				$switches = array();
				$fps_secs = floatval(1) /  $this->__mashData['quantize']; // we need an extra frame in mash's fps
				if ($clip_trim['trimstart']) 
				{
					$clip_trim['trimstart'] -= $fps_secs;
					$clip_trim['trimlength'] += $fps_secs;
				}
				$clip_trim['trimlength'] += $fps_secs;
				
				if (($clip['speed'] != 1) || (! empty($this->_options['DecoderCacheAllVideoFrames'])))
				{
					// TODO: don't cache all the frames when speed isn't normal
					$clip_trim['trimstart'] = 0;
					$clip_trim['trimlength'] = -1;
				}
				//$this->log('Caching ' . ((string) $media_tag['label']) . ' @ ' . $this->_options['DecoderFPS'] . ' ' . $clip_trim['trimstart'] . ' -> ' . $clip_trim['trimlength']);
				$cached_frames = cache_file_frames($vid_file_path, $this->_options['DecoderFPS'], $clip_trim['trimstart'], $clip_trim['trimlength'], $options, $switches, $this->_options['PathFFmpeg']);
				if (! $cached_frames) throw new RuntimeException('Could not prepare to cache image sequence: ' . $url);
				if ((! empty($this->_options['Verbose'])) && (! empty($cached_frames['command']))) $this->log($cached_frames['command'] . "\n" . $cached_frames['result']);
				if (! $cached_frames['files']) throw new RuntimeException('Could not cache image sequence: ' . $url);
				
				
				$media_tag['url'] = 'http://' . $this->getOption('HostLocal') . '/mm.' . $this->getVersion() . '/cache/' . frame_file_path(url_file_path($url), $this->_options['DecoderDimensions'], $this->_options['DecoderFPS']);
				
			}
		}
	
		// cache the non-flash video content
		
		$zero = floatval(0);
		$cur_time = $zero;
		
		$z = sizeof($this->__mashData['timespans']);
		
		for ($i = 0; $i < $z; $i++)
		{
			if (floatgtr($this->__mashData['timespans'][$i][0], $cur_time))
			{
				// first timespan doesn't start where the last left off, so there is something between
				$this->__cacheVisuals($cur_time, $this->__mashData['timespans'][$i][0]);
			}
			$cur_time = $this->__mashData['timespans'][$i][1];
			$this->_progressStep('CacheFiles', 30 + (1 + round(30 * ($i / $z))), 'Caching Visuals');
		}
		
		if (! floatcmp($cur_time, $this->__mashData['duration']))
		{
			// last timespan doesn't end the mash, so there is stuff after it
			$this->__cacheVisuals($cur_time, $this->__mashData['duration']);
		}
	
		// cache audio and video with audio files
		$i = 0;
		$z = sizeof(array_keys($this->__mashData['cache_urls']));
	
		foreach($this->__mashData['cache_urls'] as $url => $true)
		{
			$this->_progressStep('CacheFiles', 60 + (1 + round(30 * (($i++) / $z))), 'Caching Audio');
			
			$result = cache_url($url, $this->_options['DirCache']);
			if (! $result) throw new RuntimeException('Could not cache audio: ' . $url);
			
		}					
		$this->_progressStep('CacheFiles', 100, 'Cached Media');
	}
	function __cacheVisuals($start, $stop) // floats in seconds
	{
		// will download and check the dimensions of all video and image content between start and stop times
		
		$clips = MovieMasher_Coder_Decoder::videoBetween($this->__mashData['clips'], $start, $stop);
		$fps = floatval($this->_options['DecoderFPS']);
		$z = sizeof($clips);
		for ($i = 0; $i < $z; $i++)
		{
			$clip = $clips[$i]; // id, type, tag, start, stop, duration (as floats)
						
			$clip_trim = $this->__clipTrim($clip, $start, $stop, $fps);
			if (! $clip_trim) throw new UnexpectedValueException('Could not determine clip trim: ' . $clip['id']);
			
			$media_tag = $this->__mashData['media'][$clip['id']];
			
			
			$dims = explode('x', $this->_options['DecoderDimensions']);
			
			$url = (string) $media_tag['source'];
			if (! $url) $url = (string) $media_tag['url'];
			$url = MovieMasher_Coder::cleanURL($url);
					
			$url = absolute_url(end_with_slash($this->_options['CoderBaseURL']), $url);
						
			switch($clip['type'])
			{
				case 'image':
				{
					$file_path = cache_url($url, $this->_options['DirCache']);
					if (! $file_path) throw new RuntimeException('Could not cache image: ' . $url);
				
					$orig_dims = get_file_info('dimensions', $file_path, $this->_options['PathFFmpeg']);
					if (! $orig_dims) throw new RuntimeException('Could not determine dimensions: ' . $url);
				
					break;
				}
				case 'video':
				{
					$video =  (string) $media_tag['source'];
					$video = MovieMasher_Coder::cleanURL($video);
					
					if ($video) $url = absolute_url(end_with_slash($this->_options['CoderBaseURL']), $video);
					$ext = file_extension($url);
					if ($ext)
					{
						// grab the video file 
						$file_path = cache_url($url, $this->_options['DirCache']);
						if (! $file_path) throw new RuntimeException('Could not cache video: ' . $url);
					}
					else
					{
						// grab image sequence - very untested!!
						
						$clip_fps = floatval((string) $media_tag['fps']);
						$options = array();
						$options['duration'] = $clip_trim['medialength'];
						$options['zeropadding'] = intval($media_tag['zeropadding']);
						$begin = (string) $media_tag['begin'];
						if ($begin) $options['begin'] = $begin;
						$options['pattern'] = (string) $media_tag['pattern'];
						$options['increment'] = (string) $media_tag['increment'];
						$fps_secs = floatval(1) / $clip_fps;
						
						$clip_trim['trimstart'] = floor($clip_trim['trimstart'] / $fps_secs) * $fps_secs;
						
						// TODO: don't cache it all (need one based file links?)
						$options = cache_sequence($url, $fps, $clip_fps, 0, $options['duration'], $this->_options['DirCache'], $options);
						//$options = cache_sequence($url, $fps, $clip_fps, $clip_trim['trimstart'], $clip_trim['trimlength'], $this->_options['DirCache'], $options);
						if (! $options) throw new RuntimeException('Could not cache image sequence: ' . $url);
						$file_path = url_file_path($url, $this->_options['DirCache']);
						
					}
				
					$orig_dims = get_file_info('dimensions', $file_path, $this->_options['PathFFmpeg']);
					if (! $orig_dims) throw new RuntimeException('Could not determine dimensions: ' . $file_path);
					$orig_dims = explode('x', $orig_dims);
					break;
				}
			}
		}
	}
	function __cleanUpJob()
	{
		$this->__mashXML = null;
		$this->__mashData = array();
	}
	function __clipTrim($clip, $start, $stop, $fps) //clip object as returned by videoBetween()
	{
		$zero = floatval(0);
		$one = floatval(1);
		$result = array();
		
		
		// if clip is composited start is zero
		$orig_clip_start = $clip['start'];
		if ($clip['track'])
		{
			$start -= $orig_clip_start;
			$stop -= $orig_clip_start;
			$orig_clip_start = $zero;
		}
		$orig_clip_length = $clip['length'];
		$orig_clip_end = $orig_clip_length + $orig_clip_start;
		$clip_start = floatmax($orig_clip_start, $start);
		$clip_length = floatmin($orig_clip_end, $stop) - $clip_start;
		$orig_clip_trimstart = $clip['trimstart'];
		$clip_trimstart = $orig_clip_trimstart + ($clip_start - $orig_clip_start);
		$frame_seconds = $one / $fps;
		$clip_trimstart = floor($clip_trimstart / $frame_seconds) * $frame_seconds;
		$clip_length = floor($clip_length / $frame_seconds) * $frame_seconds;
		
		$media_duration = $clip['duration'];
		if (! floatgtr($media_duration, $zero))
		{
			$media_duration = $orig_clip_length;
		}
		// trim may not round out well, so check it 
		$clip_length = floatmin($clip_length, $media_duration - $clip_trimstart);
		
		if (floatgtr($clip_length, $zero))
		{
			$result['trimstart'] = $clip_trimstart;
			$result['trimlength'] = $clip_length;
			$result['medialength'] = $media_duration;
		}
		else throw new UnexpectedValueException('Could not determine trim of clip with no length: ' . $clip['id']);
		return $result;
	}
	function __buildAudio()
	{
		$result = FALSE;
		$c = 0;
		$y = sizeof(array_keys($this->__mashData['cache_urls']));
		
		foreach($this->__mashData['cache_urls'] as $url => $true)
		{
			$this->_progressStep('CacheFiles', 1 + round(20 * ($c / $y)), 'Caching Media');
			
			$result = cache_url($url, $this->_options['DirCache']);
			if (! $result) throw new RuntimeException('Could not cache audio: ' . $url);
		
			$file_path = $result;
			$ext = file_extension($file_path);
			switch ($ext)
			{
				//case 'mp3': // recent version of ecasound doesn't support seeking mp3s
				case 'wav':
				case 'aiff':
				case 'aif':
					break;
				default:
				{
					// needs to be converted for ecasound
					
					$cached_wav = cache_file_wav($file_path, array(), $this->_options['PathFFmpeg']);
					if (! $cached_wav) throw new RuntimeException('Could not determine path to audio wav file: ' . $file_path);
					
					if (! empty($this->_options['Verbose'])) $this->log($cached_wav['command']);
					if (! $cached_wav['path']) throw new RuntimeException('Could not build audio wav file: ' . $file_path);
					$file_path = $cached_wav['path'];
				}
			}
		
			$this->__mashData['cache_urls'][$url] = $file_path;
			$this->_progressStep('CacheFiles', 100, 'Cached Media');
		}
	
		$this->_progressStep('BuildAudio', 25, 'Building Audio');
		$audio_path = $this->_buildDir . 'build/audio.wav';
		
		if ($this->__mashData['has_audio']) 
		{
			$path = $this->_options['CoderBaseURL'];
			$cmd = $this->_options['PathEcasound'];
			$counter = 1;
			$last_sound = floatval(0);
			$one = floatval(1);
				
			foreach($this->__mashData['clips'] as $clip)
			{
				if (! $clip['audio']) continue;
				
				// make sure we've got a locally cached file for this url
				$file_path = $this->__mashData['cache_urls'][$clip['audio']];
				if (! $file_path) throw new RuntimeException('No path for audio URL: ' . $clip['audio']);
				
				$cmd .= ' -a:' . ($counter ++) . ' -i ';
				if (floatgtr($clip['loops'], $one)) $cmd .= ' audioloop,';
				$cmd .= "playat,{$clip['start']},select,{$clip['trimstart']},{$clip['length']},$file_path";
				
				if (floatgtr($clip['loops'], $one)) $cmd .= ' -t:' . ($clip['duration'] * $clip['loops']);
				
				$volume = $clip['volume'];
				$volume = explode(',', $volume);
				
				$z = sizeof($volume) / 2;
				$cmd .= ' -ea:0 -klg:1,0,100,' . $z;
				
				for ($i = 0; $i < $z; $i++)
				{
					$p = ($i + 1) * 2;
					$pos = floatval($volume[$p - 2]);
					$val = floatval($volume[$p - 1]) / floatval(100);
					if ($pos) $pos = ($clip['length'] * $clip['loops'] * $pos) / floatval(100);										
					$cmd .= ',' . ($clip['start'] + $pos) . ',' . $val;
				}
				$last_sound = floatmax($last_sound, $clip['start'] + $clip['length']);
			}
			// if there is space at the end, fill it with silence
			if (floatgtr($this->__mashData['duration'], $last_sound))
			{
				//$this->log('duration = ' . $this->__mashData['duration'] . ' last_sound = ' . $last_sound);
				$cmd .= ' -a:' . $counter . ' -i ';
				$cmd .= 'playat,0,tone,sine,0,' . $this->__mashData['duration'];
			}
			$cmd .= ' -a:all';
			$cmd .= ' -o ' . $audio_path;
		}
		if ($cmd)
		{
			$result = $this->_shellExecute($cmd);
			if (! file_exists($audio_path)) throw new RuntimeException('Could not build audio: ' . $cmd);
			$result = $audio_path;
		}
		return $result;
	}
	function __buildFlash()
	{
		
		// see if there are areas requiring flash rendering
		if (! empty($this->__mashData['timespans']))
		{
			// create processing file, will be removed by one of the children
			if (! @file_put_contents($this->_buildDir . 'processing.txt', '1')) throw new RuntimeException('Problem writing processing file');
		
					
			// spawn the applet thread
			$start_time = microtime(true);
			$started = time();
			$this->_progressStep('LaunchPlayer', 1, 'Preparing Mash');
			$has_started = 0;
			
			$this->__flashStartProcessing();
			
			$frame_count = $this->__mashData['timespan_frame_count'];
			$zeropadding = strlen($frame_count);
		
			
			// wait for flash client to process
			while ($this->__flashIsProcessing()) 
			{
				$mash_frames = $this->__flashFrames();
				$kill_flash = FALSE;
				
				if ($mash_frames > 0)
				{
					if (! $has_started)
					{
						$has_started = 1;
						$this->_progressStep('LaunchPlayer', 100, 'Mash Prepared');
					}
					else if ($mash_frames >= $frame_count) $kill_flash = TRUE;
					else
					{
						$this->_progressStep('BuildFlash', 100 * ($mash_frames / $frame_count), 'Decoding Frame ' . $mash_frames . ' of ' . $frame_count);
		
					}
				}
				else
				{
					if ((time() - $started) > $this->_options['FlashSeconds'])
					{
						$kill_flash = TRUE;
						
						$err = file_get($this->_buildDir . 'error.txt');
						if (! $err) $err = ('No response from Flash: started at ' . date('H:i:s', $started) . ' with timeout of ' . $this->_options['FlashSeconds'] . ' now ' . date('H:i:s')); 
						
					}	
				}
				if ($kill_flash)
				{
					$cmd = 'ps ux | awk \'/flashplayer/ && !/awk/ {print $2}\'';
					$result = $this->_shellExecute($cmd, ' 2>&1', 1);
					if ($result)
					{
						$ids = explode("\n", $result);
						$z = sizeof($ids);
						for ($i = $z - 1; $i > 0; $i--)
						{
							$pid = $ids[$i];
							if ($pid) 
							{
								posix_kill($pid, SIGTERM);
								while (pcntl_waitpid(-1, $status, WNOHANG) > 0);
								break;
							}
						}
					}
					if ($err) throw new RuntimeException($err);
				}
				else sleep(5);	
			}
			
			if (file_exists($this->_buildDir . 'error.txt')) throw new RuntimeException(file_get($this->_buildDir . 'error.txt'));
			
			$mash_frames = $this->__flashFrames();
			if ($mash_frames != $frame_count) throw new RuntimeException("Frames not found: $mash_frames != $frame_count");
		}
	}
	function __buildMovie($file_name, $audio_path, $video_path)
	{
		
		$switches = switchesFromString($this->_options['DecoderSwitches']);
		
		
		$options = '';
		
		$cmd = '';
		$cmd .= $this->_options['PathFFmpeg'];
		
		if ($video_path)
		{
			$cmd .= ' -f ' . $this->_options['DecoderVideoFormatInter'];
			//$cmd .= ' -vcodec ' . $this->_options['DecoderVideoCodec'];
			//$cmd .= ' -r ' . $this->_options['DecoderFPS'];
			$cmd .= ' -s ' . $this->_options['DecoderDimensions'];
			//$cmd .= ' -b ' . $this->_options['DecoderVideoBitrate'] . 'k';
			$cmd .= ' -i ' . $video_path;
			$cmd .= ' -t ' . $this->__mashData['duration'];
			$options .= ' -r ' . $this->_options['DecoderFPS'];
			$options .= ' -s ' . $this->_options['DecoderDimensions'];
			if (empty($switches['vcodec']))  $options .= ' -vcodec ' . $this->_options['DecoderVideoCodec'];
			if (empty($switches['b'])) $options .= ' -b ' . $this->_options['DecoderVideoBitrate'] . 'k';
		}
		if ($audio_path)
		{
			$cmd .= ' -i ' . $audio_path;
			$cmd .= ' -t ' . $this->__mashData['duration'];
		
			if (empty($switches['ab'])) $options .= ' -ab ' . $this->_options['DecoderAudioBitrate'] . 'k';
			if (empty($switches['ar'])) $options .= ' -ar ' . $this->_options['DecoderAudioFrequency'];
			if (empty($switches['acodec'])) $options .= ' -acodec ' . $this->_options['DecoderAudioCodec'];
		}
		
		if ($switches) $options .= ' ' . stringFromSwitches($switches);
		
		
		/* 	// single pass
		$cmd .= $options . ' -y ';
		$cmd .= $file_name;		
		$result = $this->_shellExecute($cmd);
		*/
		
		// double pass
		$cmd .= $options . ' -pass {pass} -passlogfile ' . $this->_buildDir . 'FFMPEG2passFinal.txt -y ' . $file_name;
		$cmd1 = str_replace('{pass}', '1', $cmd);
		$cmd2 = str_replace('{pass}', '2', $cmd);
	
		$result = '';
		$result .= $this->_shellExecute($cmd1);
		$result .= $this->_shellExecute($cmd2);

		if (! file_exists($file_name)) throw new RuntimeException('Could not build final file: ' . $cmd . "\n" . $result);
	
		// make sure file is the right duration
		$cmd = '';
		$cmd .= $this->_options['PathFFmpeg'];
		// need to supply codec hints??
		//$cmd .= ' -f ' . $this->_options['DecoderVideoFormat'];
		//$cmd .= ' -vcodec ' . $this->_options['DecoderVideoCodec'];
		$cmd .= ' -i ' . $file_name;
		$response = $this->_shellExecute($cmd);
		
		if (! $response) throw new RuntimeException('Could not create intermediate file ' . $i . ': ' . $cmd);
		
		$file_duration = ffmpeg_info_from_string('duration', $response);
		if (! $file_duration) throw new RuntimeException('Could not determine duration of final file: ' . $cmd . "\n" . $response);
		// enforce precision to one second
		if (floatgtr(abs($file_duration - $this->__mashData['duration']), floatval($this->_options['DecoderFPS']))) throw new RuntimeException('Final file duration of ' . $file_duration . ' does not match mash duration of ' . $this->__mashData['duration']);
		
		$this->_progressStep('BuildFile', 100, 'Encoding Video');
		
	}
	function __buildVideo()
	{
		
		$extension = $this->_options['DecoderVideoExtensionInter'];
		$video_path = $this->_buildDir . 'build.' . $extension;
		
		$pre_cmds = array();
		$cmds = array();
		$switches = switchesFromString($this->_options['DecoderSwitchesInter']);
		
		// override any video codec set, since we're using intermediate video format
		//if (! empty($switches['vcodec'])) unset($switches['vcodec']);
		
		$options = '';
		$options .= ' -r ' . $this->_options['DecoderFPS'];
		
		//if (empty($switches['vcodec'])) $options .= ' -vcodec ' . $this->_options['DecoderVideoCodec'];
		if (empty($switches['b'])) $options .= ' -b ' . (empty($this->_options['DecoderVideoBitrateInter']) ? $this->_options['DecoderVideoBitrate'] : $this->_options['DecoderVideoBitrateInter']) . 'k';
		
		if ($switches) $options .= ' ' . stringFromSwitches($switches);
		

		$zero = floatval(0);
		$cur_time = $zero;
		
		$z = sizeof($this->__mashData['timespans']);
		
		for ($i = 0; $i < $z; $i++)
		{
			if (floatgtr($this->__mashData['timespans'][$i][0], $cur_time))
			{
				// first timespan doesn't start where the last left off, so there is something between
				$visual_cmds = $this->__buildVisuals($cur_time, $this->__mashData['timespans'][$i][0]);
				$this->log('building visuals ' . print_r($visual_cmds, 1));

				$cmds = array_merge($cmds, $visual_cmds);
			}
			$cmd = '';
			$cmd .= $this->_options['PathFFmpeg'];
			$cur_time = $this->__mashData['timespans'][$i][1];
			$cmd .= ' -i ' . $this->_buildDir . 'build/' . $i . '-%' . strlen($this->__mashData['timespan_frame_count']) . 'd.jpg';
			$cmd .= ' -t ' . ($this->__mashData['timespans'][$i][1] - $this->__mashData['timespans'][$i][0]);
			$cmds[] = $cmd;
			$this->log('building flash ' . $cmd);

		}
	
		if (! floatcmp($cur_time, $this->__mashData['duration']))
		{
			// last timespan doesn't end the mash, so there is stuff after it
			$visual_cmds = $this->__buildVisuals($cur_time, $this->__mashData['duration']);
			//$this->log('building trailing visuals ' . print_r($visual_cmds, 1));

			$cmds = array_merge($cmds, $visual_cmds);
		}
		$options .= ' -f ' . $this->_options['DecoderVideoFormatInter'];
		$options .= ' -vcodec ' . $this->_options['DecoderVideoCodecInter'];
		$options .= ' -an ';
	
		$z = sizeof($pre_cmds);
		for ($i = 0; $i < $z; $i++)
		{
			$cmd = $pre_cmds[$i];
			$result = $this->_shellExecute($cmd);
			
			$this->_progressStep('BuildFile', round((($i + 1) * 50) / $z), 'Encoding Frames');
		}
		$z = sizeof($cmds);
		$files = array();
		for ($i = 0; $i < $z; $i++)
		{
			$result = '';
			
			$file_name = $this->_buildDir . 'video_' . $i . '.' . $extension;
			
			$cmd = $cmds[$i];
			$files[] = $file_name;
			
			/*	// single pass
			$cmd .= $options . ' -y ' . $file_name;
			$result .= $this->_shellExecute($cmd);
			*/
			
			// double pass
			$cmd .= $options . ' -pass {pass} -passlogfile ' . $this->_buildDir . 'FFMPEG2passInter.txt -y ' . $file_name;
			$cmd1 = str_replace('{pass}', '1', $cmd);
			$cmd2 = str_replace('{pass}', '2', $cmd);
		
			$result .= $this->_shellExecute($cmd1);
			$result .= $this->_shellExecute($cmd2);
				


			
			if ((! file_exists($file_name)) || (! @filesize($file_name))) throw new RuntimeException('Could not execute build command: ' . $cmd . "\n" . $result);
		
			// make sure intermediate file is the right dimensions
			$cmd = '';
			$cmd .= $this->_options['PathFFmpeg'] . ' -f ' . $this->_options['DecoderVideoFormatInter'];
			// need to supply codec hint
			$cmd .= ' -vcodec ' . $this->_options['DecoderVideoCodecInter'];
			$cmd .= ' -i ' . $file_name;
			
			$response = $this->_shellExecute($cmd);
			
			if (! $response) throw new RuntimeException('Could not create intermediate file ' . $i . ': ' . $cmd);
			 
			$int_dims = ffmpeg_info_from_string('dimensions', $response);
			
			if (! $int_dims) throw new RuntimeException('Could not determing intermediate file dimensions ' . $i . ': ' . $cmd . "\n" . $response);
			if ($this->_options['DecoderDimensions'] != $int_dims) throw new RuntimeException('Inter dimensions do not equal output dimensions ' . $i . ' ' . $int_dims);
			
		
			
			$this->_progressStep('BuildFile', round((($i + 1) * 50) / $z), 'Encoding Video');
		}
		
		if ($files)
		{
			// concat the files
			if (sizeof($files) > 1)
			{
				$cmd = 'cat ' . join(' ', $files) . ' > ' . $video_path;
				$result = $this->_shellExecute($cmd, ' 2>&1', 1);
				if (! file_exists($video_path)) throw new RuntimeException('Could not merge intermediate files: ' . $cmd . "\n" . $result);
			}
			else rename($files[0], $video_path);
		}
		return $video_path;
	}
	function __buildVisuals($start, $stop) // floats in seconds
	{
		$path = $this->_options['CoderBaseURL'];
		
		$result = array();
		$clips = MovieMasher_Coder_Decoder::videoBetween($this->__mashData['clips'], $start, $stop);
		

		$fps = floatval($this->_options['DecoderFPS']);
		$z = sizeof($clips);
		for ($i = 0; $i < $z; $i++)
		{
			$clip = $clips[$i]; // id, type, tag, start, stop, duration (as floats)
						
			$clip_trim = $this->__clipTrim($clip, $start, $stop, $fps);
			if (! $clip_trim) throw new UnexpectedValueException('Could not determine clip trim: ' . $clip['id']);
			
			$media_tag = $this->__mashData['media'][$clip['id']];
			
			
			$cmd = '';
			$cmd .= $this->_options['PathFFmpeg'];
			
			$dims = explode('x', $this->_options['DecoderDimensions']);
			
			
			$url = (string) $media_tag['source'];
			if (! $url) $url = (string) $media_tag['url'];
			$url = absolute_url(end_with_slash($this->_options['CoderBaseURL']), $url);
						
			$url = MovieMasher_Coder::cleanURL($url);
					
			
			switch($clip['type'])
			{
				case 'image':
				{
					$file_path = cache_url($url, $this->_options['DirCache']);
					if (! $file_path) throw new RuntimeException('Could not cache image: ' . $url);
					
					
					$orig_dims = get_file_info('dimensions', $file_path, $this->_options['PathFFmpeg']);
					if (! $orig_dims) throw new RuntimeException('Could not determine image dimensions: ' . $url);
					$orig_dims = explode('x', $orig_dims);
				
					$switches = scale_switches($orig_dims, $dims, $clip['fill']);
					
					$cmd .= ' -loop_input -vframes ' . floor($fps * $clip_trim['trimlength']);
					$cmd .= ' -s ' . $orig_dims[0] . 'x' . $orig_dims[1];
					$cmd .= ' -i ' . $file_path;
					
					if ($switches) $cmd .= ' ' . stringFromSwitches($switches);
					else $cmd .= ' -s ' . $this->_options['DecoderDimensions'];
				
					break;
				}
				case 'video':
				{
					$video =  (string) $media_tag['source'];
					$video = MovieMasher_Coder::cleanURL($video);
					
					if ($video) $url = absolute_url(end_with_slash($this->_options['CoderBaseURL']), $video);
					$ext = file_extension($url);
					if ($ext)
					{
						// grab the video file 
						$input_path = $file_path = cache_url($url, $this->_options['DirCache']);
						if (! $file_path) throw new RuntimeException('Could not cache video: ' . $url);
					
					}
					else
					{
						// grab image sequence - very untested
						
						$clip_fps = floatval((string) $media_tag['fps']);
						$fps_secs = floatval(1) / $clip_fps;
						
						$clip_trim['trimstart'] = floor($clip_trim['trimstart'] / $fps_secs) * $fps_secs;
						$cmd .= ' -r ' . $clip_fps;
					
						$file_path = url_file_path($url, $this->_options['DirCache']);
						$orig_dims = get_file_info('dimensions', $file_path, $this->_options['PathFFmpeg']);
						if (! $orig_dims) throw new RuntimeException('Could not determine image sequence dimensions: ' . $url);
						
						$input_path = frame_file_path($file_path, $orig_dims, $clip_fps);
						$input_path .= '%' . intval($media_tag['zeropadding']) . 'd.jpg';
						$fps = $clip_fps;
					
					
					}
				
					$orig_dims = get_file_info('dimensions', $file_path, $this->_options['PathFFmpeg']);
					if (! $orig_dims) throw new RuntimeException('Could not determine dimensions: ' . $file_path . ' ' . $this->_options['PathFFmpeg']);
					$orig_dims = explode('x', $orig_dims);
				
				
					$switches = scale_switches($orig_dims, $dims, $clip['fill']);
					
					$cmd .= ' -vframes ' . floor($fps * $clip_trim['trimlength']);
					$cmd .= ' -s ' . $orig_dims[0] . 'x' . $orig_dims[1];
					$cmd .= ' -i ' . $input_path;
					if ($clip_trim['trimstart']) $cmd .= ' -ss ' . $clip_trim['trimstart'];
					$cmd .= ' -an'; // no audio
					if ($switches) $cmd .= ' ' . stringFromSwitches($switches);
					else $cmd .= ' -s ' . $this->_options['DecoderDimensions'];

					break;
				}
			}
			$cmd .= ' -t ' . $clip_trim['trimlength'];
			$result[] = $cmd;
		}
		return $result;
		
	}
	function __flashConfiguration($path)
	{
		$size = explode('x', $this->_options['DecoderDimensions']);
		
		
		$local_host = $this->getOption('HostLocal');
		
		
		$decoder_url = dirname(dirname(dirname($this->_options['DecoderAppletURL'])));
		$mm_url = dirname(dirname($decoder_url));
		$policy = $mm_url . '/crossdomain.xml';
		$decoder_url .= '/control/Decoder/' . basename($this->_options['DecoderAppletURL']) . '@Decoder';
				
		$s = MOVIEMASHER_XML_DECLARATION;
		$s .= '<moviemasher>' . "\n";
		if (! empty($this->_options['DecoderPolicyURL'])) $s .= '<option type="server" policy="' . $this->_options['DecoderPolicyURL'] . '" />' . "\n";
		$s .= '<option type="server" policy="http://' . $local_host . '/crossdomain.xml" />' . "\n";
		$s .= '
	<panels>
		<panel color="0" curve="0" width="' . $size[0] . '" height="' . $size[1] . '" x="0" y="0">
			<bar size="*">
				<control 
					fps="' . $this->_options['DecoderFPS'] . '" 
					id="player" symbol="' . $decoder_url . '" 
					localhost="' . $local_host . '"
					source="mash"
					version="mm.' . $this->getVersion() . '"
					zeropadding="' . strlen($this->__mashData['timespan_frame_count']) . '"
					path="' . $path . '"
					' . (empty($this->_options['DecoderTimecodeColor']) ? '' : 'timecode="1" forecolor="' . $this->_options['DecoderTimecodeColor'] . '"') . '		
				>
				';
		$z = sizeof($this->__mashData['timespans']);
		for ($i = 0; $i < $z; $i++)
		{
			$span = $this->__mashData['timespans'][$i];
			$s .= '<timespan frame="' . $span[2] . '" frames="' . ($span[3] - $span[2]) . '" />' . "\n\t\t";
		}
		$s .= '
				</control>
			</bar>
		</panel>
	</panels>
				
	<option type="font" id="moviemasher_default" font="FreeSans" url="' . $mm_url . '/com/moviemasher/font/FreeSans/stable.swf@FreeSans" />
	' . $this->__mashXML->mash->asXML() . '
</moviemasher>';
		if ($this->getOption('Verbose')) $this->log($s);
		return $s;
	}
	function __flashFrames()
	{
		$c = 0;
		$zeropadding = strlen($this->__mashData['timespan_frame_count']);
		$z = sizeof($this->__mashData['timespans']);
		for ($i = 0; $i < $z; $i++)
		{
			$span = $this->__mashData['timespans'][$i];
			$y = $span[3] - $span[2];
			for ($j = 0; $j < $y; $j++)
			{
				$frame_path = $this->_buildDir . 'build/' . $i . '-' . str_pad(1 + $j, $zeropadding, '0', STR_PAD_LEFT) . '.jpg';
				if (! file_exists($frame_path)) 
				{
					return $c;
				}
				$c++;
			}
		}
		return $c;
	}
	function __flashIsProcessing()
	{
		return (file_exists($this->_buildDir . 'processing.txt') && (! file_exists($this->_buildDir . 'error.txt')));
	}
 	function __flashStartProcessing()
	{
		$partial_path = substr($this->_buildDir, strlen($this->_options['DirTemporary'])); 
		$mash_id = $partial_path . 'build';
		$xml = $this->__flashConfiguration($mash_id);
		$mash_path = $this->_options['DirCache'] . md5($mash_id) . '.xml';
		if (! safe_path($mash_path)) throw new RuntimeException('Could create path: ' . $mash_path);
		if (! @file_put_contents($mash_path, $xml)) throw new RuntimeException('Could not write file: ' . $mash_path);
		
		
		$pid = pcntl_fork();
		if ($pid == -1) throw new RuntimeException('pcntl_fork failed');
		
		if (! $pid) // child
		{
			$local_host = $this->getOption('HostLocal');
			
			// launch flashplayer through xvfb
			
			$version = $this->getVersion();
			$cmd = '';
			$cmd .= escapeshellcmd($this->_options['PathXvfb']) . ' ';
			//$cmd .= '-l '; // listen to tcp?
			$cmd .= '-f /root/.Xauthority '; // this MUST be here
			$cmd .= '-e ' . escapeshellcmd($this->_buildDir) . 'Xerr.txt ';
			$size = explode('x', $this->_options['DecoderDimensions']);
			$size[1] += $this->__menuHeight;// menu bars
			$size[0] += 4;
			$size[1] += 4;
			$cmd .= '-s "-screen 0 ' . escapeshellcmd($size[0]) . 'x' . escapeshellcmd($size[1]) . 'x16" ';
			// -fp /usr/share/X11/fonts/misc/" '; 
			$cmd .= escapeshellcmd($this->_options['PathFlashplayer']) . ' "';
			$cmd .= escapeshellcmd($this->_options['DecoderAppletURL']);
			$cmd .= '?base=' . escapeshellcmd(urlencode($this->_options['CoderBaseURL']));
			$cmd .= '&policy=' . urlencode('http://' . escapeshellcmd($local_host) . '/crossdomain.xml');
			$cmd .= '&debug=' . urlencode('http://' . escapeshellcmd($local_host) . '/mm.' . $version . '/error/?path=' . $partial_path);
			
			$cmd .= '&config=' . urlencode('http://' . escapeshellcmd($local_host) . '/mm.' . $version . '/cache/' . md5($mash_id). '.xml');
			$cmd .= '"';
	
			$this->_progressStep('LaunchPlayer', 20, 'Preparing Mash');
			
			// this will launch flashplayer
			$result = $this->_shellExecute($cmd, ' 2>&1', 1);
			
			if (file_exists($this->_buildDir . 'processing.txt')) @unlink($this->_buildDir . 'processing.txt');
			if ($this->_options['Verbose'] && file_exists($mash_path)) @unlink($mash_path);
		
			//if ($this->_options['Verbose']) $this->log(__METHOD__ . ' child exiting');
			exit;
		}
	}
	function __sortByStartTime($a, $b)
	{
		if (floatgtr($a['start'], $b['start'])) return 1;
		if (floatcmp($a['start'], $b['start'])) return 0;
		return -1;
	}
}

?>