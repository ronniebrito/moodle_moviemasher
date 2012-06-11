<?php
/*
This script receives the encoded asset from Movie Masher Server as an archive file in $_FILES. The
file is extracted with archiveutils.php and selected files in archive are moved to the directory
named $id in the media/upload directory. We inject a media tag into media.xml 
for the newly uploaded file. If an error is encountered a 400 header is returned and it
is logged, if possible.
*/

$err = '';

// load MovieMasher
if ((! $err) && (! @include_once('MovieMasher/MovieMasher.php'))) $err = 'Problem loading MovieMasher script';

// load objects from configuration
if (! $err)
{
	try
	{
		$moviemasher_client =& MovieMasher::fromConfig('MovieMasher.xml', 'Client');
		$moviemasher_coder =& MovieMasher::fromConfig('MovieMasher.xml', 'Coder', 'Encoder');
	}
	catch(Exception $ex)
	{
		$err = xml_safe($ex->getMessage());
	}
}

// load utilities
if ((! $err) && (! @include_once('MovieMasher/lib/authutils.php'))) $err = 'Problem loading utility script';

// load utilities
if ((! $err) && (! @include_once('MovieMasher/lib/idutils.php'))) $err = 'Problem loading utility script';

// see if the user is autheticated (will NOT exit)
if ((! $err) && (! authenticated())) $err = 'Unauthenticated access';

// load utilities
if ((! $err) && (! @include_once('MovieMasher/lib/archiveutils.php'))) $err = 'Problem loading utility script';

// check to make sure required parameters have been sent
if (! $err)
{
	$id = (empty($_REQUEST['id']) ? '' : $_REQUEST['id']);
	if (! $id ) $err = 'Parameter id required';
}

// check to make sure required configuration options have been set
if (! $err)
{
	$dir_host = $moviemasher_client->getOption('DirHost');
	$tmp_dir = $moviemasher_client->getOption('DirTemporary');
	$filename = $moviemasher_coder->getOption('CoderFilename');
	if (! ($dir_host && $tmp_dir && $filename)) 
	{
		$err = 'Configuration options DirHost, DirTemporary, CoderFilename required';
	}
}

// check to make sure there is a media directory for this ID
if (! $err)
{

	$path_media = $moviemasher_client->getOption('PathMedia');
	if (! $path_media) $err = 'Configuration option PathMedia required';
}

if (! $err)
{
	$path_media .=  authenticated_userid() . '/';
	
	$encoder_fps = $moviemasher_coder->getOption('EncoderFPS');
	if (! $encoder_fps) $encoder_fps = '1';
			
	$encoder_audio_extension = $moviemasher_coder->getOption('EncoderAudioExtension');
	$encoder_wave_extension = $moviemasher_coder->getOption('EncoderWaveformExtension');
	$encoder_dimensions = $moviemasher_coder->getOption('EncoderDimensions');
	
	$media_dir = $dir_host . $path_media . $id . '/';
	$media_extension = get_file_info('extension', $media_dir);
	$type = get_file_info('type', $media_dir);

	$encoder_extension = $moviemasher_coder->getOption('EncoderExtension');
	
	if ($type == 'image') $encoder_extension = $media_extension;
	
	if (! ($encoder_extension && $type)) $err = 'Could not determine type and extension: ' . $media_dir;
}

// make sure $_FILES is set and has item
if ((! $err) && empty($_FILES)) $err = 'No files supplied';

// make sure first item in $_FILES is valid
if (! $err)
{
	foreach($_FILES as $k => $v)
	{
		$file = $_FILES[$k];
		break;
	}
	if (! $file) $err = 'No file supplied';
}

// make sure there wasn't a problem with the upload
if (! $err)
{
	if (! empty($file['error'])) $err = 'Problem with posted file: ' . $file['error'];
	elseif (! is_uploaded_file($file['tmp_name'])) $err = 'Not an uploaded file';
}

// make sure file extension is valid
if (! $err)
{
	$file_name = $file['name'];
	$file_ext = file_extension($file_name);
	if ($file_ext != 'tgz') $err = 'Unsupported extension: ' . $file_ext;
}

// extract the archive to temp directory
if (! $err)
{
	set_time_limit(0);
	$tmp_dir = end_with_slash($tmp_dir);
	$tmp_path = $tmp_dir . unique_id('archive');
	$archive_dir = $tmp_path . '/' . $filename . '/';
	if (! extract_archive($file['tmp_name'], $archive_dir)) $err = 'Could not extract to ' . $archive_dir;	
}

// move select files from the archive to media directory
if (! $err)
{
	switch($type)
	{
		case 'audio':
		case 'video':
		{
			// move any soundtrack
			$frag = 'media/audio.' . $encoder_audio_extension;
			$media_path = $media_dir . $frag;
			$archive_path = $archive_dir . $frag;
			if (file_exists($archive_path)) 
			{
				if (! safe_path($media_path)) $err = 'Could not create directories for ' . $media_path;
				elseif (! @rename($archive_path, $media_path)) $err = 'Could not move audio file from ' . $archive_path . ' to ' . $media_path;
				else
				{
					// move any soundtrack waveform graphic
					$frag = 'media/audio.' . $encoder_wave_extension;
					$archive_path = $archive_dir . $frag;
					$media_path = $media_dir . $frag;
					if (file_exists($archive_path)) 
					{
						if (! @rename($archive_path, $media_path)) $err = 'Could not move audio file from ' . $archive_path . ' to ' . $media_path;
					}
				}
			}
			break;
		}
	}

	if (! $err)
	{
		$extension = $media_extension;
		switch($type)
		{
			case 'video':
				$extension = 'jpg'; // otherwise use image's original extension (eg. png)
			case 'image':
			{
				if ($type == 'image') $encoder_fps = '1';
				// move any frames
				$archive_path = frame_file_path($archive_dir, $encoder_dimensions, $encoder_fps);
				if (file_exists($archive_path)) 
				{
					$media_path = frame_file_path($media_dir, $encoder_dimensions, $encoder_fps);
					if (! move_files_having_extension($extension, $archive_path, $media_path)) $err = 'Could not move ' . $extension . ' files from ' . $archive_path . ' to ' . $media_path;
				}
				else $moviemasher_client->log('Path does not exist: ' . $archive_path);
				break;			
			}
		}
	}
	if (! $err)
	{
		// move any meta data
		$frag = 'meta/';
		$archive_path = $archive_dir . $frag;
		if (file_exists($archive_path))
		{
			$media_path = $media_dir . $frag;
			if (! move_files_having_extension('txt', $archive_path, $media_path, TRUE)) $err = 'Could not move txt files from ' . $archive_path . ' to ' . $media_path;
		}
	}
	
	
	// remove the temporary directory we created, and any remaining files (there shouldn't be any)
	remove_dir_and_files($tmp_path);
}

if ($err)
{
	header('HTTP/1.1: 400 Bad Request');
	header('Status: 400 Bad Request');
	if (! empty($moviemasher_client)) $moviemasher_client->log($err);
}

?>