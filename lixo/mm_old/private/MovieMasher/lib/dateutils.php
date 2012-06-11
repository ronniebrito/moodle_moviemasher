<?php
/* 
This file is required by Coder and Daemon classes, to provide date for progress info. This file uses
PEAR's HTTP class to handle the date formatting. Functions will return FALSE if the class cannot be
loaded.
*/

// try to load HTTP PEAR class for date function

@include_once('HTTP.php');

function http_date_string()
{
	$result = FALSE;
	if (class_exists('HTTP'))
	{
		$result = HTTP::Date(time());
	}
	return $result;
}

?>