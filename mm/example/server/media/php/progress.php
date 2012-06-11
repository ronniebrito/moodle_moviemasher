<?php
/*
This script is called from Movie Masher Server, when an error has occured during job processing.
If the request can be properly authenticated, the directory named $id in media/upload is removed.
The body of the request contains XML formatted progress info indicating the error encountered. 
This error or any other encountered during processing is logged if possible. 
*/

$err = '';

// load MovieMasher
if ((! $err) && (! @include_once('MovieMasher/MovieMasher.php'))) $err = 'Problem loading MovieMasher.php';

// load objects from configuration
if (! $err)
{
	try
	{
		$moviemasher_client =& MovieMasher::fromConfig('MovieMasher.xml', 'Client');
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
if ((! $err) && (! authenticated($moviemasher_client))) $err = 'Unauthenticated access';


// check to make sure required parameters have been sent
if (! $err)
{
	$id = (empty($_REQUEST['id']) ? '' : $_REQUEST['id']);
	if (! $id ) $err = 'Parameter id required';
}
if (! $err)
{
	// set $err for log entry
	$progress = @file_get_contents('php://input');
	if (! $progress) $err = 'No request body provided';
}

// make sure required configuration options have been set
if (! $err)
{
	$uploads_locally = $moviemasher_file->uploadsLocally();
	$path_media = $moviemasher_client->getOption('PathMedia');
	if (! $path_media) $err = 'Configuration option PathMedia required';
	
	if ($uploads_locally)
	{
		$dir_host = $moviemasher_client->getOption('DirHost');
		if (!  $dir_host) $err = 'Configuration option DirHost required';
	}
}

// build media path and make sure we know extension and type of uploaded file
if (! $err)
{
	$path_media .=  authenticated_userid() . '/';
	
	$meta_path = $path_media . $id . '/';
	if ($uploads_locally) $meta_path = $dir_host . $meta_path;
	if (! $moviemasher_file->addMeta($meta_path, 'progress', $progress)) $err = 'Problem saving media meta data: ' . $meta_path;
}

if ($err)
{
	header('HTTP/1.1: 400 Bad Request');
	header('Status: 400 Bad Request');
	if (! empty($moviemasher_client)) $moviemasher_client->log($err);
}
else $moviemasher_client->log($progress);


?>