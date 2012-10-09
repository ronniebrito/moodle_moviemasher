<?php
/*
This file provides hooks for the authentication mechanisms and is included by most
scripts. It uses PHP's built in HTTP authentication but allows ANY username/password
combination to be used. The auth_challenge() function is only called from the index page.
The auth_userid() function is called whenever paths are built to the user's content
(uploads, rendered videos, XML data files). The auth_data() function is called from
decode.php and encode.php when callbacks are being generated for inclusion in the job XML
for the transcoder. 

If using session-based authentication, you may need to start the session manually and make
sure that use_only_cookies is off so any callbacks from the Transcoder AMI can be properly
authenticated. 

ini_set('session.use_only_cookies', '0');
session_name('session');
        
session_start();

*/

function auth_challenge($realm = 'Any username and password will work for this example!', $msg = 'Reload to try again')
{
	// in this example we use HTTP authentication
	// if using sessions, you'll probably want to redirect to login page instead
	header('WWW-Authenticate: Basic realm="' . $realm . '"');
	header('HTTP/1.0 401 Unauthorized');
	print $msg;
	exit;
}

function auth_ok()
{
	// in this example we just check to see if ANY username and password have been set
	// if using sessions, a mechanism in your auth library probably returns authentication state
	return ! (empty($_SERVER['PHP_AUTH_USER']) || empty($_SERVER['PHP_AUTH_PW']));
}

function auth_userid()
{
	// in this example the username serves as the ID, and is used to build user paths
	// if using sessions, a mechanism in your auth library probably returns a user ID
	return (empty($_SERVER['PHP_AUTH_USER']) ? '' : $_SERVER['PHP_AUTH_USER']);
}

function auth_data(& $request, $prefix = '')
{
	// use HTTP authentication - eg. http://User:Pass@www.example.com/path/
	$request[$prefix . 'User'] = $_SERVER['PHP_AUTH_USER'];
	$request[$prefix . 'Pass'] = $_SERVER['PHP_AUTH_PW'];
	
	/* 
	// if using sessions we add session name/id to parameter name/value, making sure they are arrays first
	if (empty($request[$prefix . 'ParameterName'])) $request[$prefix . 'ParameterName'] = array();
	else if (is_string($request[$prefix . 'ParameterName'])) $request[$prefix . 'ParameterName'] = array($request[$prefix . 'ParameterName']);
	$request[$prefix . 'ParameterName'][] = session_name();
	if (empty($request[$prefix . 'ParameterValue'])) $request[$prefix . 'ParameterValue'] = array();
	else if (is_string($request[$prefix . 'ParameterValue'])) $request[$prefix . 'ParameterValue'] = array($request[$prefix . 'ParameterValue']);
	$request[$prefix . 'ParameterValue'][] = session_id();
	*/
}


?>