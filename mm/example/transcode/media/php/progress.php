<?php 
/*
This script is called from Movie Masher Server, when progress has occured during job processing.
If the request can be properly authenticated, the message body is saved to the temp directory
using the $id parameter provide as a base name.
Any error encountered during processing is logged if possible.
*/

error_reporting(E_ALL);
ini_set('display_errors', 1);


$err = '';
$dir_log = '';

// load utilities
$include = dirname(__FILE__) . '/include/';
if ((! $err) && (! @include_once($include . 'authutils.php'))) $err = 'Problem loading authentication utility script';
if ((! $err) && (! @include_once($include . 'configutils.php'))) $err = 'Problem loading configuration utility script';
if ((! $err) && (! @include_once($include . 'fileutils.php'))) $err = 'Problem loading file utility script';
if ((! $err) && (! @include_once($include . 'logutils.php'))) $err = 'Problem loading log utility script';
if (! $err) // pull in configuration so we can log other errors
{
	$config = config_get();
	$dir_log = config_path(empty($config['DirLog']) ? '' : $config['DirLog']);
	$err = config_error($config);
}

if (! $err) // see if the user is autheticated (does not redirect or exit)
{
	if (! auth_ok()) $err = 'Unauthenticated access';
}

if (! $err) // check to make sure required parameters have been sent
{
	$id = (empty($_REQUEST['id']) ? '' : $_REQUEST['id']);
	if (! $id ) $err = 'Parameter id required';
}
if (! $err) // grab progress xml from request body
{
	$xml_string = @file_get_contents('php://input');
	if (! $xml_string) $err = 'No request body provided';
}
if (! $err) // write progress xml to temporary file
{
	$dir_temporary = config_path(empty($config['DirTemporary']) ? sys_get_temp_dir() : $config['DirTemporary']);
	if (! file_put($dir_temporary . $id . '.xml', $xml_string)) $err = 'Could not write progress file';
}
if ($err)
{
	header('HTTP/1.1: 400 Bad Request');
	header('Status: 400 Bad Request');
	log_file($err, $dir_log);
}
else log_file($xml_string, $dir_log);

?>