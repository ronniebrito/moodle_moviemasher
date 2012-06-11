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
include_once(dirname(__FILE__) . '/lib/dateutils.php');
include_once(dirname(__FILE__) . '/lib/idutils.php');
include_once(dirname(__FILE__) . '/lib/xmlutils.php');
include_once(dirname(__FILE__) . '/lib/cacheutils.php');
include_once(dirname(__FILE__) . '/MovieMasher.php');

ini_set('memory_limit', -1);
				
class MovieMasher_Coder extends MovieMasher
{
	var $_tempDir; // 'Coder_UNIQID' directory created in DirTemporary
	var $_buildDir; // 'build' directory created in _tempDir
	var $_coderName; // string 'encoder', 'decoder'...
	var $__percentDone; // how far through whole coding job
	var $__steps; // array with step name as key, index as value (also key for total_steps)
	var $_ignore; // array with file names to ignore if archiving
	var $__jobID; // holds the current job ID, as set in call to codeFile()
	static $defaultOptions = array(
		'CoderArchiveExtension' => array(
			'value' => 'EXTENSION',
			'description' => "Output format specific archive file extension",	
			'emptyok' => 1,
			'default' => '',
		),
		'CoderBaseURL' => array(
			'value' => 'URL',
			'description' => "Prefix URL prepended to relative URLs in MEDIA tags",	
			'emptyok' => 1,
			'default' => '',
		),
		'CoderDoneURL' => array(
			'value' => 'URL',
			'description' => "Will be requested via POST if job completes without error",	
			'emptyok' => 1,
			'default' => '',
		),
		'CoderError' => array(
			'value' => 'STRING',
			'description' => "If specified, job will halt and report the error (for debugging of error handling)",	
			'emptyok' => 1,
			'default' => '',
		),
		'CoderErrorURL' => array(
			'value' => 'URL',
			'description' => "Will be requested via POST if job completes with error",	
			'emptyok' => 1,
			'default' => '',
		),
		'CoderFileDelete' => array(
			'value' => 'BOOLEAN',
			'description' => "If true, delete option will be sent to File implementation specified in CoderFileURL",	
			'emptyok' => 1,
			'default' => '0',
		),
		'CoderFilename' => array(
			'value' => 'STRING',
			'description' => "Base name for resultant file",	
			'default' => 'media',
		),
		'CoderFileURL' => array(
			'value' => 'URL',
			'description' => "Where to save the resulting file(s) - starts with 'http', 'system' or other File class",	
			'emptyok' => 1,
			'default' => '',
		),
		'CoderIgnoreFileError' => array(
			'value' => 'BOOLEAN',
			'description' => "If true, any error returned by CoderFileURL is ignored",	
			'emptyok' => 1,
			'default' => '',
		),
		'CoderNoAudio' => array(
			'value' => 'BOOLEAN',
			'description' => "Whether or not to include audio tracks",	
			'default' => '0',
			'emptyok' => 1,
		),
		'CoderNoVideo' => array(
			'value' => 'BOOLEAN',
			'description' => "Whether or not to include visual tracks",	
			'default' => '0',
			'emptyok' => 1,
		),
		'CoderSaveTemporaryFiles' => array(
			'value' => 'BOOLEAN',
			'description' => "If true, temporary build files won't be removed (for testing)",	
			'default' => 0,
			'emptyok' => 1,
		),		
		'CoderProgressURL' => array(
			'value' => 'URL',
			'description' => "Will be requested via POST repeatedly as job is processed",	
			'emptyok' => 1,
			'default' => '',
		),
	);
	
	function MovieMasher_Coder($config)
	{
		parent::MovieMasher($config);
	}
	static function cleanURL($url)
	{
		$url = str_replace(' ', '%20', $url);
		return $url;
	}
	function codeFile($job_id)
	{
		if ($this->getOption('Verbose')) $this->log(print_r($this->_options, 1));
		$has_callback = ( ! (empty($this->_options['CoderDoneURL']) && empty($this->_options['CoderErrorURL'])));
		
		$ex = FALSE;
		$err = '';
		// grab configuration options and make sure they're not empty
		$dir_temporary = $this->_options['DirTemporary'];
		$dir_cache = $this->_options['DirCache'];
		if (! ($dir_temporary && $dir_cache)) throw new UnexpectedValueException('Configuration options DirTemporary, DirCache required');
		
		// set unique _tempDir for job
		$uid = 'Coder_' . unique_id('codertemp');
		$this->_tempDir = $dir_temporary . $uid . '/';
		
		// set build directory within it, and make sure we can create it
		$this->_buildDir = $this->_tempDir . $this->_options['CoderFilename'] . '/';
		if (! safe_path($this->_buildDir)) throw new RuntimeException('Could not create path: ' . $this->_buildDir);
	
	
		$this->__jobID = $job_id;
		
		// set progress path and make sure we can write to it (will create DirCache if it doesn't exist)
		$progress_path = $dir_cache . $this->__jobID . '/media.xml';
		if (! safe_path($progress_path)) throw new RuntimeException('Could not create path: ' . $progress_path);

		
		
		$this->_ignore = array();
		chdir($dir_temporary);
		
		
		
		$this->__percentDone = 1;
		$this->__steps = array('total_steps' => 0);
		
		$this->__outputProgress(substr($this->_coderName, 0, -1) . 'ing');
		
		if (! set_file_info($progress_path, 'cached', gmdate("Y-m-d H:i:s"))) throw new RuntimeException('Could not set cached meta data');
	
	
		// for progress calculations
		$this->_setupSteps();
		if (! empty($this->_options['CoderFileURL'])) $this->_addStep('StoreFile');
		if ($has_callback) $this->_addStep('CallbackURL');
		
		
		try
		{
			$coder_error = $this->getOption('CoderError');
			if ($coder_error) throw new RuntimeException($coder_error);
			$file_path = $this->_codeFile();
			
			// see if archive desired
			if (! empty($this->_options['CoderArchiveExtension']))
			{
				if (substr($file_path, -1) == '/') $file_path = substr($file_path, 0, -1);
				
				//$this->log('Archiving ' . $file_path . ' to ' . $archive_path);
				$file_path = $this->__createArchive($file_path);
			}
			
			
			$this->__storeFile($file_path);
			if (! empty($this->_options['CoderArchiveExtension']))
			{
				@unlink($file_path);
			}
		}
		catch(Exception $ex)
		{
			$err .= $ex->getMessage();
		}
		try
		{
			if (! $err) 
			{
				if ($has_callback) $this->_progressStep('CallbackURL', 1, 'Calling Callback URL');
			}
			else $this->__upProgress(-1, $err);
		}
		catch(Exception $ex)
		{
			// ignore any possible errors from upping progress
		}
		try
		{
			$this->__sendDone($err);
		}
		catch(Exception $ex)
		{
			$err .= $ex->getMessage();
		}
		try
		{
			if (! $err) 
			{
				$this->__percentDone = 100;
				$this->__outputProgress($this->_coderName . 'd');
			}
		}
		catch(Exception $ex)
		{
			// ignore any possible errors from upping progress
		}
		
		if (file_exists($this->_tempDir) && empty($this->_options['CoderSaveTemporaryFiles'])) 
		{
			// remove temporary files, even in error cases
			$this->_shellExecute('rm -R ' . $this->_tempDir);
		}
		try
		{
			flush_cache_files($dir_cache, $this->_options['CacheSize']);
		}
		catch(Exception $ex)
		{
			// ignore any possible errors from flushing cache
		}
		
		if ($err) throw new RuntimeException($err);
	}
	static function defaultOption($name)
	{
		$val = '';
		if (! empty(MovieMasher_Coder::$defaultOptions[$name]))
		{
			$val = MovieMasher_Coder::$defaultOptions[$name]['default'];
		}
		return $val;
	}
	function resetOptions()
	{
		$options = array();
		foreach($this->_configDefaults as $name => $a)
		{
			$options[$name] = $this->getOption($name);
		}
		$this->_options = $options;
		
		foreach($this->_optionsDefaults as $name => $options)
		{
			$this->setOption($name, (isset($options['default']) ? $options['default'] : ''));
		}
	}
	function _addStep($step_name)
	{
		$this->__steps[$step_name] = $this->__steps['total_steps'];
		$this->__steps['total_steps']++;
	}
	function _codeFile()
	{ 
		throw new BadMethodCallException('_codeFile not implemented');
	}
	function _populateDefaults()
	{
		parent::_populateDefaults();

		$this->_configDefaults['CacheSize'] = array(
			'value' => 'GIG',
			'description' => "Cache cleanup will occur if DirCache is larger than CacheSize after a job",	
			'default' => '1',
		);
		$this->_configDefaults['DirTemporary'] = array(
			'value' => 'DIR',
			'description' => "Temporary files will be created and removed from this directory",	
			'default' => '/tmp/moviemasher/',
		);
		$this->_configDefaults['LogProgress'] = array(
			'value' => 'BOOLEAN',
			'description' => "Whether or not to include progress information in log",	
			'default' => 0,
			'emptyok' => 1,
		);
		$this->_configDefaults['PathCropper'] = array(
			'value' => 'PROGRAM',
			'description' => "Convert program (part of ImageMagick)",	
			'default' => 'convert',
		);
		$this->_configDefaults['PathFFmpeg'] = array(
			'value' => 'PROGRAM',
			'description' => "Path to FFpmeg application",	
			'default' => 'ffmpeg',
		);
		
		foreach(MovieMasher_Coder::$defaultOptions as $k => $a)
		{
			$this->_optionsDefaults[$k] = $a;
		}
	}
	function _progressStep($step_name, $percent_done, $msg)
	{
		if (isset($this->__steps[$step_name]))
		{
			$p = 0;
			$step_amount = 100 / $this->__steps['total_steps'];
			$p += $step_amount * $this->__steps[$step_name];
			$p += ($percent_done * $step_amount) / 100;
			$this->__upProgress(ceil($p), $msg);
		}
	}
	function _setupSteps()
	{

	}
	function _shellExecute($s, $target = ' 2>&1', $dont_encode = 0)
	{
		$v = $this->getOption('Verbose');
		if ($v) $this->log($s . $target);
		$output = shell_command($s, $target, $dont_encode);
		if ($v) $this->log($output);
	   	return $output;
	}
	function __createArchive($file_path)
	{
		$err = '';
		$this->_progressStep('BuildFile', 5, 'Archiving');
		
		// zip it up
		$wd = getcwd();
		$parent_dir = dirname($file_path);
		
				
		chdir($parent_dir);
		
		$renamed = $parent_dir . '/' . $this->_options['CoderFilename'];
		rename($file_path, $renamed);
		
		$archive_path = $renamed . '.' . $this->_options['CoderArchiveExtension'];
		
		$cmd = '';
		$exclude_switch = '';
		switch($this->_options['CoderArchiveExtension'])
		{
			case 'tgz':
			{
				$cmd .= 'tar -czvf ';
				$cmd .= $archive_path . ' ' . substr($renamed, strlen($parent_dir) + 1);
				$exclude_switch = '--exclude';
				break;
			}
			// more to come...
		}
		
		
		
		if (! $cmd) throw new UnexpectedValueException('Unsupported archive format: ' . $this->_options['CoderArchiveExtension']);
	
	
		if ($this->_ignore)
		{
			foreach($this->_ignore as $exclude)
			{
				$exclude = substr(str_replace($file_path, $renamed, $exclude), strlen($this->_options['DirCache']));
				$cmd .= ' ' . $exclude_switch . ' ' . $exclude;
			}
		}
		$response = $this->_shellExecute($cmd);
		
		if (! file_exists($archive_path)) throw new RuntimeException('Could not create archive: ' . $response);
	
		rename($renamed, $file_path);
		
		$this->_progressStep('BuildFile', 100, 'Archived');
		return $archive_path;
	}
	function __outputProgress($s)
	{
		if ($s)
		{
			$dir_cache = $this->getOption('DirCache');
			if ($dir_cache)
			{
				//$s = htmlspecialchars(htmlspecialchars_decode($s));
				$xml_string = '';
				$xml_string .= '<Progress>' . "\n";
				$xml_string .= "\t" . '<PercentDone>' . $this->__percentDone . '</PercentDone>' . "\n";
				$xml_string .= "\t" . '<Date>' . http_date_string() . '</Date>' . "\n";
				$xml_string .= "\t" . '<Status>' . xml_safe($s) . '</Status>' . "\n";
				$xml_string .= '</Progress>' . "\n";
				$progress_path = $this->_options['DirCache'] . $this->__jobID . '/media.xml';
				@file_put_contents($progress_path, $xml_string, ($this->_options['Verbose'] ? FILE_APPEND : NULL));
				
				$coder_progress_url = $this->getOption('CoderProgressURL');
			
				if ($coder_progress_url)
				{
					if ($this->_options['Verbose'])
					{
						$xml_string = file_get($progress_path);
					}
					http_post_xml($coder_progress_url, "<moviemasher>\r$xml_string</moviemasher>");
				}
			}
			if (! empty($this->_options['LogProgress'])) $this->log($this->__percentDone . '% ' . $s);
		}
	}
	function __sendDone($err = '')
	{
		if ($url = $this->_options['Coder' . ($err ? 'Error' : 'Done') . 'URL'])
    	{
    		if ($this->_options['Verbose']) $this->log('Posting to: ' . $url);
       		$progress_path = $this->_options['DirCache'] . $this->__jobID . '/media.xml';
			// include latest progress
			$data = file_get($progress_path);
			if ($data)
			{
				if (http_post_xml($url, $data) === FALSE)
				{
					if (! $err) throw new RuntimeException('Could not post to CoderDoneURL');
				}
			}
    	}
		return $err;
	}
	function __storeFile($comp_file)
	{
		
		if (! file_exists($comp_file)) throw new RuntimeException('No file was coded');
		if ((! is_dir($comp_file)) && (! ($file_size = filesize($comp_file)))) throw new RuntimeException('Coded file was empty');
	
		
		$coder_file_url = $this->_options['CoderFileURL'];
		if ($coder_file_url) 
		{
			$url = parse_url($coder_file_url);
			if ($url)
			{
				
				$scheme = (empty($url['scheme']) ? 'System' : $url['scheme']);
				$options = array();
				$options['url'] = $comp_file;
				$options['path'] = substr($coder_file_url, strlen($scheme) + 2);
				$options['delete'] = $this->_options['CoderFileDelete'];
				$file = '';
			
				switch ($scheme)
				{
					case 'http':
					case 'https':
					{
						$file = 'HTTP';
						break;	
					}
					default: $file = ucwords($scheme);
				}
				if ($file)
				{
					$path_configuration = $this->_options['PathConfiguration'];
					if (! $path_configuration) throw new UnexpectedValueException('Configuration option PathConfiguration required');
			
					$file = MovieMasher::fromConfig($path_configuration, 'File', $file, $this->_options);
					
					
					$this->_progressStep('StoreFile', 10, "Storing File");
					$options['ignore'] = $this->_ignore;
					try
					{
						$file->put($options);
					}
					catch(Exception $ex)
					{
						if (empty($this->_options['CoderIgnoreFileError'])) throw new RuntimeException('Problem transfering file to: ' . $coder_file_url);
					}
					$this->_progressStep('StoreFile', 100, 'Stored File');
				}
			}
			else throw new RuntimeException('Could not parse URL: ' . $coder_file_url);
		}
		else $this->_progressStep('StoreFile', 100, "Saved to $comp_file");
	
	}
	function __upProgress($n, $status = '')
	{
		$n = round($n);
		$n = min(98, $n);
		if (! $n) $n = 1;
		if ($this->_options['Verbose'] || ($this->__percentDone != $n))
		{
			$this->__percentDone = $n;
			if ($status && (! is_numeric($status))) $this->__outputProgress($status);
		}
	}
}

?>
