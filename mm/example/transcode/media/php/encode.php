<?php 
/*
This script is called from the CGI control, after uploading file to upload.php.
The media ID is in GET, and the file extension and type have been cached to 'meta' directory.
The script generates an encode job and posts it to Movie Masher Transcoder.
The job ID is passed along with the media ID to encoding.php, by setting the 'url' attribute in response.
If an error is encountered it is displayed in a javascript alert, by setting the 'get' attribute.
If possible, the response to client is logged.
*/

ini_set('display_errors', 1);
error_reporting(E_ALL);

$err = '';
$dir_log = '';

// load utilities
$include = dirname(__FILE__) . '/include/';
if ((! $err) && (! @include_once($include . 'authutils.php'))) $err = 'Problem loading authentication utility script';
if ((! $err) && (! @include_once($include . 'configutils.php'))) $err = 'Problem loading configuration utility script';
if ((! $err) && (! @include_once($include . 'httputils.php'))) $err = 'Problem loading http utility script';
if ((! $err) && (! @include_once($include . 'idutils.php'))) $err = 'Problem loading id utility script';
if ((! $err) && (! @include_once($include . 'logutils.php'))) $err = 'Problem loading log utility script';
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
if (! $err) // pull in other configuration and check for required input
{
	$client = (empty($config['Client']) ? 'REST' : strtoupper($config['Client']));
	$file = (empty($config['File']) ? 'Local' : ucwords($config['File']));
	$dir_host = config_path(empty($config['DirHost']) ? $_SERVER['DOCUMENT_ROOT'] : $config['DirHost']);
	$dir_temporary = config_path(empty($config['DirTemporary']) ? sys_get_temp_dir() : $config['DirTemporary']);
	$host = (empty($config['Host']) ? $_SERVER['HTTP_HOST'] : http_get_contents($config['Host']));
	$host_media = (empty($config['HostMedia']) ? $host : http_get_contents($config['HostMedia']));
	$path_cgi = config_path(empty($config['PathCGI']) ? substr(dirname(__FILE__), strlen($dir_host)) : $config['PathCGI']);
	$path_site = config_path(empty($config['PathSite']) ? config_path(dirname(dirname($path_cgi))) : $config['PathSite']);
	$path_media = config_path(empty($config['PathMedia']) ? config_path(dirname($path_cgi)) . 'user' : $config['PathMedia']);
	$path_media .= auth_userid() . '/';
	$media_dir = (($file == 'Local') ? $dir_host : 'http://' . config_path($host_media)) . $path_media;

	$encoder_audio_bitrate = (empty($config['EncoderAudioBitrate']) ? '128' : $config['EncoderAudioBitrate']);
	$encoder_audio_extension = (empty($config['EncoderAudioExtension']) ? 'mp3' : $config['EncoderAudioExtension']);
	$encoder_audio_filename = (empty($config['EncoderAudioFilename']) ? 'audio' : $config['EncoderAudioFilename']);
	$encoder_audio_frequency = (empty($config['EncoderAudioFrequency']) ? '44100' : $config['EncoderAudioFrequency']);
	$encoder_extension = (empty($config['EncoderExtension']) ? 'jpg' : $config['EncoderExtension']);
	$encoder_image_quality = (empty($config['EncoderImageQuality']) ? '75' : $config['EncoderImageQuality']);
	$encoder_original_filename = (empty($config['EncoderOriginalFilename']) ? 'original' : $config['EncoderOriginalFilename']);
	$encoder_waveform_backcolor = (empty($config['EncoderWaveformBackcolor']) ? 'FFFFFF' : $config['EncoderWaveformBackcolor']);
	$encoder_waveform_dimensions = (empty($config['EncoderWaveformDimensions']) ? '64x2800' : $config['EncoderWaveformDimensions']);
	$encoder_waveform_extension = (empty($config['EncoderWaveformExtension']) ? 'png' : $config['EncoderWaveformExtension']);
	$encoder_waveform_forecolor = (empty($config['EncoderWaveformForecolor']) ? '000000' : $config['EncoderWaveformForecolor']);
	$encoder_waveform_name = (empty($config['EncoderWaveformBasename']) ? 'waveform' : $config['EncoderWaveformBasename']);

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

	// make sure required parameters have been sent
	$id = (empty($_REQUEST['id']) ? '' : $_REQUEST['id']);
	$label = (empty($_REQUEST['label']) ? '' : $_REQUEST['label']);
	$extension = (empty($_REQUEST['extension']) ? '' : $_REQUEST['extension']);
	$type = (empty($_REQUEST['type']) ? '' : $_REQUEST['type']);
	if (! ($id && $label && $extension && $type)) $err = 'Required parameter omitted';
	else if ($type != 'audio') // grab configuration options for visual assets
	{
		$encoder_dimensions = (empty($config['EncoderDimensions']) ? '208x117' : $config['EncoderDimensions']);
		if ($type == 'image') $encoder_fps = 1;
		else $encoder_fps = (empty($config['EncoderFPS']) ? '10' : $config['EncoderFPS']);
	}
}
if (! $err) // all input now in local variables, so create and send job to transcoder
{
	$media_dir .=  $id . '/';
	
	// start XML payload with MovieMasher tag
	$moviemasher_writer = xml_writer('MovieMasher', TRUE);
	
	// start Authentication and Job tags, but actually add to document at end
	$authentication_writer = xml_writer('Authentication');
	$job_writer = xml_writer('Job');

	// set default transfer type and host, for CGI callbacks
	xml_write($job_writer, array('TransferType' => 'http'));
	xml_write($job_writer, array('TransferHost' => $host));
	
	// construct shared transfer data
	$transfer = array('Inherit' => '1', 'ParameterName' => array(), 'ParameterValue' => array());
	
	if ($file == 'Local')
	{
		$transfer['Path'] = $path_cgi . 'encoded.php';
		$transfer['ParameterName'][] = 'id';
		$transfer['ParameterValue'][] = $id;
		$transfer['ParameterName'][] = 'type';
		$transfer['ParameterValue'][] = $type;
		$transfer['ParameterName'][] = 'extension';
		$transfer['ParameterValue'][] = $extension;
		auth_data($transfer);
	}
	else // s3 upload
	{
		
		$transfer['Host'] = $host_media;
		$transfer['Path'] = $path_media . $id . '/{Transfer.File}';
		
		$transfer['SeparateRequests'] = '1'; // one request per file
		$transfer['Method'] = 'put';
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
	// see if an archive is required (only tgz is supported currently)
	if ($file == 'Local') $transfer['ArchiveExtension'] = 'tgz';
	
	xml_write($job_writer, array('Transfer' => $transfer));
	
	// add the uploaded file as the only Input
	$transfer = array('Inherit' => '1', 'Path' => $path_media . $id . '/' . $encoder_original_filename . '.' . $extension, 'Host' => (($file == 'Local') ? $host : $host_media));
	$input = array('Type' => $type, 'Transfer' => $transfer);
	xml_write($job_writer, array('Input' => $input));
	
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
	
	$output['Trigger'] = 'done';
	xml_write($job_writer, array('Output' => $output));

	if ($client == 'SQS') // add output for job progress notifications
	{
		$transfer['Path'] = $path_cgi . 'progress.php';
		$output['Trigger'] = 'progress';
		xml_write($job_writer, array('Output' => $output));
	}

	// add output for type meta data file
	$output = array('Type' => 'text', 'Basename' => 'meta/type', 'Body' => '{Input.Type}');
	xml_write($job_writer, array('Output' => $output));

	// add output for extension meta data file
	$output = array('Type' => 'text', 'Basename' => 'meta/extension', 'Body' => $extension);
	xml_write($job_writer, array('Output' => $output));

	// add output for label meta data file
	$output = array('Type' => 'text', 'Basename' => 'meta/label', 'Body' => $label);
	xml_write($job_writer, array('Output' => $output));
	
	if ($type == 'image')
	{
		// add output for image file
		$output = array('Type' => 'image', 'Basename' => $encoder_dimensions . 'x1/0', 'Dimensions' => $encoder_dimensions, 'Extension' => $extension, 'ImageQuality' => $encoder_image_quality, 'NoAudio' => '1');
		xml_write($job_writer, array('Output' => $output));
	}
	else
	{
		// add output for audio file
		$output = array('Type' => 'audio', 'AudioBitrate' => $encoder_audio_bitrate, 'Basename' => $encoder_audio_filename, 'Extension' => $encoder_audio_extension, 'NoVideo' => '1', 'Frequency' => $encoder_audio_frequency);
		xml_write($job_writer, array('Output' => $output));

		// add output for waveform file
		$output = array('Type' => 'waveform', 'Forecolor' => $encoder_waveform_forecolor, 'Backcolor' => $encoder_waveform_backcolor, 'Basename' => $encoder_waveform_name, 'Dimensions' => $encoder_waveform_dimensions, 'Extension' => $encoder_waveform_extension);
		xml_write($job_writer, array('Output' => $output));
		
		// add output for duration meta data file
		$output = array('Type' => 'text', 'Body' => '{Input.Duration}', 'Basename' => 'meta/duration');
		xml_write($job_writer, array('Output' => $output));

		// add output for audio meta data file
		$output = array('Type' => 'text', 'Basename' => 'meta/audio', 'Body' => '{Input.Audio}');
		xml_write($job_writer, array('Output' => $output));
	}
	if ($type == 'video')
	{
		// add output for sequence files
		$output = array('Type' => 'sequence', 'FPS' => $encoder_fps, 'ImageQuality' => $encoder_image_quality, 'Basename' => $encoder_dimensions . 'x' . $encoder_fps, 'Dimensions' => $encoder_dimensions);
		xml_write($job_writer, array('Output' => $output));
		
	}
	if ($type != 'audio')
	{
		// add output for dimensions meta data file
		$output = array('Type' => 'text', 'Basename' => 'meta/dimensions', 'Body' => '{Input.Dimensions}');
		xml_write($job_writer, array('Output' => $output));
	}

	
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
if (! $err) $xml = '<moviemasher url="media/php/encoding.php?job=' . $job_id . '&amp;id=' . $id . '" progress="1" status="Posting..." delay="5" />';
else $xml = '<moviemasher progress="-1" status="' .  $err . '" />';

print $xml . "\n\n";
if (! empty($log_responses)) log_file($xml, $dir_log);
?>