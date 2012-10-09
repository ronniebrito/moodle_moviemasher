<?php

include_once(dirname(__FILE__) . '/floatutils.php');
include_once(dirname(__FILE__) . '/fileutils.php');
include_once(dirname(__FILE__) . '/urlutils.php');

if (! defined('MASH_PATTERN_SWF')) define('MASH_PATTERN_SWF', '/^([.\/[:alnum:]]+[.]swf)*@[[:alnum:]]+/i');
if (! defined('MASH_XPATH_FONT')) define('MASH_XPATH_FONT', '//option[@type="font"]');

// these match com.moviemasher.manager.ConfigManager
if (! defined('MASH_LENGTH_IMAGE')) define('MASH_LENGTH_IMAGE', 1);
if (! defined('MASH_LENGTH_TRANSITION')) define('MASH_LENGTH_TRANSITION', 1);
if (! defined('MASH_LENGTH_FRAME')) define('MASH_LENGTH_FRAME', 2);
if (! defined('MASH_LENGTH_THEME')) define('MASH_LENGTH_THEME', 3);
if (! defined('MASH_LENGTH_EFFECT')) define('MASH_LENGTH_EFFECT', 4);

function mash_clean_xml_url($url)
{
	return str_replace(' ', '%20', trim($url));
}
function mash_clip($clip_tag, $media_tag, $quantize, $index = '', $return_array = FALSE)
{
	$zero = floatval(0);
	$one = floatval(1);
	$types = mash_clip_types();
	$result = array('result' => FALSE, 'warnings' => array(), 'error' => FALSE);
	$muted = '0,0,100,0';
	$clip = mash_data_from_tags($clip_tag, $media_tag);
	
	$clip['index'] = $index;
	if (empty($clip['id'])) $result['warnings'][] = 'No id attribute in ' . mash_description($clip);
	else if (is_null($media_tag)) $result['warnings'][] = 'Nonexistent media in ' . mash_description($clip);
	
	// type defaults to video
	if (empty($clip['type'])) 
	{
		$result['warnings'][] = 'Assuming type video in ' . mash_description($clip);
		$clip['type'] = 'video';
	}
	// duration is float in seconds, defaulting to zero (for modules and images)
	$clip['duration'] = (empty($clip['duration']) ? $zero : floatval($clip['duration']));

	// convert trimstart to float rather than frames, defaults to zero
	$clip['trimstart'] = (empty($clip['trimstart']) ? $zero : floatval($clip['trimstart']) / $quantize);
	
	// convert trimend to float rather than frames, defaults to zero
	$clip['trimend'] = (empty($clip['trimend']) ? $zero : floatval($clip['trimend']) / $quantize);
	
	// loops is float, defaulting to one
	$clip['loops'] = (empty($clip['loops']) ? $one : floatval($clip['loops']));
	
	if (! in_array($clip['type'], $types)) 
	{
		$result['warnings'][] = 'Ignoring unknown type in ' . mash_description($clip);
		$clip = FALSE;
	}
	if ($clip)
	{
		if ($clip['type'] == 'audio')
		{
			if ((! empty($clip['volume'])) && ($clip['volume'] == $muted)) 
			{
				$result['warnings'][] = 'Ignoring muted audio in ' . mash_description($clip);
				$clip = FALSE;
			}
		}
	}
	if ($clip)
	{
		if (! isset($clip['track']))
		{
			$clip['track'] = 0;
			switch($clip['type'])
			{
				case 'effect':
				case 'audio': $clip['track'] = 1;
			}
			$result['warnings'][] = 'Assuming track ' . $clip['track'] . ' in ' . mash_description($clip);
		}
		else $clip['track'] = intval($clip['track']);
		
		if (empty($clip['start'])) 
		{
			if (! isset($clip['start'])) $result['warnings'][] = 'Assuming start zero in ' . mash_description($clip);
			$clip['start'] = $zero;
		}
		else if ($clip['track'] >= 0) $clip['start'] = floatval($clip['start']);
		if ($clip['track'] < 0)  
		{
			// start is sum of clip start and the starts of each parent
			$clip['start'] = __nested_start($clip_tag, $media_tag); 
			if (! float_gtre($clip['start'], $zero)) 
			{
				$result['warnings'][] = 'Ignoring additional composite in ' . mash_description($clip);
				$clip = FALSE; // composite, but not first?
			}	
		}
	}
	if ($clip)
	{
		$clip['start'] = $clip['start'] / $quantize;
		if (! isset($clip['length']))
		{
			$clip['length'] = 0;
			// try to figure from duration
			if (float_gtr($clip['duration'], $zero))
			{
				$result['warnings'][] = 'Determining length from duration in ' . mash_description($clip);
				$clip['length'] = $clip['loops'] * ($clip['duration'] - ($clip['trimend'] + $clip['trimstart']));
			}
			else
			{
				$k = 'MASH_LENGTH_' . strtoupper($clip['type']);
				if (defined($k)) 
				{
					$result['warnings'][] = 'Using default length for type in ' . mash_description($clip);
					$clip['length'] = constant($k);
				}
			}
		}
		;
		$clip['length'] = floatval($clip['length']) / $quantize;
		if (! float_gtr($clip['length'], $zero)) 
		{
			$result['error'] = 'Could not determine length in ' . mash_description($clip);
			$clip = FALSE;
		}
		else if (! float_gtr($clip['duration'], $zero))
		{
			$clip['duration'] = $clip['length'] + $clip['trimend'] + $clip['trimstart'];
		}
	}
	if ($clip) $clip['stop'] = $clip['start'] + $clip['length'];
	if (! $return_array) return $clip;
	$result['result'] = $clip;
	return $result;
}
function mash_clip_between($clip, $start, $stop)
{
	$between = FALSE;
	if (float_gtr($stop, $clip['start']))
	{
		// I start before stop time
		if (float_gtr($clip['stop'], $start))
		{
			// I stop after start time
			$between = TRUE;
		} 
	}
	return $between;
}
function mash_clip_types()
{
	return array('audio', 'image', 'video', 'frame', 'effect', 'transition', 'theme');
}
function mash_clips_between(&$clips, $start, $stop) // returns video between supplied points
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
			case 'frame':
			case 'transition':
			{
				if (! float_gtre($clip['start'], $stop))
				{
					if (float_gtr($clip['stop'], $start))
					{
						$video_clips[] = $clip;
						//$clip = $video_clips[sizeof($video_clips) - 1];
					}
				}
			}
				
		}
	}
	return $video_clips;
}
function mash_data_from_tags($tag, $other_tag = NULL)
{
	$data = array();
	if (! is_null($other_tag))
	{
		$attributes = $other_tag->attributes();
		foreach($attributes as $k => $v) $data[strval($k)] = strval($v);
	}
	if (is_object($tag))
	{
		$attributes = $tag->attributes();
		foreach($attributes as $k => $v) $data[strval($k)] = strval($v);
	}
	return $data;
}
function mash_description($data, $verbose = FALSE)
{
	$bits = array();
	$id = (isset($data['id']) ? $data['id'] : '' );
	$index = (isset($data['index']) ? $data['index'] : '' );
	$type = (isset($data['type']) ? $data['type'] : '' );
	$label = (isset($data['label']) ? $data['label'] : '' );
	
	if ($type) $bits[] = $type;
	$bits[] = 'clip';
	if (strlen($index)) $bits[] = 1 + $index;
	if (strlen($id)) $bits[] = 'ID ' . $id;
	if (strlen($label)) $bits[] = '(' . $label . ')';
	if ($verbose)
	{
		$pairs = array();
		foreach($data as $k => $v)
		{
			switch($k)
			{
				case 'id':
				case 'index':
				case 'type':
				case 'label': break;
				default: $pairs[] = "$k:$v";
			}
		}
		if ($pairs) $bits[] = '{' . join(', ', $pairs) . '}';
	}
	return join(' ', $bits);
}
function mash_duration($xml, $return_array = FALSE)
{	
	$zero = floatval(0);
	$one = floatval(1);
	// should we be respecting 'config' attributes in the tags?
	$result = array('warnings' => array(), 'error' => FALSE, 'result' => $zero);
	
	$duration = $zero;
	$media_id_lookup = array(); // holds references to all media tags (they may get altered)
	$mash_tags = $xml->xpath('//mash');
	if (! sizeof($mash_tags)) $result['error'] = 'No mash tag found';
	else
	{
		$mash_tag = $mash_tags[0];
		$quantize = strval($mash_tag['quantize']);
		$quantize = ($quantize ? floatval($quantize) : $one);
		
		$media_tags = $xml->xpath('//media'); // media can be outside mash tag
		$media_count = sizeof($media_tags);
		for ($i = 0; $i < $media_count; $i++)
		{
			$media_tag = $media_tags[$i];
			$media_id_lookup[strval($media_tag['id'])] = $media_tag;
		}
		// grab first tier clip tags within mash (not nested ones)
		$clip_tags = $mash_tag->clip;
		$clip_count = sizeof($clip_tags);
		for ($i = 0; $i < $clip_count; $i++)
		{
			$media_tag = NULL;
			$clip_tag = $clip_tags[$i];
			$id = (string) $clip_tag['id'];
			if ($id && (! empty($media_id_lookup[$id]))) $media_tag = $media_id_lookup[$id];
			$mash_clip = mash_clip($clip_tag, $media_tag, $quantize, $i, TRUE);
			if (! empty($mash_clip['warnings'])) $result['warnings'] = array_merge($result['warnings'], $mash_clip['warnings']);
			if (! empty($mash_clip['error'])) 
			{
				$result['error'] = $mash_clip['error'];
				break;
			}
			else
			{
				if (! empty($mash_clip['result'])) $duration = float_max($mash_clip['result']['stop'], $duration);
			}	
		}
	}
	if (! $return_array) return $duration;
	if ((! $result['error']) && (! float_gtr($duration, $zero))) $result['error'] = 'Mash has no duration ' . $duration;
	$result['result'] = $duration;
	return $result;
}
function mash_info($xml, $trim = 0, $length = 0, $exact = FALSE)
{	
	// should we be respecting 'config' attributes in the tags?
	
	$zero = floatval(0);
	$one = floatval(1);
	$muted = '0,0,100,0';
	$result = array();
	$result['error'] = '';
	$result['warnings'] = array(); // nonfatal but potentially problematic issues
	$result['duration'] = $zero;
	$result['has_audio'] = FALSE;
	$result['has_video'] = FALSE;
	$result['label'] = '';
	$result['render_all'] = $exact; // switch for full flash rendering
	$result['cache_audio_urls'] = array(); // audio files needing to be cached
	$result['cache_video_urls'] = array(); // visual files needing to be cached (assets and swfs)
	$result['flashtimes'] = array(); // array(startseconds, stopseconds)
	$result['fonts'] = array();
	$result['clips'] = array(); // indexed array() of arrays with keys needed for quick sorting and time based retrieval (start, stop)
	$media_id_lookup = array(); // holds references to all media tags (they may get altered)
	$render_clips = array();
	$mash_duration = mash_duration($xml, TRUE);
	if (! empty($mash_duration['error'])) 
	{
		if ($mash_duration['warnings']) $result['warnings'] = array_merge($result['warnings'], $mash_duration['warnings']);
		$result['error'] = $mash_duration['error'];
	}
	if (! $result['error'])
	{
		$result['duration'] = $mash_duration['result'];
		if ($trim || $length)
		{
			$start = floatval($trim);
			if (! $length) $length = $result['duration'] - $start;
			else $length = floatval($length);
			$stop = $start + $length;
		}
		else 
		{
			$start = $zero;
			$stop = $result['duration'];
		}
		$fonts = array();
		
		$font_tags = $xml->xpath(MASH_XPATH_FONT);
		foreach($font_tags as $font_tag)
		{
			$font = mash_data_from_tags($font_tag);
			if (empty($font['id']))
			{
				if (isset($fonts['default'])) $result['warnings'][] = 'Default font already set, ignoring ' . mash_description($font);
				else $font['id'] = 'default';
			}
			if (! empty($font['id'])) 
			{
				if (isset($fonts[$font['id']])) $result['warnings'][] = 'ID exists, ignoring ' . mash_description($font);
				else 
				{
					$font['url'] = mash_clean_xml_url($font['url']);
					if (empty($font['url'])) $result['warnings'][] = 'Attribute url undefined, ignoring ' . mash_description($font);
					else if (! preg_match(MASH_PATTERN_SWF, $font['url'])) $result['warnings'][] = 'Attribute url invalid, ignoring ' . mash_description($font);
					else $fonts[$font['id']] = $font;
				}
			}
		}
		$mash_tags = $xml->xpath('//mash'); // there will be some, or mash_duration would have choked
	
		$mash_tag = $mash_tags[0];
		$result['label'] = strval($mash_tag['label']);
		$quantize = strval($mash_tag['quantize']);
		$quantize = ($quantize ? floatval($quantize) : $one);
		
		$result['quantize'] = $quantize;
		
		// grab all media tags, even nested ones
		$media_tags = $xml->xpath('//media');
		
		$media_count = sizeof($media_tags);
		for ($i = 0; $i < $media_count; $i++)
		{
			$media_tag = $media_tags[$i];
			$media_id_lookup[strval($media_tag['id'])] = $media_tag;
		}
		
		// grab all clip tags within mash, even nested ones
		$clip_tags = $mash_tag->xpath('//clip');
		$clip_count = sizeof($clip_tags);
		
		for ($i = 0; ((! $result['error']) && ($i < $clip_count)); $i++)
		{
			$media_tag = NULL;
			$clip_tag = $clip_tags[$i];
			$id = (string) $clip_tag['id'];
			if ($id) $media_tag = $media_id_lookup[$id];
			
			$mash_clip = mash_clip($clip_tag, $media_tag, $quantize, $i, TRUE);
			if (! empty($mash_clip['error'])) $result['error'] = $mash_clip['error'];
			
			if (! $result['error'])
			{
				if ($mash_clip['warnings']) $result['warnings'] = array_merge($result['warnings'], $mash_clip['warnings']);
				$clip = $mash_clip['result'];
			}
			if (! $result['error'])
			{
				if (! $clip) continue; // true if it was composite but not first
				$clip['index'] = $i; 
				if (! mash_clip_between($clip, $start, $stop)) 
				{
					$result['warnings'][] = 'Outside range in ' . mash_description($clip);
					continue;
				}
				switch ($clip['type'])
				{
					case 'effect':
					{
						$render_clips[] = $clip;
						if ($clip['track'] < 0) 
						{
							// check if effect clip is attached to mash itself
							$parent_tag = __parent_tag($clip_tag);
							if ($parent_tag->getName() == 'mash') $result['render_all'] = 1;
						}
					} // fall through to other modules
					case 'theme': if ($clip['track'] == 0) $render_clips[] = $clip;
					case 'transition': 
					{	
						if ($clip['type'] == 'transition') $render_clips[] = $clip;
						if (! empty($clip['font']))
						{
							if (empty($fonts[$clip['font']])) $result['error'] = 'Nonexistent font (ID: ' . $clip['font'] . ') required for ' . mash_description($clip);
							else if (! mash_is_moviemasher_path($font['url']))
							{
								$result['cache_video_urls'][$font['url']] = mash_description($font);
								$result['fonts'][$font['id']] = $font;
							}
						}
						if (empty($clip['symbol'])) $result['error'] = 'Attribute symbol required for ' . mash_description($clip);
						else
						{
							$clip['symbol'] = mash_clean_xml_url($clip['symbol']);
							if (! preg_match(MASH_PATTERN_SWF, $clip['symbol'])) $result['error'] = 'Attribute symbol invalid in ' . mash_description($clip);
							else
							{
								if (! mash_is_moviemasher_path($clip['symbol']))
								{
									$result['cache_video_urls'][$clip['symbol']] = mash_description($clip);
								}
								$result['has_video'] = TRUE;
								if (! empty($clip['source'])) 
								{
									$clip['source'] = mash_clean_xml_url($clip['source']);
									if (! mash_is_moviemasher_path($clip['source']))
									{
										$result['cache_video_urls'][$clip['source']] = mash_description($clip);
									}
								
								}
							}
						}
						break;
					}
					case 'frame':
					{
						$clip['frame'] = floatval($clip['frame']);
					}	// intentional fall through to video
					case 'video':
					{
						if (empty($clip['fill'])) $clip['fill'] =  'stretch';
					} // intentional fall through to default
					default:
					{
						if (empty($clip['source'])) $result['error'] = 'Attribute source required in ' . mash_description($clip);
						else 
						{
							$clip['source'] = mash_clean_xml_url($clip['source']);
							if (! file_extension($clip['source'])) $result['error'] = 'Attribute source extension require in ' . mash_description($clip);
							else 
							{
								$could_have_audio = ($clip['type'] != 'image');
								if ($clip['type'] == 'video') 
								{
									$clip['speed'] = (empty($clip['speed']) ? $one : floatval($clip['speed']));
									$could_have_audio = ((! isset($clip['audio'])) || ($clip['audio'] !== '0'));
									$not_time_shifted = float_cmp($clip['speed'], $one);
									if ($could_have_audio) $could_have_audio = $not_time_shifted;
									if (! $not_time_shifted) $render_clips[] = $clip;
								}
								if ($could_have_audio) $could_have_audio = (empty($clip['volume']) || ($clip['volume'] != $muted));
								if ($clip['type'] != 'audio') 
								{
									$result['has_video'] = TRUE;
									$result['cache_video_urls'][$clip['source']] = mash_description($clip);
								}
								else if (! $could_have_audio) $clip = FALSE;
								if ($could_have_audio) 
								{
									$clip['has_audio'] = TRUE;
									$result['cache_audio_urls'][$clip['source']] = mash_description($clip);
								}
							}
						}
					}
				}
			}
			if ((! $result['error']) && $clip) $result['clips'][] = $clip;
		}
	}
	if (! $result['error'])
	{
		usort($result['clips'], '__sort_by_start');
		
		if (! empty($result['render_all']))
		{
			$result['flashtimes'][] = array($zero, $result['duration']);
		}
		else
		{
			usort($render_clips, '__sort_by_start');
		
			// determine flashtimes of all clips requiring flash rendering
			$z = sizeof($render_clips);
			
			for ($i = 0; $i < $z; $i++)
			{
				$clip = $render_clips[$i];

				$clip_start = float_max($start, $clip['start']);
				$clip_stop = float_min($stop, $clip['stop']);
				$y = sizeof($result['flashtimes']);
				for ($j = $y - 1; $j > -1; $j--)
				{
					$spanstart = $result['flashtimes'][$j][0];
					$spanstop = $result['flashtimes'][$j][1];
					if ( ! (float_gtr($clip_start, $spanstop) || float_gtr($spanstart, $clip_stop)))
					{
						// they touch or overlap, so remove and expand
						$clip_start = float_min($clip_start, $spanstart);
						$clip_stop = float_max($clip_stop, $spanstop);
						array_splice($result['flashtimes'], $j, 1);
					}
				}
				$result['flashtimes'][] = array($clip_start, $clip_stop);
			}
			usort($result['flashtimes'], 'float_sort');
			if (sizeof($result['flashtimes']) == 1)
			{
				if (($result['flashtimes'][0][0] == $zero) && ($result['flashtimes'][0][1] == $result['duration']))
				{
					$result['render_all'] = 1;
				}
			}
		}		
	}
	$result['has_audio'] = (count($result['cache_audio_urls']) > 0);

	return $result;
}
function mash_is_moviemasher_path($path)
{
	return (strpos($path, '/com/moviemasher/') !== FALSE);
}
function mash_trim($clip, $start, $stop, $fps = 44100, $frame_fps = 0) // returns trim for supplied clip
{
	$result = array();
	// clip object as returned by videoBetween()
	$zero = floatval(0);
	$one = floatval(1);
	$fps = floatval($fps);
	$frame_seconds = $one / $fps;
	$orig_clip_length = $clip['length'];
	$media_duration = $clip['duration'];
	if (! float_gtr($media_duration, $zero)) $media_duration = $orig_clip_length;
	
	if ($clip['type'] == 'frame')
	{
		$clip_trimstart = floor(($clip['frame'] / $frame_fps) / $frame_seconds) * $frame_seconds;
		$clip_length = $frame_seconds;
	}
	else
	{
		$orig_clip_start = $clip['start'];
		if ($clip['track'])
		{
			$start -= $orig_clip_start;
			$stop -= $orig_clip_start;
			$orig_clip_start = $zero;
		}
		$orig_clip_end = $orig_clip_length + $orig_clip_start;
		$clip_start = float_max($orig_clip_start, $start);
		$clip_length = float_min($orig_clip_end, $stop) - $clip_start;
		$orig_clip_trimstart = $clip['trimstart'];
		$clip_trimstart = $orig_clip_trimstart + ($clip_start - $orig_clip_start);
		$clip_trimstart = floor($clip_trimstart / $frame_seconds) * $frame_seconds;
		$clip_length = floor($clip_length / $frame_seconds) * $frame_seconds;
		
		// trim may not round out well, so check it 
		$clip_length = float_min($clip_length, $media_duration - $clip_trimstart);
	}
	if (float_gtr($clip_length, $zero))
	{
		$result['trimstart'] = $clip_trimstart;
		$result['trimlength'] = $clip_length;
		$result['medialength'] = $media_duration;
	}
	return $result;
}
function __nested_start($tag, $media_tag)
{
	$neg_one = floatval(-1);
	// start for a nested tag is the sum of its start and its parents
	$parent = $tag;
	$result = floatval($parent['start']);
	while (($parent != NULL) && (intval($parent['track']) < 0))
	{
		
		$child = $parent;
		$parent = __parent_tag($child);
		
		switch($child['type'])
		{
			case 'theme': // TODO: create a property for themes to indicate how many composites to utilize
			case 'video':
			case 'frame':
			case 'image':
			{
				// my parent is some sort of composite
				// only include me if I'm the first non effect child tag
				if ($parent != NULL) 
				{
					$children = $parent->children();
					$z = sizeof($children);
					if ($z)
					{
						for ($i = 0; $i < $z; $i++)
						{
							$first_child = $children[$i];
							if (($first_child->getName() == 'clip') && (((string) $first_child['type']) != 'effect')) break;
						}
						if ( ! ( ($first_child == $child) || ($first_child->asXML() == $child->asXML())))
						{
							return $neg_one;
						}
					}
				}
			}
		}
		if ($parent != NULL)
		{
			$result += floatval((string) $parent['start']);
		}
	}
	return $result;
}
function __parent_tag($tag)
{
	$dom = dom_import_simplexml($tag);
	$tag = NULL;
	$dom = $dom->parentNode;
	if ($dom != NULL) $tag = simplexml_import_dom($dom);
	return $tag;
}
function __sort_by_start($a, $b)
{
	if (float_gtr($a['start'], $b['start'])) return 1;
	if (float_cmp($a['start'], $b['start'])) return 0;
	return -1;
}

?>