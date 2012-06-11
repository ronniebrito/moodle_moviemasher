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

include_once(dirname(__FILE__) . '/MovieMasher.php');
include_once(dirname(__FILE__) . '/Coder/Decoder.php');
include_once(dirname(__FILE__) . '/Coder/Encoder.php');

class MovieMasher_Client extends MovieMasher
{
	
	function MovieMasher_Client($config)
	{
		parent::MovieMasher($config);
	}
	
	function get($type, $job_id) 
	{
		$this->_validateType($type);
		if (! $job_id) throw new InvalidArgumentException('Send job ID as second parameter');

		$result = $this->_get($type, $job_id);
		if ($result['percent'] == -1) throw new RuntimeException($result['status']);
		
		return $result;
	}
	function getCoderOption($name)
	{
		$val = '';
		$kind = '';
		if (substr($name, 0, 5) == 'Coder') $kind = 'Coder';
		elseif (substr($name, 0, 7) == 'Encoder') $kind = 'Coder_Encoder';
		elseif (substr($name, 0, 7) == 'Decoder') $kind = 'Coder_Decoder';
		if ($kind)
		{
			$class_name = 'MovieMasher_' . $kind;
			$val = call_user_func(array($class_name, 'defaultOption'), $name);
		}
		return $val;
	}
	function getOption($k = '')
	{
		$val = parent::getOption($k);
		
		if (empty($val))
		{
			$val = $this->getCoderOption($k);
		}
		return $val;
	}
	function post($type) 
	{
		$this->_validateType($type);
		return $this->_post($type);
	}
	function progressesLocally()
	{
		return FALSE;
	}
	function rendersLocally() 
	{
		return FALSE;
	}
	function _get($type, $job_id) 
	{
		$dir_cache = $this->getOption('DirCache');
		if (! $dir_cache) throw new UnexpectedValueException('Configuration option DirCache required');
		
		
		$path = end_with_slash($dir_cache) . $job_id . '/media.xml';
		
		$raw_xml = file_get($path);
				
		$result = '';
		//$progress = -1;
		$status = 'Progress or PercentDone tags not found in response';
		$progress = 10; // now if there is any problem we set the percent back to one and retry later
			
		if (! $raw_xml) 
		{
			$status = 'Queued';
		}
		else 
		{
			$raw_xml = '<moviemasher>' . $raw_xml . '</moviemasher>';
			$xml = $this->_parseResponse($raw_xml);
			
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
					else 
					{
						$progress = 10;
						$status = 'Status tag empty';
					}
				}
				else $status = 'PercentDone tag empty';
			}
			else $status = 'Progress tag empty'; 
		}
		if (strpos($status, 'empty') !== FALSE) $this->log($status . ' in response: ' . $raw_xml);

		$result = array('percent' => $progress, 'status' => $status);
		return $result;
	}
	function _jobParameters($type)
	{
		$uc_type = ucwords($type) . 'r';
		$type_length = strlen($uc_type);
		
		$file = MovieMasher::fromConfig($this->getOption('PathConfiguration'), 'File');
		
		$a = array();
		
		foreach($this->_options as $k => $v) 
		{
			if ((strlen($k) > 5) && (substr($k, 0, 5) == 'Coder') || (substr($k, 0, $type_length) == $uc_type))
			{
				$a[$k] = $this->getOption($k);
			}
		}
		if ($this->getOption('Verbose')) $a['Verbose'] = '1';
		return $a;
	}
	function _parseResponse($body)
	{
		$result = '';
		$body = trim($body);
		if (! $body) throw new InvalidArgumentException('Send XML string as first argument');
		$xml = @simplexml_load_string($body);
		if ( ! ($xml instanceof SimpleXMLElement)) throw new UnexpectedValueException('Could not parse XML response: ' . $body);
		return $xml;
	}
	function _post($type)
	{
		throw new BadMethodCallException('_post not implemented');
	}
	function _populateDefaults()
	{
		parent::_populateDefaults();
		$this->_configDefaults['LogRequests'] = array(
			'value' => 'BOOLEAN',
			'description' => "Whether or not to add requests we make to the log.",
			'default' => 1,
			'empty_ok' => 1,
		);
		$this->_configDefaults['LogResponses'] = array(
			'value' => 'BOOLEAN',
			'description' => "Whether or not to add responses we receive to the log.",
			'default' => 1,
			'empty_ok' => 1,
		);
	}
	function _validateType($type)
	{
		// make sure $type is either 'encode' or 'decode'
		switch ($type)
		{
			case 'encode':
			case 'decode': break;
			default:
				throw new InvalidArgumentException('Send encode or decode as first parameter');
		}
	}
	function _xmlBody($type)
	{
		$xml_req = MOVIEMASHER_XML_DECLARATION;
		$uc_type = ucwords($type);
		$xml_req .= '<' . $uc_type . '>';
		$params = $this->_jobParameters($type);
		foreach($params as $k => $v) 
		{
			$xml_req .= "\n\t" . '<' . $k . '>' . htmlspecialchars($v, ENT_COMPAT) . '</' . $k . '>';
		}
		$xml_req .= "\n" . '</' . $uc_type . '>';
		return $xml_req;
	}
}

?>