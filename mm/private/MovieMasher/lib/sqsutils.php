<?php

@include_once('Zend/Service/Amazon/Sqs.php');

function sqs_delete_message($access_key_id, $secret_access_key, $queue_url, $handle)
{
	$result = FALSE;
	if ($access_key_id && $secret_access_key && $queue_url && $handle)
	{
		try
		{
			$sqs = new Zend_Service_Amazon_Sqs($access_key_id, $secret_access_key);
			$result = $sqs->deleteMessage($queue_url, $handle);
		}
		catch (Exception $ex) 
 		{
        	// ignored, $result will be false	
        }
	}
	return $result;

}

function sqs_get_message($access_key_id, $secret_access_key, $queue_url, $timeout = 600)
{
	$result = FALSE;
	if ($access_key_id && $secret_access_key && $queue_url)
	{
		try
		{
			$sqs = new Zend_Service_Amazon_Sqs($access_key_id, $secret_access_key);
			
			foreach ($sqs->receive($queue_url, 1, $timeout) as $message) 
			{
				$result = $message;
			}
		}
		catch (Exception $ex) 
 		{
 			//print $ex->getMessage();
 			
        	// ignored, $result will be false	
        }
	}
	return $result;
}

function sqs_send_message($access_key_id, $secret_access_key, $queue_url, $message)
{
	$result = FALSE;
	if ($access_key_id && $secret_access_key && $queue_url && $message)
	{
		try
		{
			$sqs = new Zend_Service_Amazon_Sqs($access_key_id, $secret_access_key);
			$result = $sqs->send($queue_url, $message);
		}
		catch (Exception $ex) 
 		{
        	// ignored, $result will be false	
        }
	}
	return $result;
}
?>