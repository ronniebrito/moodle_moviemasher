<?php 
/*
This script is called from Movie Masher Server, when an error has occured during job processing.
If the request can be properly authenticated, the directory named $id in media/user is removed.
The body of the request contains XML formatted progress info indicating the error encountered.
This error or any other encountered during processing is logged if possible.
*/

$err = '';
$dir_log = '';

// load utilities
$include = dirname(__FILE__) . '/include/';
if ((! $err) && (! @include_once($include . 'authutils.php'))) $err = 'Problem loading authentication utility script';
if ((! $err) && (! @include_once($include . 'configutils.php'))) $err = 'Problem loading configuration utility script';
if ((! $err) && (! @include_once($include . 'logutils.php'))) $err = 'Problem loading log utility script';
if (! $err) // pull in configuration so we can log other errors
{
	$config = config_get();
	$dir_log = config_path(empty($config['DirLog']) ? '' : $config['DirLog']);
	$err = config_error($config);
}

if (! $err) // pull in other configuration and check for required input
{
	$dir_host = config_path(empty($config['DirHost']) ? $_SERVER['DOCUMENT_ROOT'] : $config['DirHost']);
	$path_cgi = config_path(empty($config['PathCGI']) ? substr(dirname(__FILE__), strlen($dir_host)) : $config['PathCGI']);
	$path_media = config_path(empty($config['PathMedia']) ? config_path(dirname($path_cgi)) . 'user' : $config['PathMedia']);
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
if (! $err)
{
	$path_media .= auth_userid();

	// remove uploaded file and directory
	// file_dir_delete_recursive($dir_host . $path_media . '/' . $id . '/');
}
if (! $err)
{
	// set $err for log entry
	$err = @file_get_contents('php://input');
}

if (! $err) $err = 'Received empty error';
if ($err) log_file($err, $dir_log);

?>