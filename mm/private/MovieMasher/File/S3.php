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

include_once(dirname(dirname(__FILE__)) . '/File.php');
include_once(dirname(dirname(__FILE__)) . '/lib/s3utils.php');


class MovieMasher_File_S3 extends MovieMasher_File
{
	function MovieMasher_File_S3($config = array())
	{
		parent::MovieMasher_File($config);
	}
	function addMeta($path, $key, $value = '')
	{
		$result = FALSE;
		if ($key && $path)
		{
			$access_key_id = $this->getOption('AWSAccessKeyID');
			$secret_access_key = $this->getOption('AWSSecretAccessKey');
			$bucket = $this->getOption('S3Bucket');
			
			if ($bucket && $access_key_id && $secret_access_key) 
			{
				$bucket_path = $bucket . '/' . $path;
				$txt_mime = mime_from_extension('txt');
				$a = array();
				if (is_array($key)) $a = $key;
				else $a[$key] = $value;
				foreach($a as $k => $v)
				{
					
					$info_file_path = meta_file_path($k, $bucket_path);
					$result = ($info_file_path && s3_put_data($access_key_id, $secret_access_key, $info_file_path, $v, $txt_mime));
					if (! $result)
					{
						$this->log($info_file_path . ' ' . $access_key_id . ' ' . $secret_access_key . ' ' . $v . ' ' . $txt_mime);
		
						break;
					}
				}
			}
		}
		return $result;
	}
	function uploadAttributes($file_name, $file_size, $path, $id = '')
	{
		
		$access_key_id = $this->getOption('AWSAccessKeyID');
        $secret_access_key = $this->getOption('AWSSecretAccessKey');
		$bucket = $this->getOption('S3Bucket');
		
		if (! ($bucket && $access_key_id && $secret_access_key)) throw new UnexpectedValueException('Configuration options AWSAccessKeyID, AWSSecretAccessKey, SQSQueueURL, S3Bucket required');
	
		$extension = file_extension($file_name);
		$mime = mime_from_path($file_name);
		if (! ($mime && $extension))  throw new UnexpectedValueException('Could not determine mime type or extension of: ' . $file_name);
		
		if (! $id) $id = unique_id($mime);
		
		$s3_options = array();
		
		
		$s3_options['bucket'] = $bucket;
		$s3_options['AWSAccessKeyId'] = $access_key_id;
		$s3_options['AWSSecretAccessKey'] = $secret_access_key;
		
		$s3_options['uniq_id'] = $id;
			
		$s3_options['path'] = $path . '.' . $extension;
		$s3_options['mime'] = $mime;
		
		$s3data = s3_upload_data($s3_options);
		
		$result = '';
        
		if (! empty($s3data))
		{
			$s3data['mime'] = $mime;
			$s3data['keyid'] = $access_key_id;
			//$s3data['id'] = $id;
			
			foreach($s3data as $k => $v)
			{
				$result .= ' ' . $k . '="' . $v . '"';
				
			}
		}
		return $result;
	}
	function uploadsLocally()
	{
		return FALSE;
	}
	function _populateDefaults()
	{
		parent::_populateDefaults();

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
	function _put($options = array())
	{	
        $access_key_id = $this->getOption('AWSAccessKeyID');
        $secret_access_key = $this->getOption('AWSSecretAccessKey');
		$to_path = (empty($options['path']) ? '' : $options['path']);
		$from_path = (empty($options['url']) ? '' : $options['url']);
		$mime = (empty($options['mime']) ? '' : $options['mime']);
		
		if (! ($access_key_id && $secret_access_key)) throw new UnexpectedValueException('Configuration options AWSAccessKeyID, AWSSecretAccessKey, SQSQueueURL required');
		if (! ($to_path && $from_path)) throw new InvalidArgumentException('Send array with url and path keys');

		if (substr($to_path, 0, 1) == '/') $to_path = substr($options['path'], 1);
		
		if (empty($mime)) $mime = mime_from_path($from_path);
		$result = s3_put_file($access_key_id, $secret_access_key, $to_path, $from_path, $mime);
		if (! $result) throw new RuntimeException('Could not put S3 file: ' . $to_path);
		if ($this->getOption('Verbose')) $this->log("Put S3 file: $to_path");
		
	}
}

?>