<?php
/*
This file provides hooks for the authentication mechanisms in the 'server' example and is included
by most scripts within it. As originally written, it uses PHP's built in HTTP authentication but
allows ANY username/password combination to be used. The authenticated_userid function is called
whenever paths are built to the user's content (uploads, rendered videos, XML data files). 
*/

function authenticate($realm = 'Any username and password will work for this example!', $msg = 'Reload to try again')
{
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
	return (empty($_SERVER['PHP_AUTH_USER']) ? '' : $_SERVER['PHP_AUTH_USER']);
}

?>