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
include_once(dirname(__FILE__) . '/lib/mimeutils.php');

class MovieMasher_File extends MovieMasher
{
	function MovieMasher_File($config)
	{
		parent::MovieMasher($config);
		
		
	}
	function addMeta($path, $key, $value = '')
	{
		return set_file_info($path, $key, $value);
	}
	function fileError($file_name, $file_size)
	{
		$err = '';
		
		if (! ($file_name && $file_size)) $err = ('Both filename and size are required: : ' . $file_name . ', ' . $file_size);
		if (! $err)
		{
			$mime = mime_from_path($file_name);
			if (! $mime) $err = ('Could not determine mime type of file: ' . $file_name);
		}
		if (! $err)
		{
		
			$type = type_from_mime($mime);
			switch($type)
			{
				case 'audio':
				case 'video':
				case 'image':
					break;
				default:
					 $err = ('Only audio, image and video files are supported: ' . $type);
			}
		
		}
		if (! $err)
		{
		
			$uc_type = ucwords($type);
			$max = $this->getOption('File' . $uc_type . 'MaxSize');
				
			if ($max)
			{
				$file_megs = round($file_size / (1024 * 1024));
				if ($file_megs > $max) $err = ($uc_type . ' files must be less than ' . $max . ' meg');
				
			}
		}
		return $err;
	}
	static function files($full_path)
	{
		$files = array();
		if (is_dir($full_path)) 
		{
			if ($dh = opendir($full_path)) 
			{
				if (substr($full_path, -1) != '/') $full_path .= '/';
				while (($file = readdir($dh)) !== false) 
				{
					if (substr($file, 0, 1) != '.')
					{
						$files = array_merge($files, MovieMasher_File::files($full_path . $file));
					}
				}
				closedir($dh);
			}
		}
		else $files[] = $full_path;
		return $files;
	}
	function jobParameters()
	{
		$a = array();
		return $a;
	}
	function put($options = array())
	{
		
		$result = FALSE;
		$url = (empty($options['url']) ? '' : $options['url']); 
		$path = (empty($options['path']) ? '' : $options['path']); 
		if (! ($url && $path)) throw new InvalidArgumentException('Send array with url and path keys as first argument');
		
		$ignore = (empty($options['ignore']) ? array() : $options['ignore']);
		$is_folder = is_dir($url);
		$urls = array();
		
		if ($is_folder)
		{
			$path = end_with_slash($path);
			$urls = MovieMasher_File::files($url);
		}
		else $urls[] = $url;
		
		$z = sizeof($urls);
		
		//if ($this->getOption('Verbose')) $this->log(__METHOD__ . ' putting ' . $z . ' file' . (($z == 1) ? '' : 's') . ': ' . join("\n", $urls));
		$errors = 0;
		
		// TODO: these could be config options
		$max_errors = 3; 
		$wait_seconds = 30;
		for ($i = 0; $i < $z; $i++)
		{
			$options['url'] = $urls[$i];
			if (in_array($options['url'], $ignore)) continue;
			if ($is_folder) $options['path'] = $path . substr($options['url'], strlen(end_with_slash($url)));
			try
			{
				$this->_put($options);
				$errors = 0; // one success resets error and result
				$result = TRUE;
			}
			catch(Exception $ex)
			{
				$result = FALSE;
				$errors++;
				if ($errors > $max_errors) throw $ex;
				$i--;
				$this->log(__METHOD__ . ' waiting ' . $wait_seconds . ' seconds after error ' . $errors . ': ' . $ex->getMessage());
				sleep($wait_seconds);
			}
		}
	
		return $result;
	}
	function uploadAttributes($file_name, $file_size, $file_basename, $id = '')
	{
		return '';
	}
	function uploadedFile()
	{
		$result = FALSE;
		if (!  empty($_FILES))
		{
			// make sure first item in $_FILES is valid
			foreach($_FILES as $k => $v)
			{
				$file = $_FILES[$k];
				break;
			}
			if ($file && empty($file['error']) && is_uploaded_file($file['tmp_name']))
			{
				$result = $file;
			}	
		}
		return $result;
	}
	function uploadsLocally()
	{
		return TRUE;
	}
	function _populateDefaults()
	{
		parent::_populateDefaults();

		$this->_configDefaults['FileAudioMaxSize'] = array(
			'value' => 'MEG',
			'description' => "Maximum Size of uploaded audio Files, in megabytes.",
			'default' => '0',
			'emptyok' => 1,
		);
		$this->_configDefaults['FileVideoMaxSize'] = array(
			'value' => 'MEG',
			'description' => "Maximum Size of uploaded video Files, in megabytes.",
			'default' => '0',
			'emptyok' => 1,
		);
		$this->_configDefaults['FileImageMaxSize'] = array(
			'value' => 'MEG',
			'description' => "Maximum Size of uploaded image Files, in megabytes.",
			'default' => '0',
			'emptyok' => 1,
		);
	}
	function _put($options = array())
	{
		throw new BadMethodCallException('_put not implemented');
	}
}
?>