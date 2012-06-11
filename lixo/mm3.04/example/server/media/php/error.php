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
	$dir_host = $moviemasher_client->getOption('DirHost');
	if (! $dir_host) $err = 'Configuration option DirHost required';
}
if (! $err)
{
	// remove uploaded file and directory
	remove_dir_and_files($dir_host . 'moviemasher/example/server/media/upload/' . $id . '/');
}
if (! $err)
{
	// set $err for log entry
	$err = @file_get_contents('php://input');
}

if ($err && (! empty($moviemasher_client))) $moviemasher_client->log($err);

?>