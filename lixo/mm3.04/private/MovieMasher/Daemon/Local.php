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
include_once('MovieMasher/lib/fileutils.php');

/*
Daemon periodically checks local folder for coding jobs to process.
*/

class MovieMasher_Daemon_Local extends MovieMasher_Daemon
{
	function MovieMasher_Daemon_Local($options)
	{
		parent::MovieMasher_Daemon($options);
		ini_set('memory_limit', -1);
	}
	function validateConfiguration()
	{
		parent::validateConfiguration();
		$this->_validateCoders();
	}
	function _processJob()
	{
		$this->_codeJob();
	}	
	function _populateDefaults()
	{
		parent::_populateDefaults();
		$this->_configDefaults['DirJobsQueued'] = array(
			'value' => 'DIR',
			'description' => "Location to look for new jobs in.",
			'default' => '',
		);
	}	
	function _receiveJob()
	{
		$result = '';
		$dir_jobs_queued = $this->_options['DirJobsQueued'];
		if (! $dir_jobs_queued) throw new UnexpectedValueException('Configuration option DirJobsQueued required');
		
		
		$path = end_with_slash($dir_jobs_queued);
		
		$job_id = '';
		
		if (file_exists($path) && is_dir($path))
		{
		
			if ($dh = opendir($path)) 
			{
				while (($file = readdir($dh)) !== false) 
				{
					if (substr($file, 0, 1) != '.')
					{
						$xml = file_get_contents($path . $file);
						$this->_jobID = substr($file, 0, strpos($file, '.'));
						$xml = @simplexml_load_string($xml);
						if (! $xml) throw new RuntimeException('Could not parse job XML');
						$this->_jobXML = $xml;
						break; // just do one
					}
				}
				closedir($dh);
			}
		}
	}
}

?>