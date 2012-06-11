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
include_once('MovieMasher/lib/fileutils.php');
include_once('MovieMasher/lib/idutils.php');
include_once('MovieMasher/Client.php');

class MovieMasher_Client_Local extends MovieMasher_Client
{
	function MovieMasher_Client_Local($config = array())
	{
		parent::MovieMasher_Client($config);	
	}
	function rendersLocally() 
	{
		return TRUE;
	}
	function _populateDefaults()
	{
		parent::_populateDefaults();
		$this->_configDefaults['DirJobsQueued'] = array(
			'value' => 'URL',
			'description' => "Location to write new jobs to.",
			'default' => '',
		);
	}	
	function _post($type)
	{
		$dir_jobs_queued = $this->_options['DirJobsQueued'];
		$job_id = (empty($this->_options['JobID']) ? '' : $this->_options['JobID']);
		
		// make sure needed configuration is there
		if (! $dir_jobs_queued) throw new UnexpectedValueException('Configuration option DirJobsQueued required');
		
		// if no JobID configuration option was set make up an ID
		if (! $job_id) $job_id = unique_id($type . 'job');
		
		$path = end_with_slash($dir_jobs_queued);
		$path .= $job_id . '.xml';
		
		// make sure we have a directory to write the job xml file to
		if (! safe_path($path)) throw new RuntimeException('Could not create path: ' . $path);
		
		// build job xml and write to file
		$xml_str = $this->_xmlBody($type);
		if (! @file_put_contents($path, $xml_str)) throw new RuntimeException('Could not create file: ' . $path);
		
		return $job_id;
	}
}
?>