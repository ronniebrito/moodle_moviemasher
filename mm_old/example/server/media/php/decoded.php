<?php
/*
This script receives the decoded mash from Movie Masher Server as a video file in $_FILES. If the
file is okay, it's moved to the directory named $id in the server/media/upload directory. If an
error is encountered a 400 header is returned and it is logged, if possible.
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
		$moviemasher_file =& MovieMasher::fromConfig('MovieMasher.xml', 'File');
		$moviemasher_coder =& MovieMasher::fromConfig('MovieMasher.xml', 'Coder', 'Encoder');
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
	if (! empty($file['error'])) $err = 'Problem with your file: ' . $file['error'];
	elseif (! is_uploaded_file($file['tmp_name'])) $err = 'Not an uploaded file';
}

// make sure required configuration options have been set
if (! $err)
{
	$uploads_locally = $moviemasher_file->uploadsLocally();
	$renders_locally = $moviemasher_client->rendersLocally();
	if ($renders_locally) $host = $moviemasher_client->getOption('HostLocal');
	else $host = $moviemasher_client->getOption('Host');
	if ($uploads_locally)
	{
		
		$dir_host = $moviemasher_client->getOption('DirHost');
		if (! ($host && $dir_host)) $err = 'Configuration options DirHost and either Host or HostLocal required';
		$media_dir = $dir_host;
	}
	else
	{
		$media_dir = 'http://' . $moviemasher_file->getOption('HostMedia') . '/';
	}
}

// build media path and make sure we know extension and type of uploaded file
if (! $err)
{
	$path_site = $moviemasher_client->getOption('PathSite');
	$path_media = $moviemasher_client->getOption('PathMedia');
	$path_media .=  authenticated_userid() . '/';
	$media_dir .=  $path_media . $id . '/';
	

	$extension = get_file_info('extension', $media_dir);
	$type = get_file_info('type', $media_dir);
	
	if ((! $extension && $type)) $err = 'Could not determine type and extension: ' . $media_dir;
}
// make sure we can determine mime type of uploaded file
if (! $err)
{
	$ext = file_extension($file['name']);
	if (! $ext) $err = 'Could not determine extension of uploaded file: ' . $file['name'];
}

// make sure we cached file extension info and that it matches
if (! $err)
{
	if ($ext != $extension) $err = 'Rendered extension (' . $ext . ') differs from requested (' . $extension . ')';
}

// make sure we can move the uploaded file
if (! $err)
{
	$coder_filename = $moviemasher_coder->getOption('CoderFilename');
	
	$path = $media_dir . $coder_filename . '.' . $ext;
	if (! @move_uploaded_file($file['tmp_name'], $path)) $err = 'Problem moving: ' . $path;
}		

// attempt to change its file permissions
if (! $err)
{
	if (! @chmod($path, 0777)) $err = 'Problem setting permissions of media: ' . $path;
}
if ($err)
{
	header('HTTP/1.1: 400 Bad Request');
	header('Status: 400 Bad Request');
	if (! empty($moviemasher_client)) $moviemasher_client->log($err);
}

?>