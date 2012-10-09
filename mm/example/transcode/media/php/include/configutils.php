<?php

function config_get()
{
	$config = @parse_ini_file('moviemasher.ini');
	if (! $config) $config = array();
	return $config;
}

function config_error($config)
{
	$err = '';
	if ($config === FALSE) $err = 'Could not find moviemasher.ini - make sure its parent directory is in include_path';
	if (! $err)
	{
		$client = (empty($config['Client']) ? 'REST' : strtoupper($config['Client']));
		$file = (empty($config['File']) ? 'Local' : ucwords($config['File']));
		$check_aws = FALSE;
		switch($file)
		{
			case 'Local':
			{
				break;
			}
			case 'S3':
			{
				if (empty($config['S3Bucket'])) $err = 'Configuration option S3Bucket required';
				else $check_aws = TRUE;
				break;
			}
			default: 
			{
				$err = 'Unsupported File configuration ' . $file;
			}
		}
		switch($client)
		{
			case 'REST':
			{
				if (empty($config['RESTEndPoint']))
				{
					$err = 'Configuration option RESTEndPoint required';
				}
				else if (substr($config['RESTEndPoint'], 0, 4) != 'http') 
				{
					$err = 'Configuration option RESTEndPoint must have http prefix';
				}
				else if (empty($config['KeypairPrivate']))
				{
					$check_aws = TRUE;
					$err = 'Configuration option KeypairPrivate or both AWSAccessKeyID and AWSSecretAccessKey required';
				}
				break;
			}
			case 'SQS':
			{
				if (empty($config['SQSQueueURLSend'])) $err = 'Configuration option SQSQueueURLSend required';
				else $check_aws = TRUE;
				break;
			}
			default: 
			{
				$err = 'Unsupported Client configuration ' . $client;
			}
		}
		if ($check_aws)
		{
			if (empty($config['AWSAccessKeyID']) || empty($config['AWSSecretAccessKey']))
			{
				if (! $err) $err = 'Configuration options AWSAccessKeyID, AWSSecretAccessKey required';
			}
			else $err = '';
		}
	}
	return $err;
}
function config_path($input, $char = '/')
{
	if ($input && (substr($input, - strlen($char)) != $char)) $input .= $char;
	return $input;
}
?>