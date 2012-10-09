<?php 
/*
This script is called directly from Movie Masher Applet, in response to a click on the Render button.
The XML formatted mash data has already been saved to PathMedia/{auth_userid()}/$id.xml
The script then generates a decode job XML payload and posts it to Movie Masher Server.
The job ID is passed to decoding.php, by setting the 'url' attribute in response.
If an error is encountered it is displayed in a javascript alert, by setting the 'get' attribute.
If possible and options permit, responses and requests are logged.
*/
ini_set('display_errors', 1);
error_reporting(E_ALL);

$err = '';
$dir_log = '';

// load utilities
$include = dirname(__FILE__) . '/include/';
if ((! $err) && (! @include_once($include . 'authutils.php'))) $err = 'Problem loading authentication utility script';
if ((! $err) && (! @include_once($include . 'configutils.php'))) $err = 'Problem loading configuration utility script';
if ((! $err) && (! @include_once($include . 'fileutils.php'))) $err = 'Problem loading file utility script';
if ((! $err) && (! @include_once($include . 'httputils.php'))) $err = 'Problem loading http utility script';
if ((! $err) && (! @include_once($include . 'idutils.php'))) $err = 'Problem loading id utility script';
if ((! $err) && (! @include_once($include . 'logutils.php'))) $err = 'Problem loading log utility script';
if ((! $err) && (! @include_once($include . 'mashutils.php'))) $err = 'Problem loading log utility script';
if ((! $err) && (! @include_once($include . 'sigutils.php'))) $err = 'Problem loading sig utility script';
if ((! $err) && (! @include_once($include . 'xmlutils.php'))) $err = 'Problem loading xml utility script';

if (! $err) // pull in configuration so we can log other errors
{
	$config = config_get();
	$dir_log = config_path(empty($config['DirLog']) ? '' : $config['DirLog']);
	$err = config_error($config);
}
if (! $err) // see if the user is autheticated (does not redirect or exit)
{
	if (! auth_ok()) $err = 'Unauthenticated access';
}
if (! $err) // read configuration (best to ignore this and set options in private/moviemasher.ini)
{
	$client = (empty($config['Client']) ? 'REST' : strtoupper($config['Client']));
	$file = (empty($config['File']) ? 'Local' : ucwords($config['File']));
	$dir_temporary = config_path(empty($config['DirTemporary']) ? sys_get_temp_dir() : $config['DirTemporary']);
	$dir_host = config_path(empty($config['DirHost']) ? $_SERVER['DOCUMENT_ROOT'] : $config['DirHost']);
	$dir_log = config_path(empty($config['DirLog']) ? '' : $config['DirLog']);
	$host = (empty($config['Host']) ? $_SERVER['HTTP_HOST'] : http_get_contents($config['Host']));
	$host_media = (empty($config['HostMedia']) ? $host : http_get_contents($config['HostMedia']));
	$path_cgi = config_path(empty($config['PathCGI']) ? substr(dirname(__FILE__), strlen($dir_host)) : $config['PathCGI']);
	$path_site = config_path(empty($config['PathSite']) ? config_path(dirname(dirname($path_cgi))) : $config['PathSite']);
	$path_media = config_path(empty($config['PathMedia']) ? config_path(dirname($path_cgi)) . 'user' : $config['PathMedia']);
	$path_media .= auth_userid() . '/';
	$media_dir = (($file == 'Local') ? $dir_host : 'http://' . config_path($host_media)) . $path_media;

	$decoder_extension = (empty($config['DecoderExtension']) ? 'flv' : $config['DecoderExtension']);
	$decoder_switches = (empty($config['DecoderSwitches']) ? '' : $config['DecoderSwitches']);
	$decoder_metatitle = (empty($config['DecoderMetatitle']) ? '' : $config['DecoderMetatitle']);

	if (($client == 'SQS') || ($file == 'S3'))
	{
		$access_key_id =  (empty($config['AWSAccessKeyID']) ? '' : $config['AWSAccessKeyID']);
		$secret_access_key =  (empty($config['AWSSecretAccessKey']) ? '' : $config['AWSSecretAccessKey']);
		if ($file == 'S3') $s3_bucket = (empty($config['S3Bucket']) ? '' : $config['S3Bucket']);
		if ($client == 'SQS') $queue_url =  (empty($config['SQSQueueURLSend']) ? '' : $config['SQSQueueURLSend']);
	}
	if ($client == 'REST') $rest_endpoint = config_path(empty($config['RESTEndPoint']) ? '' : $config['RESTEndPoint']);
	$keypair_private = (empty($config['KeypairPrivate']) ? '' : $config['KeypairPrivate']);

	$verbose = (empty($config['Verbose']) ? '' : $config['Verbose']);
	$log_requests = (empty($config['LogRequests']) ? '' : $config['LogRequests']);
	$log_responses = (empty($config['LogResponses']) ? '' : $config['LogResponses']);
	$log_transcoder_requests = (empty($config['LogTranscoderRequests']) ? '' : $config['LogTranscoderRequests']);
	$log_transcoder_responses = (empty($config['LogTranscoderResponses']) ? '' : $config['LogTranscoderResponses']);
	if ($log_requests) log_file($_SERVER['QUERY_STRING'], $dir_log);

	$id = (empty($_REQUEST['id']) ? '' : $_REQUEST['id']);
	if (! $id ) $err = 'Parameter id required';
	$media_dir .=  $id . '/';
}
if (! $err) // try to read in mash XML file
{
	$mash_xml_path = $path_media . $id . '.xml';
	$mash_string = file_get($dir_host . $mash_xml_path);
	if (! $mash_string) $err = 'Could not read mash xml file';
}
if (! $err) // try to parse mash XML
{
	$mash_xml = xml_from_string($mash_string);
	if (! $mash_xml) $err = 'Could not parse mash xml file';
}
if (! $err) // try to analyze mash and read configuration based existence of tracks (audio, video or both)
{
	$type = 'video';
	$has_audio = TRUE;
	$mash_info = mash_info($mash_xml);
	$label = $mash_info['label'];
	if ($mash_info['has_video'])
	{
		$has_audio = $mash_info['has_audio'];
		$decoder_image_quality = (empty($config['DecoderImageQuality']) ? '100' : $config['DecoderImageQuality']);
		$decoder_video_codec = (empty($config['DecoderVideoCodec']) ? 'libx264' : $config['DecoderVideoCodec']);
		$decoder_dimensions = (empty($config['DecoderDimensions']) ? '480x270' : $config['DecoderDimensions']);
		$decoder_fps = (empty($config['DecoderFPS']) ? '30' : $config['DecoderFPS']);
	}
	else // just audio clips in mash, so change type and extension
	{
		$type = 'audio';
		$decoder_extension = (empty($config['DecoderAudioExtension']) ? 'mp3' : $config['DecoderAudioExtension']);
	}
	if ($has_audio)
	{
		$decoder_audio_codec = (empty($config['DecoderAudioCodec']) ? 'libfaac' : $config['DecoderAudioCodec']);
		$decoder_audio_frequency = (empty($config['DecoderAudioFrequency']) ? '44100' : $config['DecoderAudioFrequency']);
		$decoder_audio_bitrate = (empty($config['DecoderAudioBitrate']) ? '128' : $config['DecoderAudioBitrate']);
	}
	$err = $mash_info['error'];
}
if (! $err) // all input now in local variables, so create and send job to transcoder
{
	// start XML payload with MovieMasher tag
	$moviemasher_writer = xml_writer('MovieMasher', TRUE);
	
	// start Authentication and Job tags, but actually add to document at end
	$authentication_writer = xml_writer('Authentication');
	$job_writer = xml_writer('Job');
	
	// construct shared transfer data
	$transfer = array('Host' => $host, 'Type' => 'http', 'ParameterName' => array('id'), 'ParameterValue' => array($id));
	auth_data($transfer); // adds what is needed to authenticate callback
	
	// construct text output shared by notification callbacks
	$progress = array('PercentDone' => '{Job.Progress}', 'Status' => '{Job.Status}');
	$body = array('Response' => array('Progress' => $progress));
	$error_body = array('Response' => array('ErrorLog' => '{Job.Error}', 'CommandLog' => '{Job.Commands}', 'VerboseLog' => '{Job.Verbose}'));
	$output = array('Type' => 'text', 'Payload' => '1', 'Body' => $body, 'Transfer' => &$transfer);
		
	// add output for job error abort notification
	$transfer['Path'] = $path_cgi . 'error.php';
	$output['Trigger'] = 'error';
	$output['Body'] = $error_body;
	xml_write($job_writer, array('Output' => $output));
	$output['Body'] = $body;
	
	// add output for job successful done notification
	$transfer['Path'] = $path_cgi . 'addmedia.php';
	
	// addmedia.php needs job id to determine rendered file name
	$transfer['ParameterName'][] = 'job';
	$transfer['ParameterValue'][] = '{Job.ID}';
	
	$output['Trigger'] = 'done';
	xml_write($job_writer, array('Output' => $output));

	if ($client == 'SQS') // add output for job progress notifications
	{
		$transfer['Path'] = $path_cgi . 'progress.php';
		
		$output['Trigger'] = 'progress';
		xml_write($job_writer, array('Output' => $output));
	}
	

	// add transfer main output and any others that don't have one
	if ($file == 'Local')
	{
		// we can just use the default callback transfer with different path
		$transfer['Path'] = $path_cgi . 'decoded.php';
	}
	else // s3 needs its own transfer
	{
		$transfer = array('Host' => $host_media, 'Path' => $path_media . $id . '/{Transfer.File}', 'Method' => 'put', 'Type' => 'http', 'SeparateRequests' => '1');
		$transfer['HeaderName'] = array('Authorization', 'x-amz-acl', 'Content-Type', 'Content-MD5', 'Date');
		$transfer['HeaderValue'] = array('AWS {AccessKey.Identifier}:{Transfer.Signature}', 'public-read', '{Transfer.Mime}', '{Transfer.MD5}', '{Transfer.Date}');
		
		$value = array('{Transfer.MD5}', '{Transfer.Mime}', '{Transfer.Date}');
		$value[] = 'x-amz-acl:public-read';
		// this does the same thing as preceeding line, but for ALL x-amz-* headers added above
		// $value[] = array('KeyJoin' => array('Value' => ':', 'KeySort' => array('KeyLowerCase' => array('MatchPairs' => '^x-amz-'))));
		$value[] = '/' . $s3_bucket . '/{Transfer.Path}';
		
		$join = array('NewLine' => '', 'UpperCase' => '{Transfer.Method}', 'Value' => $value);
		$hmac = array('Join' => $join, 'Value' => '{AccessKey.Secret}');
		$transfer['Signature'] = array('Base64Encode' => array('HMACSHA1' => $hmac));
	}
	xml_write($job_writer, array('Transfer' => $transfer));
	
	// add Input for mash data, with its own Transfer
	$transfer = array('Host' => $host, 'Path' => $path_site . '{Transfer.File}', 'method' => 'get', 'Type' => 'http');
	$input = array('Type' => 'mash', 'Body' => $mash_string, 'Transfer' => $transfer);
	xml_write($job_writer, array('Input' => $input));
	
	// add Output for rendered video or audio file, with no transfer tag of its own
	$output = array('Type' => $type, 'Basename' => '{Job.ID}', 'Extension' => $decoder_extension, 'Switches' => $decoder_switches);
	if ($decoder_metatitle && $label) $output['Switches'] .= ' -metadata ' . $decoder_metatitle . '="' . $label . '"';

	if ($type == 'video')
	{
		$output['VideoCodec'] = $decoder_video_codec;
		$output['FPS'] = $decoder_fps;
		$output['ImageQuality'] = $decoder_image_quality;
		$output['Dimensions'] = $decoder_dimensions;
	}
	else // type = audio
	{
		$output['NoVideo'] = '1';
	}
	if ($has_audio)
	{
		$output['AudioCodec'] = $decoder_audio_codec;
		$output['AudioBitrate'] = $decoder_audio_bitrate;
		$output['Frequency'] = $decoder_audio_frequency;
	}
	else $output['NoAudio'] = '1';
		
	xml_write($job_writer, array('Output' => $output));

	// debug option will add Verbose output to the transcoder's log file
	$job_writer->writeElement('Verbose', $verbose);
	
	
	$job_writer->endElement(); // Job

	$job_xml_string = $job_writer->outputMemory();
	$authentication_xml_string = '';
	if ((! empty($keypair_private)) || (! empty($access_key_id)))
	{
		$nonce = id_unique();
		$gmd = gmdate(DATE_FORMAT_OFFSET);
		$authentication_writer->writeElement('Nonce', $nonce);
		$authentication_writer->writeElement('Date', $gmd);
		if ($keypair_private)
		{
			$authentication_writer->writeElement('Name', 'KeyPair');
		}
		else 
		{
			$authentication_writer->writeElement('Identifier', $access_key_id);
			$authentication_writer->writeElement('Name', 'AccessKey');
		}
		
		$authentication_writer->endElement(); // Authentication	
		$authentication_xml_string = $authentication_writer->outputMemory(); 
		$sig = sig_for_xml_string($authentication_xml_string);
		$sig .= "\n" . sig_for_xml_string($job_xml_string);
		
		if ($keypair_private) $sig = sig_private_key($keypair_private, $sig);
		else $sig = sig_base_hmac($secret_access_key, $sig);
		//if (! $sig) $err = 'Could not sign request';
	}
	if ($authentication_xml_string) 
	{
		$moviemasher_writer->writeElement('Signature', $sig);
		$moviemasher_writer->writeRaw($authentication_xml_string);
	}
	$moviemasher_writer->writeRaw($job_xml_string);
	$moviemasher_writer->endElement(); // MovieMasher
	$job_string = $moviemasher_writer->outputMemory();
	
}
/* uncomment the block below to log job XML for testing, while not posting it to transcoder
if (! $err) // testing
{
	log_file(xml_pretty($job_string), $dir_log);
	$err = 'Testing - check log for request that would have been made';
}
 */
if (! $err) // request is all signed, go ahead and make it
{
	$job_id = '';
	// post decode job to Movie Masher Server
	if ($log_transcoder_requests) log_file("Client $client request:\n" . $job_string, $dir_log);

	if ($client == 'SQS')
	{
		$variables = array();
		$variables['Action'] = 'SendMessage';
		$variables['MessageBody'] = $job_string;
		$variables['Version'] = '2011-10-01';
		// the following are required for non-public queues
		$variables['AWSAccessKeyId'] = $access_key_id;
		$variables['Timestamp'] = gmdate('Y-m-d\TH:i:s\Z');
		$variables['SignatureVersion'] = '2';
		$variables['SignatureMethod'] = 'HmacSHA256';
		$variables['Signature'] = sig_version_two($secret_access_key, $queue_url, $variables, 'post');
		
		$post_result = http_send($queue_url, $variables);
		
		$xml_string = $post_result['result'];
		if ($xml_string && $log_transcoder_responses) log_file("Client SQS response:\n" . $xml_string, $dir_log);
		if ($post_result['error']) $err = 'Could not make SQS request ' . $queue_url . ' ' . $post_result['error'];
		else if (! $xml_string) $err = 'Got no response from SQS request';
		else
		{
			log_file("Client SQS response:\n" . $xml_string, $dir_log);
			$xml = xml_from_string($xml_string);
			if (! is_object($xml)) $err = 'Could not parse SQS response';
			else if (sizeof($xml->Error)) $err = 'Got error in SQS response';
			else $job_id = (string) $xml->SendMessageResult->MessageId;
			if ($job_id)
			{
				$xml_string = '';
				$xml_string .= "<Response>\n\t<Progress>\n";
				$xml_string .= "\t\t" . '<PercentDone>2</PercentDone>' . "\n";
				$xml_string .= "\t\t" . '<Status>Queued</Status>' . "\n";
				$xml_string .= "\t</Progress>\n</Response>\n";
				if (! file_put($dir_temporary . $id . '.xml', $xml_string)) $err = 'Could not write progress file';
			}
		}
	}
	else // REST
	{
		$post_result = http_send($rest_endpoint, $job_string);
		$xml_string = $post_result['result'];
		if ($xml_string && $log_transcoder_responses) log_file("Client REST response:\n" . $xml_string, $dir_log);
		
		// make sure we got a response, log it and parse into SimpleXML object
		if (! $xml_string) $err = 'Got no response from REST request';
		else
		{
			$xml = xml_from_string($xml_string);
			if (! is_object($xml)) $err = 'Could not parse REST response';
			else if (sizeof($xml->Error)) 
			{
				if (! $log_transcoder_responses) log_file("Client REST response:\n" . $xml_string, $dir_log);
				$err = 'Got error in REST response, check log';
			}
			else if ($post_result['error']) $err = 'Could not make REST request ' . $post_result['error'];
			else
			{
				$id_tags = $xml->xpath('//JobID');
				if (sizeof($id_tags)) $job_id = (string) $id_tags[0];
			}
		}
	}
	if ((! $err) && (! $job_id)) $err = 'Got no Job ID';

}

if (! $err) $xml = '<moviemasher url="media/php/decoding.php?id=' . $id . '&amp;job=' . $job_id . '" progress="2" status="Decoding..." delay="5" />';
else $xml = '<moviemasher progress="100" status="" get=\'javascript:alert("' .  $err . '");\' />';

print $xml . "\n\n";
if (! empty($log_responses)) log_file($xml, $dir_log);

?>