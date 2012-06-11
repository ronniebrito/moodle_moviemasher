<?php
/*
This script is called from Movie Masher Applet, after loading decode.php.
The job and video IDs are passed as GET parameters.
The script attempts to check on the progress of the job and either:
	* redirects client back to itself, if job is still processing, by setting 'url' attribute
	* directs client to download video file, by setting 'download' attribute
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
	if (! ($id && $job)) $err = 'Parameters id, job required';
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
	$path_cgi = $moviemasher_client->getOption('PathCGI');
	

	$extension = get_file_info('extension', $media_dir);
	$type = get_file_info('type', $media_dir);
	
	if ((! $extension && $type)) $err = 'Could not determine type and extension: ' . $media_dir;
}


// get job status from Movie Masher Server, and check for error
if (! $err)
{
	try
	{
		$get_target = $job;
		if ($moviemasher_client->progressesLocally())
		{
			$media_host = ($uploads_locally ? ($renders_locally ? $moviemasher_file->getOption('HostLocal') : $moviemasher_file->getOption('Host')) : $moviemasher_file->getOption('HostMedia'));
			$get_target = 'http://' . $media_host . '/' . $path_media . $id . '/';
			$get_target = meta_file_path('progress', $get_target);
		}
		$progress = $moviemasher_client->get('decode', $get_target);
	}
	catch(Exception $ex)
	{
		$err = xml_safe($ex->getMessage());
	}
}

if (! $err)
{
	$attrs = '';
	$progress['percent'] = max(1, floor($progress['percent'] / 2));
	if ($progress['percent'] == 50)
	{
		$progress['status'] = 'Preparing Post...';
		
		
		if ($moviemasher_client->progressesLocally())
		{
			$meta_path = $path_media . $id . '/';
			if ($uploads_locally) $meta_path = $dir_host . $meta_path;
			
			$meta = array();
			$xml_string = '';
			$xml_string .= '<Progress>' . "\n";
			$xml_string .= "\t" . '<PercentDone>2</PercentDone>' . "\n";
			$xml_string .= "\t" . '<Date>' . http_date_string() . '</Date>' . "\n";
			$xml_string .= "\t" . '<Status>Queued for Posting</Status>' . "\n";
			$xml_string .= '</Progress>' . "\n";
			
			$meta['progress'] = $xml_string;
			if (! $moviemasher_file->addMeta($meta_path, $meta)) $err = 'Problem saving job meta data: ' . $meta_path;
		}



		$job = get_file_info('job', $media_dir);
		if (! $job) $err = 'Could not determine job id for file: ' . $media_dir;
		$attrs .= ' url="media/php/encoding.php?job=' . $job . '&amp;id=' . $id . '&amp;start=50"';
		$attrs .= ' delay="1"';
	}
	else 
	{
		$attrs = ' delay="10" url="media/php/decoding.php?job=' . $job . '&amp;id=' . $id . '"';
	}
	$xml = '<moviemasher' . $attrs . ' progress="' . $progress['percent'] . '" status="' . $progress['status'] . '" />';
}

if ($err) $xml = '<moviemasher progress="100" status="" get="javascript:alert(\'' .  htmlspecialchars($err) . '\');" />';

print $xml . "\n\n";
if (! empty($moviemasher_client)) $moviemasher_client->log($xml);

?>