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
include_once('MovieMasher/lib/sqsutils.php');
       
class MovieMasher_Daemon_SQS extends MovieMasher_Daemon
{	
	var $__receiptHandle;
	function MovieMasher_Daemon_SQS($options)
	{
		parent::MovieMasher_Daemon($options);
	}
	function _deleteJob()
	{
	
		if (! sqs_delete_message($this->getOption('AWSAccessKeyID'), $this->getOption('AWSSecretAccessKey'), $this->getOption('SQSQueueURLReceive'), $this->__receiptHandle))
		{
			throw new RuntimeException('Could not delete SQS message');
		}							
		if (! empty($this->_options['Verbose'])) $this->log('Deleted SQS Message');
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
		$this->_configDefaults['DaemonPeekSeconds'] = array(
			'value' => 'NUMBER',
			'description' => "Seconds to wait between calls to SQS Queue.",
			'default' => 10,
		);	
		$this->_configDefaults['SQSQueueURLReceive'] = array(
			'value' => 'URL',
			'description' => "SQS Queue to check.",
			'default' => '',
		);
		$this->_configDefaults['SQSVisibilitySeconds'] = array(
			'value' => 'NUMBER',
			'description' => "Seconds before SQS should reactivate Queue message.",
			'default' => 600,
		);	

	}	
	function _receiveJob()
	{
		$message = sqs_get_message($this->getOption('AWSAccessKeyID'), $this->getOption('AWSSecretAccessKey'), $this->getOption('SQSQueueURLReceive'), $this->_options['SQSVisibilitySeconds']);
		if ($message)
		{
			if ($this->_options['LogResponses']) $this->log('RECEIVED SQS Message: ' . $message['body']);
		
		
			$xml = @simplexml_load_string($message['body']);
			if (! $xml) throw new RuntimeException('Could not parse SQS delivered job XML');
			else 
			{
				$this->__receiptHandle = $message['handle'];
				$this->_jobXML = $xml;
				$this->_jobID = (string) $this->_jobXML->JobID;
				if (empty($this->_jobID)) $this->_jobID = $message['message_id'];
			}
		}
	}
}

?>