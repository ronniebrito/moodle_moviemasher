<?php
/*
This file provides hooks for the authentication mechanisms in the 'server' example and is included
by most scripts within it. As originally written, it uses PHP's built in HTTP authentication but
allows ANY username/password combination to be used. The authenticated_userid function is called
whenever paths are built to the user's content (uploads, rendered videos, XML data files). The 
authenticated_url() function is called from decode.php, done.php and encode.php when callback URLs
are being generated for inclusion in the job XML for the renderer.
*/

include_once(dirname(__FILE__) . '/http_build_url.php');

function authenticate($realm = 'Any username and password will work for this example!', $msg = 'Reload to try again')
{
	// this function will not be called if authenticated() returns true
	header('WWW-Authenticate: Basic realm="' . $realm . '"');
	header('HTTP/1.0 401 Unauthorized');
	print $msg;
	exit;
}

function authenticated()
{
	// in this example we just check to see if ANY username and password have been set
	return ! (empty($_SERVER['PHP_AUTH_USER']) || empty($_SERVER['PHP_AUTH_PW']));
}

function authenticated_userid()
{
	// in this example the username serves as the ID, and is used to build user paths
	// if using sessions you might put the user ID there and retrieve here
	// or use some other mechanism in your authentication library to get the user ID
	return (empty($_SERVER['PHP_AUTH_USER']) ? '' : $_SERVER['PHP_AUTH_USER']);
}

function authenticated_url($url)
{
	// we are using HTTP authentication in this example
	// if using sessions you'll want to put the session name and ID into the query string instead
	$parts = array();
	$parts['user'] = $_SERVER['PHP_AUTH_USER'];
	$parts['pass'] = $_SERVER['PHP_AUTH_PW'];
	return http_build_url($url, $parts);
}


?>