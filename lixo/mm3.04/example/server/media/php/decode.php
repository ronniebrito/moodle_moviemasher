<?php
/*
This script is called directly from Movie Masher Applet, in response to a click on the Render button.
The XML formatted mash data is posted, and is guaranteed to be longer than zero seconds.
The script saves out a copy of the mash (file must permit writing by web process):
	/media/user/{authenticated_userid()}/$id.xml - read by Movie Masher Applet and Server
The script then generates a decode job and posts it to Movie Masher Server.
The job ID is passed to decoding.php, by setting the 'url' attribute in response.
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
		$moviemasher_file =& MovieMasher::fromConfig('MovieMasher.xml', 'File');
		$moviemasher_coder =& MovieMasher::fromConfig('MovieMasher.xml', 'Coder', 'Decoder');
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

// check to make sure required parameters have been sent
if (! $err)
{
	$id = (empty($_REQUEST['id']) ? '' : $_REQUEST['id']);
	if (! $id ) $err = 'Parameter id required';
}

// make sure required configuration options have been set
if (! $err)
{
	$decoder_extension = $moviemasher_client->getOption('DecoderExtension');
	$dir_host = $moviemasher_client->getOption('DirHost');
	if (! ($decoder_extension && $dir_host)) $err = 'Configuration options DecoderExtension, DirHost required';
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
		if (! ($host )) $err = 'Configuration option Host or HostLocal required';
		$media_dir = $dir_host;
	}
	else
	{
		$media_dir = 'http://' . $moviemasher_file->getOption('HostMedia') . '/';
	}
}

// build media path and save out extension for use in done.php
if (! $err)
{
	$mash_media_id = unique_id('mash');
	$path_site = $moviemasher_client->getOption('PathSite');
	$path_media = $moviemasher_client->getOption('PathMedia');
	$path_media .=  authenticated_userid() . '/';
	$media_dir .=  $path_media . $mash_media_id . '/';
	$path_cgi = $moviemasher_client->getOption('PathCGI');
	$path_xml = $moviemasher_client->getOption('PathXML');
	$mash_xml_path = $path_media . $id . '.xml';
	$mash_string = @file_get_contents($dir_host . $mash_xml_path);
	if (! $mash_string) $err = 'Could not read mash xml file: ' . $dir_host . $mash_xml_path;
	else
	{
		$mash_xml = @simplexml_load_string($mash_string);
		if (! $mash_xml) $err = 'Could not parse mash xml file: ' . $dir_host . $mash_xml_path;
		else 
		{
			$type = 'video';
			$mash_info = MovieMasher_Coder_Decoder::mashInfo($mash_xml);
			if (! $mash_info['has_video'])
			{
				// just audio clips in mash, so change output extension
				$decoder_extension = $moviemasher_client->getOption('EncoderAudioExtension');
				$type = 'audio';
			}
			
			$label = (string) $mash_xml->mash[0]['label'];
			if (! $label) $label = 'Untitled Mash';
			
			$meta = array();
			$meta['label'] = $label;
			$meta['extension'] = $decoder_extension;
			$meta['type'] = $type;
			if ($moviemasher_client->progressesLocally())
			{
				$xml_string = '';
				$xml_string .= '<Progress>' . "\n";
				$xml_string .= "\t" . '<PercentDone>4</PercentDone>' . "\n";
				$xml_string .= "\t" . '<Date>' . http_date_string() . '</Date>' . "\n";
				$xml_string .= "\t" . '<Status>Queued</Status>' . "\n";
				$xml_string .= '</Progress>' . "\n";
				
				$meta['progress'] = $xml_string;
			}
			
			$meta_path = $path_media . $mash_media_id . '/';
			if ($uploads_locally) $meta_path = $dir_host . $meta_path;
			if (! $moviemasher_file->addMeta($meta_path, $meta)) $err = 'Problem saving mash meta data: ' . $meta_path;
		}
	}
}

// create and post decode job to Movie Masher Server
if (! $err)
{
	// this example uses HTTP authentication, replace with session_name() and session_id() if using sessions
	$user_pass = $_SERVER['PHP_AUTH_USER'] . ':' . $_SERVER['PHP_AUTH_PW'] . '@';	

	$options = array();
	
	$options['DecoderExtension'] = $decoder_extension;
	
	
	// CoderFileURL
	$options['CoderFileURL'] = strtolower($moviemasher_client->getOption('File')) . '://';
	$coder_filename = $moviemasher_coder->getOption('CoderFilename');
	
	if ($uploads_locally)  // all but S3
	{
		if (! $renders_locally) $options['CoderFileURL'] .= $user_pass . $host . '/' . $path_cgi . 'decoded.php?id=' . $mash_media_id;
		else $options['CoderFileURL'] .= $path_media . $mash_media_id . '/' . $coder_filename . '.' . $decoder_extension;		
	}
	else 
	{
		// TODO: Change name of S3Bucket
		$bucket_path = $moviemasher_client->getOption('S3Bucket') . '/' . $path_media;
		$options['CoderFileURL'] .= $bucket_path . $mash_media_id . '/' . $coder_filename . '.' . $decoder_extension;
		
	}

	if ($moviemasher_client->progressesLocally())
	{
		$options['CoderProgressURL'] = 'http://' . $user_pass . $host . '/' . $path_cgi . 'progress.php?id=' . $mash_media_id;
	}
	

	$options['CoderDoneURL'] = 'http://' . $user_pass . $host . '/' . $path_cgi . 'done.php?id=' . $mash_media_id;
	$options['CoderErrorURL'] = 'http://' . $user_pass . $host . '/' . $path_cgi . 'error.php?id=' . $mash_media_id;
	
	// absolute URLs to mash, policy file, applet and base path
	$options['DecoderConfigURL'] = 'http://' . $host . '/' . $mash_xml_path;
	$options['DecoderPolicyURL'] = 'http://' . $host . '/' . 'crossdomain.xml';
	$options['DecoderAppletURL'] = 'http://' . $host . '/' . 'moviemasher/moviemasher/com/moviemasher/core/MovieMasher/stable.swf';
	$options['CoderBaseURL'] = 'http://' . $host . '/' . substr($path_site, 0, -1);

	// set options, post, and retrieve job id
	try
	{
		$moviemasher_client->setOptions($options);
		$job_id = $moviemasher_client->post('decode');
	}
	catch(Exception $ex)
	{
		$err = xml_safe($ex->getMessage());
	}
}

if (! $err) $xml = '<moviemasher url="media/php/decoding.php?id=' . $mash_media_id . '&amp;job=' . $job_id . '" progress="2" status="Decoding..." delay="5" />';
else $xml = '<moviemasher progress="100" status="" get=\'javascript:alert("' .  $err . '");\' />';

print $xml . "\n\n";
if (! empty($moviemasher_client)) $moviemasher_client->log($xml);

?>