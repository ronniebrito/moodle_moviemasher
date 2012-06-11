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

include_once('MovieMasher/Daemon.php');
include_once('MovieMasher/lib/urlutils.php');
include_once('MovieMasher/lib/cryptutils.php');
include_once('MovieMasher/lib/idutils.php');
include_once('MovieMasher/lib/dateutils.php');

class MovieMasher_Daemon_REST extends MovieMasher_Daemon
{    
    function MovieMasher_Daemon_REST($options)
    {
		$this->_pauseWhileProcessing = 0;
		parent::MovieMasher_Daemon($options);
	}
	function errorResponse($errors = array(), $extra = array())
	{
		$xml = '';
		$xml .= "\n<Response>";
		$xml .= "\n\t<Errors>";
		$z = sizeof($errors);
		for ($i = 0; $i < $z; $i++)
		{
		
			foreach($errors[$i] as $k => $v)
			{
				$xml .= "\n\t\t<Error>";
				$xml .= "\n\t\t\t<Code>$k</Code>";
				$xml .= "\n\t\t\t<Message>$v</Message>";
				$xml .= "\n\t\t</Error>";
			}
		}
		$xml .= "\n\t</Errors>";
		if ($extra)
		{
			foreach($extra as $k => $v)
			{
				$xml .= "\n\t<$k>$v</$k>";
			}
		}
		$xml .= "\n</Response>";
		return $xml;
	}
	function processRequest($request)
	{
		$result = '';
		
		$method = (empty($request['method']) ? '' : $request['method']); // must be get or post
		
		if (! $method) throw new InvalidArgumentException('Send array with method key for first parameter');
		
		$this->_jobXML = '';
			
		$method = '__' . $method . 'Response';
		$result = $this->$method($request);
		if ($this->_jobXML && $this->_jobID)
		{
			$this->_processJob();
		}
		return $result;
	}
	function _populateDefaults()
	{
		parent::_populateDefaults();
		$this->_configDefaults['AuthKey'] = array(
			'value' => 'PATH',
			'description' => "Public key for authentication of requests.",
			'default' => '',
			'emptyok' => 1,
		);	
		$this->_configDefaults['AuthKeyFormat'] = array(
			'value' => 'STRING',
			'description' => "Format of public key (x509 or ssh-rsa).",
			'default' => 'x509',
			'emptyok' => 1,
		);
		
	}	
	function __authCheck($signature, $data)
	{
		$err = '';
		$auth_key = $this->_options['AuthKey'];
		$auth_key_format = $this->_options['AuthKeyFormat'];
		$key = @file_get_contents($auth_key);
		
		if (! $key) throw new UnexpectedValueException('Could not load file: ' . $auth_key);
	
		switch ($auth_key_format)
		{
			case 'ssh-rsa':
			{
				$key = x509_from_rsa($key);
				if (! $key)
				{
					$err = 'Could not convert RSA to x509';
					break;
				}
				
				// intentional fallthrough to x509
			}
			case 'x509':
			{
				if (! public_verify($data, $signature, $key)) $err = "Error authorizing request";
				break;
			}

			default: $err = 'Unsupported AuthKeyFormat: ' . $auth_key_format;
		}
		if ($err) throw new UnexpectedValueException($err);
	}
    function __getResponse($request)
    {
    	$err = '';
    	$uc_path = 'Get';
    	$response = '';
    	$body = '';
        $split_path = explode('/', $request['path']);
		switch($split_path[0])
		{
			case '':
			{
				// getting count of queued jobs
				
				$count = sizeof(files_in_dir($this->_options['DirJobsQueued']));
				
				$response = "\t" . '<QueuedJobs>' . $count . '</QueuedJobs>';
				break;
			}
			case 'encode':
			case 'decode':
			{
				if (sizeof($split_path) == 2)
				{
					if ($this->_options['DirCache'])
					{
						$uc_path = ucwords($split_path[0]);
						$progress_path = $this->_options['DirCache'] . $split_path[1] . '/media.xml';
						if (file_exists($progress_path))
						{
							$response = file_get_contents($progress_path);
						}					
						else $err = $uc_path . ' job ' . $split_path[1] . ' not found in ' . $this->_options['DirCache'];
					}
					else $err = 'DirCache was not defined';
					break;
				}
				else
				{
					// we could get count of each particular type of job here
				}
				
				// intentional fallthrough to not found!
			}
		
			default: $err = $request['path'] . ' not found';
       	}
       	if ($err) $body .= $this->errorResponse(array(array('NotFound' => $err))); 		
      	else if ($response)
      	{
     	 	$body .= "\n" . '<' . $uc_path . 'Response>';
			$body .= "\n" . $response;
			$body .= "\n\t" . '<Date>' . http_date_string() . '</Date>';
			$body .= "\n" . '</' . $uc_path . 'Response>';
      	}
      	
       	return $body;
    }
	function __postResponse($request)
	{
	    $body = '';
	    switch($request['path'])
	    {
	    	case 'encode':
	    	case 'decode':
	    	{
	    		$xml_str = $request['data'];
	    		$auth_key = $this->_options['AuthKey'];
	    		if (! empty($auth_key)) 
				{	
					if (empty($request['headers']) || empty($request['headers']['X-Moviemasher-Date']) || empty($request['headers']['Authorization'])) 
					{
						throw new BadFunctionCallException('X-Moviemasher-Date and Authorization headers required');
					}
	    		}
	    		$xml_ob = @simplexml_load_string($xml_str);
	    		if (! $xml_ob) throw new BadFunctionCallException('Could not parse XML request');
	    		
					
				if (! empty($auth_key)) 
				{	
					$sig = array();
					$gmd = $request['headers']['X-Moviemasher-Date'];
					$kids = $xml_ob->children();
					$z = sizeof($kids);
					for ($i = 0; $i < $z; $i++) $sig[$kids[$i]->getName()] = (string) $kids[$i];
					ksort($sig);
					$sigs = array();
					foreach($sig as $k => $v)
					{
						$sigs[] = $k . '=' . $v;
					}
					$sig = $gmd . join('&', $sigs);
					
					$this->__authCheck(($request['headers']['Authorization']), $sig);
					
				}
	    		$this->_validateJob($xml_ob);
	    		$uc_path = ucwords($request['path']);
					
				$this->_jobXML = $xml_ob;
				$this->_jobID = (string) $this->_jobXML->JobID;
				if (empty($this->_jobID)) $this->_jobID = unique_id('jobid');
				
				$body .= "\n" . '<' . $uc_path . 'Response>';
				$body .= "\n\t" . '<JobID>' . $this->_jobID . '</JobID>';
				$body .= "\n\t" . '<Date>' . http_date_string() . '</Date>';
				$body .= "\n" . '</' . $uc_path . 'Response>';
				break;	
	    	}
	   		default:throw new BadFunctionCallException('Path not found: ' . $request['path']);
	    }
	    
		return $body;
		
	}
}

?>