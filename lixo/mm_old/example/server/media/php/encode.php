<?php
/*
This script is called from the CGI control, after uploading file to upload.php.
The media ID is in GET, and the file extension and type have been cached to 'meta' directory. 
The script generates an encode job and posts it to Movie Masher Server.
The job ID is passed along with the media ID to encoding.php, by setting the 'url' attribute in response.
If an error is encountered it is displayed in a javascript alert, by setting the 'get' attribute.
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


// make sure required parameters have been sent
if (! $err)
{
	$id = (empty($_REQUEST['id']) ? '' : $_REQUEST['id']);
	if (! $id) $err = 'Parameter id required';
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
	
	if (! ($extension && $type)) $err = 'Could not determine type and extension: ' . $media_dir;
}

// make sure required configuration options have been set for visual assets
if (! $err)
{
	if ($type != 'audio')
	{
		$encoder_dimensions = $moviemasher_client->getOption('EncoderDimensions');
		if (! $encoder_dimensions) $err = 'Configuration option EncoderDimensions required for visual assets';
	}
}
	
// create encode job options
if (! $err)
{
	$options = array();		
	
	$media_host = ($moviemasher_file->uploadsLocally() ? ($renders_locally ? $moviemasher_file->getOption('HostLocal') : $moviemasher_file->getOption('Host')) : $moviemasher_file->getOption('HostMedia'));
	
	$coder_filename = $moviemasher_coder->getOption('CoderFilename');
		
	// specify full URL to uploaded file that needs encoding
	$options['EncoderURL'] = 'http://' . $media_host . '/' . $path_media . $id . '/' . $coder_filename . '.' .  $extension;


	// specify URL to hit in case of encoding error
	$options['CoderErrorURL'] = 'http://' . $host . '/' . $path_cgi . 'error.php?id=' . $id;
	$options['CoderErrorURL'] = authenticated_url($options['CoderErrorURL']);
	$options['CoderDoneURL'] = 'http://' . $host . '/' . $path_cgi . 'addmedia.php?id=' . $id;
	$options['CoderDoneURL'] = authenticated_url($options['CoderDoneURL']);

	if ($moviemasher_client->progressesLocally())
	{
		$options['CoderProgressURL'] = 'http://' . $host . '/' . $path_cgi . 'progress.php?id=' . $id;
		$options['CoderProgressURL'] = authenticated_url($options['CoderProgressURL']);
	}
	// CoderFileURL
	$options['CoderFileURL'] = strtolower($moviemasher_file->getOption('File')) . '://';
	
	if ($uploads_locally)  // all but S3
	{
		if ($renders_locally) $options['CoderFileURL'] .= substr($dir_host, 1) . $path_media . $id;		
		else 
		{
			$options['CoderFileURL'] .= $host . '/' . $path_cgi . 'encoded.php?id=' . $id;
			$options['CoderFileURL'] = authenticated_url($options['CoderFileURL']);
		}
	}
	else 
	{
		// TODO: Change name of S3Bucket
		$bucket_path = $moviemasher_file->getOption('S3Bucket') . '/' . $path_media;
		$options['CoderFileURL'] .= $bucket_path . $id . '/';
	}


	// see if an archive is required (only tgz is supported currently)
	if ($uploads_locally && (! $renders_locally)) $options['CoderArchiveExtension'] = 'tgz';

	// provide hints for files having only one type of AV content
	$options['CoderNoVideo'] = (($type == 'audio') ? 1 : 0);
	$options['CoderNoAudio'] = (($type == 'image') ? 1 : 0);
	
	// make sure PNGs aren't converted to JPG, to retain transparency
	if ($type == 'image') $options['EncoderExtension'] = $extension; // warning: a render error will be generated if a transparent image is not composited 
	
}

// post encode job to Movie Masher Server
if (! $err)
{
	try
	{
		$moviemasher_client->setOptions($options);
		$job_id = $moviemasher_client->post('encode');
	}
	catch(Exception $ex)
	{
		$err = xml_safe($ex->getMessage());
	}
}

if (! $err) $xml = '<moviemasher url="media/php/encoding.php?job=' . $job_id . '&amp;id=' . $id . '" progress="' . 1 . '" status="Posting..." delay="5" />';
else $xml = '<moviemasher progress="-1" status="' .  $err . '" />';

print $xml . "\n\n";
if (! empty($moviemasher_client)) $moviemasher_client->log($xml);

?>