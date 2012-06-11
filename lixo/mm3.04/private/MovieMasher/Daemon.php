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
include_once('MovieMasher/MovieMasher.php');
include_once('MovieMasher/lib/fileutils.php');
include_once('MovieMasher/lib/cacheutils.php');
include_once('MovieMasher/lib/dateutils.php');
include_once('MovieMasher/lib/xmlutils.php');
include_once('MovieMasher/lib/idutils.php');

declare(ticks = 1);

class MovieMasher_Daemon extends MovieMasher
{

	var $_jobXML = ''; // currently processing job XML
	var $_jobID = ''; // currently processing job ID

	var $_pauseWhileProcessing = 1;
	
	var $__pid = 0;
	var $__isChild = false;
	var $__isRunning = false;
	var $__encoder;
	var $__decoder;
	
	function MovieMasher_Daemon($config)
	{
		parent::MovieMasher($config);
		$this->_options['DirPID'] = end_with_slash($this->_options['DirPID']);
		$this->_options['DirJobsQueued'] = end_with_slash($this->_options['DirJobsQueued']);
	}
	function jobType($job_xml)
	{
		return strtolower($job_xml->getName());
	}
	function start()
	{
		//$this->log('Starting daemon ' . ini_get('memory_limit') . ' ' . round(memory_get_usage() / 1024) . ' ' . round(memory_get_peak_usage() / 1024) . ' ' . round(memory_get_peak_usage(true) / 1024));
		if (! $this->__daemonize())
		{
			$this->log('Could not start daemon');
			return false;
		}
		//$this->log('Running... ' . ini_get('memory_limit') . ' ' . round(memory_get_usage() / 1024) . ' ' . round(memory_get_peak_usage() / 1024) . ' ' . round(memory_get_peak_usage(true) / 1024));
		$this->__isRunning = true;
		set_time_limit(0);
		ob_implicit_flush();
		$peak_seconds = $this->_options['DaemonPeekSeconds'];
		while ($this->__isRunning)
		{
			try
			{
				$this->__peek();
				$this->_eventLoop();
			}
			catch(Exception $ex)
			{
				$this->log($ex);
			}
			if ($peak_seconds) usleep($peak_seconds * 1000000); // one millionth
		}
		return true;
	}
	function stop()
	{
		//if (! empty($this->_options['Verbose'])) $this->log('Stopping daemon');
		$this->__isRunning = false;
		if ($this->__isChild && file_exists($this->_options['DirPID'] . 'MovieMasher_' . $this->_options['module'] . '_' . $this->_options[$this->_options['module']] . '.pid'))
		{
			//if (! empty($this->_options['Verbose'])) $this->log('Deleting PID');
			unlink($this->_options['DirPID'] . 'MovieMasher_' . $this->_options['module'] . '_' . $this->_options[$this->_options['module']] . '.pid');
		}

   }
	function _codeJob()
	{
		// at this point this is only called by Daemon::Local
		$ex = FALSE;
		try
		{
		
			$this->_validateJob($this->_jobXML);
			
			$type = MovieMasher_Daemon::jobType($this->_jobXML);
			$coder = $this->_coder($type);
			$coder->codeFile($this->_jobID);
			
		}
		catch(Exception $ex)
		{
			$ex = $ex->getMessage();
		}
		
		// even if there was an error we want to make sure there's a progress file for job
		$dir_cache = $this->_options['DirCache'];
		
		if ($dir_cache) 
		{
			$progress_path = $dir_cache . $this->_jobID . '/media.xml';
			if ($ex || (! file_exists($progress_path)))
			{
				$xml_string = '';
				$xml_string .= '<Progress>' . "\n";
				$xml_string .= "\t" . '<PercentDone>-1</PercentDone>' . "\n";
				$xml_string .= "\t" . '<Date>' . http_date_string() . '</Date>' . "\n";
				$xml_string .= "\t" . '<Status>' . xml_safe($ex) . '</Status>' . "\n";
				$xml_string .= '</Progress>' . "\n";
				
				if (safe_path($progress_path) && @file_put_contents($progress_path, $xml_string))
				{
					set_file_info($progress_path, 'cached', gmdate("Y-m-d H:i:s"));						
				}
			}
		}
		try
		{
			$this->__codedFile();
		}
		catch(Exception $ex2)
		{
			$ex = $ex2->getMessage();
		}
		// wait for any child processes to die
		while (pcntl_waitpid(-1, $status, WNOHANG) > 0);
	
		if ($ex) throw new RuntimeException($ex);
		
	}
	function &_coder($type)
	{
		$func = '_' . $type . 'r';
		$coder = $this->$func();
		return $coder;
	}
	function &_decoder()
	{
		if (! isset($this->__decoder))
		{
			$path_configuration = $this->getOption('PathConfiguration');
			if (! $path_configuration) throw new UnexpectedValueException('Configuration option PathConfiguration required');
			$this->__decoder =& MovieMasher::fromConfig($path_configuration, 'Coder', 'Decoder');
		}
		return $this->__decoder;
	}	
	function _deleteJob()
	{
		// base function does nothing
	}
	function &_encoder()
	{
		if (! isset($this->__encoder))
		{
			$path_configuration = $this->getOption('PathConfiguration');
			if (! $path_configuration) throw new UnexpectedValueException('Configuration option PathConfiguration required');
			$this->__encoder =& MovieMasher::fromConfig($path_configuration, 'Coder', 'Encoder');
		}
		return $this->__encoder;
	}
	function _eventLoop()
	{
		
	}
	function _populateDefaults()
	{
		parent::_populateDefaults();
		$this->_configDefaults['DaemonPeekSeconds'] = array(
			'value' => 'NUMBER',
			'description' => "Seconds to wait between directory checks.",
			'default' => 10,
			'emptyok' => 1,
		);	
		$this->_configDefaults['DirJobsQueued'] = array(
			'value' => 'URL',
			'description' => "Location to write new jobs to.",
			'default' => '',
			//'emptyok' => 1,
		);
		$this->_configDefaults['DirPID'] = array(
			'value' => 'DIR',
			'description' => "Process ID files will be created and removed from this directory.",	
			'default' => '/tmp/moviemasher/',
		);
		$this->_configDefaults['LogRequests'] = array(
			'value' => 'BOOLEAN',
			'description' => "Whether or not to add job requests to the log.",
			'default' => 1,
		);
		$this->_configDefaults['LogResponses'] = array(
			'value' => 'BOOLEAN',
			'description' => "Whether or not to add responses from endpoint to the log.",
			'default' => 1,
		);
		$this->_configDefaults['PosixGroup'] = array(
			'value' => 'GROUP',
			'description' => "POSIX gid to run daemon under.",
			'default' => '',
			'emptyok' => 1,
		);
		$this->_configDefaults['PosixUser'] = array(
			'value' => 'GROUP',
			'description' => "POSIX uid to run daemon under.",
			'default' => '',
			'emptyok' => 1,
		);
	}	
	function _processJob()
	{
		$dir_cache = $this->_options['DirCache'];
		$dir_jobs_queued = $this->_options['DirJobsQueued'];
		if (! ($dir_cache && $dir_jobs_queued)) throw new UnexpectedValueException('Configuration options DirCache, DirJobsQueued required');
		
		// create job file
		$this->_jobXML->asXML($this->_addDelimiters($dir_jobs_queued) . $this->_jobID . '.xml');
		
		$xml_string = '';
		$xml_string .= '<Progress>' . "\n";
		$xml_string .= "\t" . '<PercentDone>1</PercentDone>' . "\n";
		$xml_string .= "\t" . '<Date>' . http_date_string() . '</Date>' . "\n";
		$xml_string .= "\t" . '<Status>Queued</Status>' . "\n";
		$xml_string .= '</Progress>' . "\n";


		
		$progress_path = $dir_cache . $this->_jobID . '/media.xml';
		if (! safe_path($progress_path)) throw new RuntimeException('Could not create path: ' . $progress_path);
		if (! @file_put_contents($progress_path, $xml_string)) throw new RuntimeException('Could not write file: ' . $progress_path);
		if (! set_file_info($progress_path, 'cached', gmdate("Y-m-d H:i:s"))) throw new RuntimeException('Could set cached info: ' . $progress_path);
	}
	function _receiveJob()
	{
	
	}
	function _validateCoders()
	{
		$encoder = $this->_encoder();
		$decoder = $this->_decoder();
		$encoder->validateConfiguration();
		$decoder->validateConfiguration();
	}
	function _validateJob($job_xml)
	{
		$type = MovieMasher_Daemon::jobType($job_xml);
		
		$coder = $this->_coder($type);
		$coder->resetOptions();
		
		$kids = $job_xml->children();
		$z = sizeof($kids);
		for ($i = 0; $i < $z; $i++)
		{
			$coder->setOption($kids[$i]->getName(), (string) $kids[$i]);
		}
		$coder->validateOptions();
	}
	function __codedFile() // sent when Coder::codeFile done
	{
		// remove job file
		if (! empty($this->_options['DirJobsQueued'])) 
		{
			$file_path = $this->_options['DirJobsQueued'] . $this->_jobID . '.xml';
			//$this->log(__METHOD__ . ' ' . $file_path);
			@unlink($file_path);
		}
	}
	function __daemonize()
	{
   /**
    * 1) Check is daemon already running
    * 2) Fork child process
    * 3) Sets identity
    * 4) Make current process a session leader
    * 5) Write process ID to file
    * 6) Change home path
    * 7) umask(0)
    */
		$result = FALSE;
		
		if ((! $this->__isDaemonRunning()) && $this->__fork() && $this->__setIdentity() && posix_setsid())
		{
			
			try
			{
				$dir_pid = $this->_options['DirPID'];
				if (! safe_path($dir_pid))
				{
					$this->log('Could not create ' . $dir_pid);
				}
				elseif (! @file_put_contents($dir_pid . 'MovieMasher_' . $this->_options['module'] . '_' . $this->_options[$this->_options['module']] . '.pid', $this->__pid))
				{
					$this->log('Could not write to PID file');
				}
				else
				{
					@chdir('/');
					umask(0);
					
					pcntl_signal(SIGCHLD, array(&$this, '__sigHandler'));
					pcntl_signal(SIGTERM, array(&$this, '__sigHandler'));
		
					$result = TRUE;
				}
			}
			catch(Exception $ex)
			{
				$this->log($ex);
			}
		}
		return $result;
   }
	function __fork()
	{
   /**
    * Forks process
    *
    * @access private
    * @since 1.0
    * @return bool
    */
		$pid = pcntl_fork();
		if ($pid == -1) // error
		{
			$this->log(__METHOD__ . ' ' . posix_getpid() . ' could not fork process');
			return false;
		}
		else if ($pid) // parent
		{
			//if (! empty($this->_options['Verbose'])) $this->log(__METHOD__ . ' ' . posix_getpid() . ' child process forked, exiting');
			exit(0);
		}
		else // children
		{
			$this->__isChild = true;
			$this->__pid = posix_getpid();
			//if (! empty($this->_options['Verbose'])) $this->log(__METHOD__ . ' ' . posix_getpid() . ' is a forked child process');
			return true;
		}
	}
	function __isDaemonRunning()
	{
   /**
    * Cheks is daemon already running
    *
    * @access private
    * @since 1.0.3
    * @return bool
    */
      $oldPid = @file_get_contents($this->_options['DirPID'] . 'MovieMasher_' . $this->_options['module'] . '_' . $this->_options[$this->_options['module']] . '.pid');

      if ($oldPid !== false && posix_kill(0 + trim($oldPid),0))
      {
         $this->log('Daemon already running with PID: '. $oldPid);

         return true;
      }
      else
      {
         return false;
      }
   }
	function __jobProcessing()
	{
		return ($this->_jobID && file_exists($this->_options['DirJobsQueued'] . $this->_jobID . '.xml'));
	}
	function __peek()
	{
		
		if (! ($this->_pauseWhileProcessing && $this->__jobProcessing()))
		{
			if (empty($this->_jobID))
			{
				$this->_receiveJob();
				if ($this->_jobXML)
				{
					if (empty($this->_jobID)) $this->_jobID = (string) $this->_jobXML->JobID;
					if (empty($this->_jobID)) $this->_jobID = unique_id('jobid');
				
					//if (! empty($this->_options['Verbose'])) $this->log('Starting Job: ' . $this->_jobID);
					
					$this->_processJob();						
				}
			}
			else // active job
			{
				// job has just been coded
				$this->_deleteJob();
				//if (! empty($this->_options['Verbose'])) $this->log('Finished Job: ' . $this->_jobID);
				$this->_jobID = '';
				$this->_jobXML = '';
			}
		}
	
	}
	function __setIdentity()
	{
  /**
    * Sets identity of a daemon and returns result
    *
    * @access private
    * @since 1.0
    * @return bool
   */ 
   	if (! (empty($this->_options['PosixGroup']) || empty($this->_options['PosixUser'])))
   	{
		  if (!posix_setgid($this->_options['PosixGroup']) || ! posix_setuid($this->_options['PosixUser']))
		  {
			 $this->log('Could not set identity');
	
			 return false;
		  }
      }
      return true;
   }
	function __sigHandler($sigNo)
	{
   /**
    * Signals handler
    *
    * @access public
    * @since 1.0
    * @return void
    */
		switch ($sigNo)
		{
			case SIGTERM:   // Shutdown
			{
				//if (! empty($this->_options['Verbose'])) $this->log('SIGTERM signal');
				$this->stop();
				exit();
				break;
			}
			case SIGCHLD:   // Halt
			{
				//if (! empty($this->_options['Verbose'])) $this->log('SIGCHLD signal ' . $this->__isChild);
				while (pcntl_waitpid(-1, $status, WNOHANG) > 0);
				break;
			}
		}
   }
}

?>