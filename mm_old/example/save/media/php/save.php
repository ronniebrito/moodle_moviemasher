<?php
/*
This script is called directly from Movie Masher Applet, in response to a click on the Save button.
The XML formatted mash is posted as raw data, available in php://input
The script saves the XML data to $xml_path - defined below
Status is reported in a javascript alert, by setting the 'get' attribute.
*/

$xml_path = '../xml/mash.xml'; // must be writable by the web server process
$err = '';

// check to make sure data was sent
if (! $err)
{
	$mash = file_get_contents('php://input');
	if (! $mash) $err = 'Mash data required - make sure mash attribute is set in CGI control tag';
}

if (! $err)
{
	// see xml/control_save.xml to see how this parameter is set
	$duration = (empty($_REQUEST['duration']) ? '' : $_REQUEST['duration']);
	// we're just testing for any duration, but you could also check for a specific length
	if (! $duration) $err = 'Please include at least one clip in your mash';
}

if (! $err) // save mash xml
{
	if (! @file_put_contents($xml_path, $mash)) $err = 'Problem saving mash, probably due to file permissions or paths';
}

// setting dirty to zero should cause save button to disable
if (! $err) print '<moviemasher trigger="player.mash.dirty=0" />';
else print '<moviemasher get=\'javascript:alert("' .  $err . '");\' />';

?>