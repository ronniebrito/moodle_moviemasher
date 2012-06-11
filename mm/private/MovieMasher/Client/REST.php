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
include_once(dirname(dirname(__FILE__)) . '/lib/urlutils.php');		
include_once(dirname(dirname(__FILE__)) . '/lib/cryptutils.php');		

class MovieMasher_Client_REST extends MovieMasher_Client
{	
	function MovieMasher_Client_REST($config = array())
	{
		parent::MovieMasher_Client($config);	
	}	
	function _get($type, $job_id) 
	{
		$rest_endpoint = $this->_options['RESTEndPoint'];
		
		// make sure we have an endpoint to get progress info from
		if (! $rest_endpoint) throw new UnexpectedValueException('Configuration option RestEndPoint required');
		
		// build and get url as xml string
		$url = end_with_slash($rest_endpoint) . 'mm.' . $this->getVersion() . '/rest/' . $type . '/' . $job_id;
		$xml_string = http_get_url($url);
		
		// make sure we got a response, log it and parse into SimpleXML object
		if (! $xml_string) throw new RuntimeException('Got no response from: ' . $url);
		if (! empty($this->_options['LogResponses'])) $this->log('RECEIVED from ' . $url . "\n" . $xml_string);
		$xml = $this->_parseResponse($xml_string);
		
		// default is one in case tags not found, so no error occurs
		$progress = 1;
		$status = 'Progress or PercentDone tags not found in response';
		
		if ((! empty($xml->Progress)) && is_object($xml->Progress))
		{
			$data = $xml->Progress[sizeof($xml->Progress) - 1];
			
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
		$this->_configDefaults['RESTEndPoint'] = array(
			'value' => 'URL',
			'description' => "Location of REST API",
			'default' => '',
		);
		$this->_configDefaults['RESTKeyPrivate'] = array(
			'value' => 'PATH',
			'description' => "Location of private key for signing requests",
			'default' => '',
			'emptyok' => 1,
		);
	}
	function _post($type)
	{
		$result = FALSE;
		$headers = array();
		$rest_endpoint = $this->_options['RESTEndPoint'];
		$rest_key_private = $this->_options['RESTKeyPrivate'];
		$job_id = (empty($this->_options['JobID']) ? '' : $this->_options['JobID']);
		
		// make sure we have an endpoint to post to
		if (! $rest_endpoint) throw new UnexpectedValueException('Configuration option RESTEndPoint required');
		
		// generate the job xml
		$xml_req = $this->_xmlBody($type);
		
		if (! empty($rest_key_private))
		{
			// generate headers with signature
			$gmd = gmdate('D, d M Y H:i:s O');
			$sig = array();
			$params = $this->_jobParameters($type);
			ksort($params);
			foreach($params as $k => $v) 
			{
				$sig[] = "$k=$v";
			}
			$sig = $gmd . join('&', $sig);
			
			$sig = private_signature($rest_key_private, $sig);
			
			if (! $sig) throw new RuntimeException('Could not sign request');
		
			$headers[] = 'X-Moviemasher-Date: ' . $gmd;
			$headers[] = 'Authorization: ' . $sig;
			
		}
		$url = end_with_slash($rest_endpoint) . 'mm.' . $this->getVersion() . '/rest/' . $type . '/';
		
		if (! empty($this->_options['LogRequests'])) $this->log('SENDING REST Request: ' . $xml_req);
		
		$xml_string = http_post_xml($url, $xml_req, $headers);
		
		// make sure we got a response, log it and parse into SimpleXML object
		if (! $xml_string) throw new RuntimeException('Could not post xml to: ' . $url . ' ' . $xml_req);
		if (! empty($this->_options['LogResponses'])) $this->log('RECEIVING REST Response ' . $xml_string);
		$xml = $this->_parseResponse($xml_string);
		
		// determine job ID and return
		if (! empty($xml->JobID)) 
		{
			$result = (string) $xml->JobID;
		}
		else if (! empty($job_id)) $result = $job_id;
		return $result;
	}	
}
?>