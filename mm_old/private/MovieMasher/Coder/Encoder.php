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

class MovieMasher_Coder_Encoder extends MovieMasher_Coder
{
	static $defaultOptions = array(
		'EncoderAudioBitrate' => array(
			'value' => 'NUMBER',
			'description' => "Audio bitrate in k/s",	
			'default' => '128',
		),
		'EncoderAudioFrequency' => array(
			'value' => 'NUMBER',
			'description' => "Audio frequency in Hz",	
			'default' => '44100',
		),
		'EncoderAudioExtension' => array(
			'value' => 'CODE',
			'description' => "Audio codec to use in resultant file",	
			'default' => 'mp3',
		),
		'EncoderDimensions' => array(
			'value' => 'WxH',
			'description' => "Dimensions of output media",
			'default' => '320x240',
		),
		'EncoderExtension' => array(
			'value' => 'EXTENSION',
			'description' => "File extension used for output media (formally known as EncoderFormat)",	
			'default' => 'jpg',
		),
		'EncoderFPS' => array(
			'value' => 'NUMBER',
			'description' => "Frames Per Second",	
			'default' => '12',
		),
		'EncoderImageQuality' => array(
			'value' => 'NUMBER',
			'description' => "Image quality setting for image files (100 max)",	
			'default' => '50',
		),
		'EncoderSwitches' => array(
			'value' => 'STRING',
			'description' => "FFMPEG command line switches",	
			'emptyok' => 1,
			'default' => '',
		),
		'EncoderURL' => array(
			'value' => 'URL',
			'description' => "File that is to be encoded",	
		),
		'EncoderIncludeOriginal' => array(
			'value' => 'BOOLEAN',
			'description' => "If true, original file will be included in archive",	
			'emptyok' => 1,
			'default' => '',
		),
		'EncoderWaveformBackcolor' => array(
			'value' => 'COLOR',
			'description' => "Background color for audio waveform graphic",	
			'default' => 'FFFFFF',
		),
		'EncoderWaveformExtension' => array(
			'value' => 'EXTENSION',
			'description' => "File extension for audio waveform graphic",	
			'default' => 'png',
		),
		'EncoderWaveformForecolor' => array(
			'value' => 'COLOR',
			'description' => "Foreground color for audio waveform graphic",	
			'default' => '000000',
		),
	
	);
	function Moviemasher_Coder_Encoder($config = array())
    {
		$this->_coderName = 'Encode';
		parent::MovieMasher_Coder($config);
    }	
	static function defaultOption($name)
	{
		$val = '';
		if (! empty(MovieMasher_Coder_Encoder::$defaultOptions[$name]))
		{
			$val = MovieMasher_Coder_Encoder::$defaultOptions[$name]['default'];
		}
		return $val;
	}
 	function _codeFile()
	{
		
     	
     	$file_name = '';
		$file_path = cache_url($this->_options['EncoderURL'], $this->_options['DirCache']);
		if (! $file_path) throw new RuntimeException('Could not cache: ' . $this->_options['EncoderURL']);
	
		$ext = file_extension($file_path);
		
		if (! set_file_info($file_path, 'extension', $ext)) throw new RuntimeException('Could not set extension cache info: ' . $file_path);

		switch ($ext)
		{
			case 'jpeg':
			case 'jpg':
			case 'png':
			case 'ping':
			case 'wbmp':
			case 'bmp':
			case 'gif':
			case 'giff':
			{
				$this->__buildImage($file_path);
				
				break;
			}
			default:
			{
				// encode audio
				
				if (empty($this->_options['CoderNoAudio']))
				{
					$this->__buildAudio($file_path);
				}
				else
				{
					$duration = get_file_info('duration', $file_path, $this->_options['PathFFmpeg']);
					if (! $duration) throw new RuntimeException('Could not determine audio duration');					
					
				}
			
				// encode images and video
				if (! $this->_options['CoderNoVideo']) $this->__buildSequence($file_path);					
			}
		}
	
		if (empty($this->_options['EncoderIncludeOriginal'])) $this->_ignore[] = $file_path;
		$file_name = dir_path($file_path);
	
		
		return $file_name;     
    }		
	function _populateDefaults()
	{
		parent::_populateDefaults();
	
		$this->_configDefaults['PathWaveformGenerator'] = array(
			'value' => 'PATH',
			'description' => "Path to wav2png program for generating waveforms",	
			'default' => 'wav2png',
		);
		foreach(MovieMasher_Coder_Encoder::$defaultOptions as $k => $a)
		{
			$this->_optionsDefaults[$k] = $a;
		}
	}
 	function _setupSteps()
	{
		if (! $this->_options['CoderNoVideo']) 
		{
			$this->_addStep('EncodeImage');
			$this->_addStep('EncodeVideo');
		}
		if (! $this->_options['CoderNoAudio']) 
		{
			$this->_addStep('EncodeAudio');
		}
		$this->_addStep('DownloadFile');
		$this->_addStep('BuildFile');
	}
    function __buildAudio($file_path)
    {
    	if (! empty($this->_options['EncoderAudioExtension']))
    	{
    		if (get_file_info('audio', $file_path, $this->_options['PathFFmpeg']))
    		{
    			$this->_progressStep('EncodeAudio', 5, 'Encoding Audio ' . $file_path);
    			
    				
				$media_path = media_file_path($file_path);
				$audio_path = $media_path . 'audio.' . $this->_options['EncoderAudioExtension'];
   				$switches = array();
    			
				if (! safe_path($audio_path)) throw new RuntimeException('Could not create path: ' . $audio_path);
				
				$cmd = '';
				$cmd .= $this->_options['PathFFmpeg'] . ' -i ';
				$cmd .= $file_path;
				$cmd .= ' -ab ' . $this->_options['EncoderAudioBitrate'] . 'k';
				$cmd .= ' -ar ' . $this->_options['EncoderAudioFrequency'];
				//$cmd .= ' -acodec ' . $this->_options['EncoderAudioExtension'];
				$cmd .= ' -vn ' . $audio_path;
				$response = $this->_shellExecute($cmd);
				
				
				if (! $response) throw new RuntimeException('Problem with audio command: ' . $cmd);
				if (! file_exists($audio_path)) throw new RuntimeException('Could not build audio: ' . $response);
			
			
				$cached_wav = cache_file_wav($file_path, $switches, $this->_options['PathFFmpeg']);
				if (! $cached_wav) throw new RuntimeException('Could not determine path to audio wav file: ' . $file_path);
				
				if (! empty($this->_options['Verbose'])) $this->log($cached_wav['command']);
				if (! $cached_wav['path']) throw new RuntimeException('Could not build audio wav file: ' . $file_path);
			
				
				$wav_file_path = $cached_wav['path'];
			
			
			
				// get a more accurate duration reading from WAV file
					
				if (! ($meta_path = meta_file_path('blah', $wav_file_path))) throw new RuntimeException('Could not determine meta path for ' . $wav_file_path);
				if (! ($meta_dir = dir_path($meta_path))) throw new RuntimeException('Could not determine dir path of ' . $meta_path);
				if (! ($duration = get_file_info('duration', $wav_file_path, $this->_options['PathFFmpeg']))) throw new RuntimeException('Could not determine duration of ' . $wav_file_path);
				if (! set_file_info($file_path, 'duration', $duration)) throw new RuntimeException('Could not set duration of ' . $file_path);
				
				// make waveform graphic
				
				$this->_ignore[] = $wav_file_path;
				$audio_path = $media_path . 'audio.' . $this->_options['EncoderWaveformExtension'];
				$cmd = '';
				$cmd .= $this->_options['PathWaveformGenerator'] . ' --input ' . $wav_file_path;
				$cmd .= ' --height 64 --width 2800';
				$cmd .= ' --linecolor ' . $this->_options['EncoderWaveformForecolor'];
				$cmd .= ' --padding 0';
				$cmd .= ' --backgroundcolor ' . $this->_options['EncoderWaveformBackcolor'];
				$cmd .= ' --output ' . $audio_path;
				
				$response = $this->_shellExecute($cmd);
				if (! file_exists($audio_path)) throw new RuntimeException('Could not create waveform graphic: ' . $cmd);
				
				$this->_shellExecute('rm -R ' . $meta_dir);
			
				$this->_progressStep('EncodeAudio', 100, 'Encoded Audio');
    		}
    	}
    }
    function __buildImage($file_path)
    {
    	
						
		$this->_progressStep('EncodeImage', 5, 'Encoding Image');
    	
 		$ext = file_extension($file_path);
 		
 		$parent_dir = dir_path($file_path);
 	
 		
		$tmp_file = $file_path;
 		
		
		$orig_dimensions = get_file_info('dimensions', $file_path);
		if (! $orig_dimensions) throw new RuntimeException('Could not read image: ' . $file_path);
   		
   		$cmd = '';
		
		$target_dimensions = scale_proud($orig_dimensions, $this->_options['EncoderDimensions']);
		if ($target_dimensions) 
		{
			$cmd .= ' -size ' . $orig_dimensions;
			$cmd .= ' -resize ' . $target_dimensions;
		}
		else $target_dimensions = $this->_options['EncoderDimensions'];
		$frame_path = frame_file_path($file_path, $this->_options['EncoderDimensions'], 1); 		
		$file = $frame_path . '0.' . $this->_options['EncoderExtension'];
		
		if (! safe_path($file)) throw new RuntimeException('Could not create path: ' . $file);

		if ($cmd || ($this->_options['EncoderExtension'] != substr($tmp_file, - strlen($this->_options['EncoderExtension']))))
		{
			$cmd = $this->_options['PathCropper'] . $cmd . ' ' . $tmp_file;
			$cmd .= ' -quality ' . $this->_options['EncoderImageQuality'];
			$cmd .= ' -type TrueColor';
			switch($this->_options['EncoderExtension'])
			{
				case 'ping':
				case 'png':
				case 'giff':
				case 'gif':
					$cmd .= 'Matte -depth 32';
			}
			
			$cmd .= ' ' . $file;
			$shell_result = $this->_shellExecute($cmd);
			if ($shell_result) throw new RuntimeException('Could not create image: ' . $shell_result);
		}
		else copy($tmp_file, $file);
	
	
		if (! file_exists($file)) throw new RuntimeException('Failed to create image: ' . $file . ' ' . $cmd);
		$this->_progressStep('EncodeImage', 100, 'Encoded Image');
	}
    function __buildSequence($file_path)
    {
    	$this->_progressStep('EncodeVideo', 5, 'Encoding Video');
    	
    	if (isset($this->_options['EncoderExtension']))
   		{
			$options = array();
			
			$orig_dimensions = get_file_info('dimensions', $file_path);
			if (! $orig_dimensions) throw new RuntimeException('Could not read dimensions: ' . $file_path);
		
			$target_dimensions = scale_proud($orig_dimensions, $this->_options['EncoderDimensions']);
			if (! $target_dimensions) $target_dimensions = $this->_options['EncoderDimensions'];
			$target_size = explode('x', $target_dimensions);
			$options['bitrate'] = round(($this->_options['EncoderImageQuality'] / 100) * (($target_size[0] * $target_size[1] * 3 * $this->_options['EncoderFPS']) / 1024));
			$options['dimensions'] = $target_dimensions;		
			$options['dimensions_dir'] = $this->_options['EncoderDimensions'];		

			$switches = switchesFromString($this->_options['EncoderSwitches']);
			
			$cached_frames = cache_file_frames($file_path, $this->_options['EncoderFPS'], 0, -1, $options, $switches, $this->_options['PathFFmpeg']);
			if (! $cached_frames) throw new RuntimeException('Could not prepare to cache image sequence: ' . $file_path);

			if ((! empty($this->_options['Verbose'])) && (! empty($cached_frames['command']))) $this->log($cached_frames['command'] . "\n" . $cached_frames['result']);
			if (! $cached_frames['files']) throw new RuntimeException('Could not cache image sequence: ' . $file_path);
			
			$this->_progressStep('EncodeVideo', 100, 'Encoded Video');
			
		
		}
    }    
}
?>