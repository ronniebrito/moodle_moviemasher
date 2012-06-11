<?php
/*
This script is called from the CGI control, after loading encode.php.
The job and media IDs are in _GET.
The script attempts to check on the progress of the job and either:
	* redirects client back to itself, if job is still processing, by setting 'url' attribute
	* directs client to refresh browser view if job is finished
	* displays javascript alert if error is encountered, by setting 'get' attribute
If possible, the response to client is logged.
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
if ((! $err) && (! authenticated())) $err = 'Unauthenticated access';


// check to make sure required parameters have been sent
if (! $err)
{
	$job = (empty($_REQUEST['job']) ? '' : $_REQUEST['job']);
	$id = (empty($_REQUEST['id']) ? '' : $_REQUEST['id']);
	if (! ($job && $id)) $err = 'Parameters job, id required';
}


// make sure required configuration options have been set
if (! $err)
{
	$uploads_locally = $moviemasher_file->uploadsLocally();
	$renders_locally = $moviemasher_client->rendersLocally();
	$path_media = $moviemasher_client->getOption('PathMedia');
	if (! $path_media) $err = 'Configuration option PathMedia required';
}


// get job status from Movie Masher Server, and check for error
if (! $err)
{

	$path_media .=  authenticated_userid() . '/';
	
	$start = (empty($_REQUEST['start']) ? 0 : $_REQUEST['start']);
	try
	{
		$get_target = $job;
		if ($moviemasher_client->progressesLocally())
		{
			$media_host = ($uploads_locally ? ($renders_locally ? $moviemasher_file->getOption('HostLocal') : $moviemasher_file->getOption('Host')) : $moviemasher_file->getOption('HostMedia'));
			$get_target = 'http://' . $media_host . '/' . $path_media . $id . '/';
			$get_target = meta_file_path('progress', $get_target);
		}
		$progress = $moviemasher_client->get('encode', $get_target);
	}
	catch(Exception $ex)
	{
		$err = xml_safe($ex->getMessage());
	}
}

if (! $err)
{
	$attrs = '';
	// if job is still processing, redirect back here with same parameters
	if ($progress['percent'] < 100) 
	{
		$progress['percent'] = max(1, $start + (($progress['percent'] / 100) * (100 - $start)));		
		$attrs = ' delay="5" url="media/php/encoding.php?job=' . $job . '&amp;id=' . $id . '&amp;start=' . $start . '"';
	}
	else // otherwise we're done, see if an error was generated in encoded.php
	{	
		
		if (! $moviemasher_file->uploadsLocally()) $media_dir = 'http://' . $moviemasher_file->getOption('HostMedia') . '/';
		else $media_dir = $moviemasher_client->getOption('DirHost');
	
		$media_dir .= $path_media . $id . '/';
		
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
				$type = type_from_path($media_dir . 'media.' . get_file_info('extension', $media_dir));
			}
		}
		$attrs = ' trigger="browser.parameters.group=' . $type . '"';
	
	}
	$xml = '<moviemasher' . $attrs . ' progress="' . $progress['percent'] . '" status="' . $progress['status'] . '" />';
}

if ($err) $xml = '<moviemasher progress="100" status="" get=\'javascript:alert("' .  $err . '");\' />';
print $xml . "\n\n";
if (! empty($moviemasher_client)) $moviemasher_client->log($xml);

?>