<?php
/*
This script is called . We inject a media tag into media.xml 
for the newly uploaded file. If an error is encountered a 400 header is returned and it
is logged, if possible.
*/

$err = '';
	
error_reporting(E_ALL);
ini_set('display_errors', 1);
// load MovieMasher
if ((! $err) && (! @include_once('MovieMasher/MovieMasher.php'))) $err = 'Problem loading MovieMasher script';

// load objects from configuration
if (! $err)
{
	try
	{
		$moviemasher_coder =& MovieMasher::fromConfig('MovieMasher.xml', 'Coder', 'Encoder');
		$moviemasher_file =& MovieMasher::fromConfig('MovieMasher.xml', 'File');
	}
	catch(Exception $ex)
	{
		$err = xml_safe($ex->getMessage());
	}
}
// load utilities
if ((! $err) && (! @include_once('MovieMasher/lib/authutils.php'))) $err = 'Problem loading utility script';

// see if the user is autheticated (will NOT exit)
if ((! $err) && (! authenticated())) $err = 'Unauthenticated access';

// check to make sure required parameters have been sent
if (! $err)
{
	$id = (empty($_REQUEST['id']) ? '' : $_REQUEST['id']);
	if (! $id ) $err = 'Parameter id required';
}

// check to make sure required configuration options have been set
if (! $err)
{
	$dir_host = $moviemasher_file->getOption('DirHost');
	$filename = $moviemasher_coder->getOption('CoderFilename');
	$path_media = $moviemasher_file->getOption('PathMedia');
	$path_site = $moviemasher_file->getOption('PathSite');
	$host_media = $moviemasher_file->getOption('HostMedia');
	if (! ($dir_host && $filename && $path_media && ($host_media || $moviemasher_file->uploadsLocally())))
	{
		$err = 'Configuration options DirHost, PathMedia, CoderFilename and perhaps HostMedia required';
	}
}

// check to make sure there is a media directory for this ID
if (! $err)
{
	$path_media .=  authenticated_userid() . '/';
	if ($moviemasher_file->uploadsLocally())
	{
		if (substr($path_media, 0, strlen($path_site)) == $path_site)
		{
			$partial_media_path = substr($path_media, strlen($path_site));
		}
		else $partial_media_path = '/' . $path_media;
		
	}
	else $partial_media_path = 'http://' . $host_media . '/' . $path_media;
	
	$encoder_fps = $moviemasher_coder->getOption('EncoderFPS');
	if (! $encoder_fps) $encoder_fps = '1';
			
	$encoder_audio_extension = $moviemasher_coder->getOption('EncoderAudioExtension');
	$encoder_wave_extension = $moviemasher_coder->getOption('EncoderWaveformExtension');
	$encoder_dimensions = $moviemasher_coder->getOption('EncoderDimensions');
	
	$media_dir = $dir_host;
	if (! $moviemasher_file->uploadsLocally()) $media_dir = 'http://' . $host_media . '/';
	
	$media_dir .= $path_media . $id . '/';
	$media_extension = get_file_info('extension', $media_dir);
	$type = get_file_info('type', $media_dir);
	
	switch ($type)
	{
		case 'image':
		case 'video':
		case 'audio': break;
		default: 
		{
			// Apache must not have delivered a proper mime type to Movie Masher Server, 
			// so let's grab it again from the file path
			$type = type_from_path($media_dir . 'media.' . $media_extension);
			// uncomment the following line to fix the type.txt file for the file
			// set_file_info($media_dir . 'media.' . $media_extension, 'type', $type);
		}
	}
	$encoder_extension = $moviemasher_coder->getOption('EncoderExtension');
	
	if ($type == 'image') 
	{
		$encoder_fps = '1';
		$encoder_extension = $media_extension;
	}
	
	if (! ($encoder_extension && $type)) $err = 'Could not determine type and extension: ' . $media_dir;
}


// try reading in media.xml file containing existing media items
if (! $err)
{
	$media_file_xml_path = $dir_host . $path_media . 'media.xml';
	
	if (file_exists($media_file_xml_path)) $xml_str = @file_get_contents($media_file_xml_path);
	else $xml_str = '<moviemasher></moviemasher>' . "\n";

	if (! $xml_str) $err = 'Problem loading ' . $media_file_xml_path;
	else
	{
		$media_file_xml = @simplexml_load_string($xml_str);
		if (! is_object($media_file_xml)) $err = 'Problem parsing ' . $xml_str;
	}
}

// add media data to existing media.xml file
if (! $err)
{
	$duration = get_file_info('duration', $media_dir);
	$label = get_file_info('label', $media_dir);
	
	// start with an unattributed media tag document
	$media_xml = simplexml_load_string('<moviemasher><media /></moviemasher>');
	
	// add required attributes
	$media_xml->media->addAttribute('type', $type);
	$media_xml->media->addAttribute('id', $id);
	
	// add standard attributes
	$media_xml->media->addAttribute('label', $label);
	$media_xml->media->addAttribute('group', $type);
	
	// add required for rendering
	$media_xml->media->addAttribute('source', $partial_media_path . $id . '/media.' . $media_extension);
	
	$frame_path = frame_file_path($partial_media_path . $id . '/', $encoder_dimensions, $encoder_fps);
	
	$audio = 1;
	$did_icon = 0;
	

	switch($type)
	{
		case 'image':
		{
			$frame_path .= '0.' . $encoder_extension;
			$media_xml->media->addAttribute('url', $frame_path);
			$media_xml->media->addAttribute('icon', $frame_path);
			break;
		}
		case 'video':
		{
			$frames = floor($duration * $encoder_fps);
			$zero_padding = strlen($frames);			
			$media_xml->media->addAttribute('url', $frame_path);
			$media_xml->media->addAttribute('fps', $encoder_fps);
			$media_xml->media->addAttribute('pattern', '%.' . $encoder_extension);
			$media_xml->media->addAttribute('zeropadding', $zero_padding);
			
			// uncomment the following line to use the mid frame as an icon, instead of the playback preview
			// $media_xml->media->addAttribute('icon', $frame_path . str_pad(ceil($frames / 2), $zero_padding, '0', STR_PAD_LEFT) . '.' . $encoder_extension);
			$did_icon = 1;
			$audio = get_file_info('audio', $media_dir);
			// intentional fallthrough to audio
		}
		case 'audio':
		{
			if (! $duration) $duration = get_file_info('duration', $media_dir);
	
			if (! $duration) $err = 'Could not determine duration from: ' . $media_dir;
			else
			{
				$media_xml->media->addAttribute('duration', $duration);
				if ($audio) 
				{
					$media_xml->media->addAttribute('audio', $partial_media_path . $id . '/media/audio.' . $encoder_audio_extension);
					$media_xml->media->addAttribute('wave', $partial_media_path . $id . '/media/audio.' . $encoder_wave_extension);
					if (! $did_icon)
					{
						$media_xml->media->addAttribute('icon', $partial_media_path . $id . '/media/audio.' . $encoder_wave_extension);
					}
				}
				else $media_xml->media->addAttribute('audio', '0'); // put in a zero to indicate that there is no audio
			}
			break;
		}
	}
}
if (! $err)
{
	// build XML string
	$media_tag = (string) $media_xml->media->asXML();
	$xml_str = MOVIEMASHER_XML_DECLARATION;
	$xml_str .= '<moviemasher>';
	$xml_str .= "\n\t" . $media_tag . "\n";
	
	$children = $media_file_xml->children();
	$z = sizeof($children);
	for ($i = 0; $i < $z; $i++) $xml_str .= "\t" . $children[$i]->asXML() . "\n";
	$xml_str .= '</moviemasher>' . "\n";
	
	// write file
	if (! safe_path($media_file_xml_path)) $err = 'Could not create path to ' . $media_file_xml_path;
	else if (! @file_put_contents($media_file_xml_path, $xml_str)) $err = 'Problem writing ' . $media_file_xml_path;
}

if ($err)
{
	header('HTTP/1.1: 400 Bad Request');
	header('Status: 400 Bad Request');
	if (! empty($moviemasher_file)) $moviemasher_file->log($err);
}
else $moviemasher_file->log($media_tag);

?>