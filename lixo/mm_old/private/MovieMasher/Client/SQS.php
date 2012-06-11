<?php
/*
* The contents of this file are subject to the Mozilla Public
* License Version 1.1 (the "License"); you may not use this
* file except in compliance with the License. You may obtain a
* copy of the License at http://www.mozilla.org/MPL/
* 
* Software distributed under the License is distributed on an
* "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express
* or implied. See the License for the specific language
* governing rights and limitations under the License.
* 
* The Original Code is 'Movie Masher'. The Initial Developer
* of the Original Code is Doug Anarino. Portions created by
* Doug Anarino are Copyright (C) 2007-2011 Syntropo.com, Inc.
* All Rights Reserved.
*/
include_once(dirname(dirname(__FILE__)) . '/Client.php');		
include_once(dirname(dirname(__FILE__)) . '/lib/sqsutils.php');

class MovieMasher_Client_SQS extends MovieMasher_Client
{
	function MovieMasher_Client_SQS($config = array())
	{
		parent::MovieMasher_Client($config);	
	}
	function progressesLocally()
	{
		return TRUE;
	}
	function _get($type, $job_id) 
	{
		if (substr($job_id, 0, 4) != 'http')  throw new UnexpectedValueException('Parameter 2 must be a URL: ' . $job_id);
		
		$xml_string = http_get_url($job_id);
		
		// make sure we got a response, log it and parse into SimpleXML object
		if (! $xml_string) throw new RuntimeException('Got no response from: ' . $job_id);
		if (! empty($this->_options['LogResponses'])) $this->log('RECEIVED from ' . $job_id . "\n" . $xml_string);
		$xml = $this->_parseResponse($xml_string);
		
		$progress_tags = $xml->xpath('//Progress');
		// default is error because tags not found
		$progress = -1;
		$tag_count = sizeof($progress_tags);
		$status = 'Progress or PercentDone tags not found in response: ' . $tag_count;
		if ($tag_count > 0)
		{
			$data = $progress_tags[$tag_count - 1];
			
			if (! empty($data->PercentDone)) 
			{
				$progress = (string) $data->PercentDone;
				if (! empty($data->Status)) 
				{
					$status = (string) $data->Status;
				}
			}
		}
		if (! is_numeric($progress)) 
		{
			$progress = 1;
			$status = htmlspecialchars(str_replace('"', "'", $xml_string));
		}
		$result = array('percent' => $progress, 'status' => $status);
		return $result;
	}
	function _populateDefaults()
	{
		parent::_populateDefaults();
		
		$this->_configDefaults['SQSQueueURLSend'] = array(
			'value' => 'URL',
			'description' => "SQS Queue to send messages to.",
			'default' => '',
		);	
		$this->_configDefaults['AWSAccessKeyID'] = array(
			'value' => 'STRING',
			'description' => "AWS Access Key ID",
			'default' => '',
		);
		$this->_configDefaults['AWSSecretAccessKey'] = array(
			'value' => 'STRING',
			'description' => "AWS Secrect Access Key",
			'default' => '',
		);
	}
	function _post($type)
	{
        
        $access_key_id = $this->getOption('AWSAccessKeyID');
        $secret_access_key = $this->getOption('AWSSecretAccessKey');
        $queue_url = $this->_options['SQSQueueURLSend'];
        
        if (! ($access_key_id && $secret_access_key && $queue_url)) throw new UnexpectedValueException('Configuration options AWSAccessKeyID, AWSSecretAccessKey, SQSQueueURLSend required');
		
		$request = $this->_xmlBody($type);
		
		if (! empty($this->_options['LogRequests'])) $this->log('SENDING: to ' . $queue_url . "\n" . $request);
		
		$result = sqs_send_message($access_key_id, $secret_access_key, $queue_url, $request);
		
		if (! $result) throw new RuntimeException('Was not able to send SQS message');
		
		return $result;
	}
}
?>