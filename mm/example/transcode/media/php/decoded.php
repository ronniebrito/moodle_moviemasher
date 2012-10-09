<?php 
/*
This script receives the decoded mash from Movie Masher Server as a video file in $_FILES. If the
file is okay, it's moved to the directory named $id in the user's directory. If an
error is encountered a 400 header is returned and it is logged, if possible.
*/

$err = '';
$dir_log = '';

// load utilities
$include = dirname(__FILE__) . '/include/';
if ((! $err) && (! @include_once($include . 'archiveutils.php'))) $err = 'Problem loading archive utility script';
if ((! $err) && (! @include_once($include . 'authutils.php'))) $err = 'Problem loading authentication utility script';
if ((! $err) && (! @include_once($include . 'configutils.php'))) $err = 'Problem loading configuration utility script';
if ((! $err) && (! @include_once($include . 'fileutils.php'))) $err = 'Problem loading file utility script';
if ((! $err) && (! @include_once($include . 'httputils.php'))) $err = 'Problem loading http utility script';
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

if (! $err) // pull in other configuration and check for required input
{
	$client = (empty($config['Client']) ? 'REST' : strtoupper($config['Client']));
	$file = (empty($config['File']) ? 'Local' : ucwords($config['File']));
	$dir_temporary = config_path(empty($config['DirTemporary']) ? sys_get_temp_dir() : $config['DirTemporary']);
	$dir_host = config_path(empty($config['DirHost']) ? $_SERVER['DOCUMENT_ROOT'] : $config['DirHost']);
	$host = (empty($config['Host']) ? $_SERVER['HTTP_HOST'] : http_get_contents($config['Host']));
	$host_media = (empty($config['HostMedia']) ? $host : http_get_contents($config['HostMedia']));
	$path_cgi = config_path(empty($config['PathCGI']) ? substr(dirname(__FILE__), strlen($dir_host)) : $config['PathCGI']);
	$path_media = config_path(empty($config['PathMedia']) ? config_path(dirname($path_cgi)) . 'user' : $config['PathMedia']);
	$path_media .=  auth_userid() . '/';
	$decoder_extension = (empty($config['DecoderExtension']) ? 'flv' : $config['DecoderExtension']);
	$id = (empty($_REQUEST['id']) ? '' : $_REQUEST['id']);
	$job = (empty($_REQUEST['job']) ? '' : $_REQUEST['job']);
	if (! ($id && $job)) $err = 'Parameter id, job required';
	$media_dir = (($file == 'Local') ? $dir_host : 'http://' . $host_media . '/');
	$media_dir .=  $path_media . $id . '/';
}

// make sure $_FILES is set and has item
if ((! $err) && empty($_FILES)) $err = 'No files supplied';

// make sure first item in $_FILES is valid
if (! $err)
{
	foreach($_FILES as $k => $v)
	{
		$file = $_FILES[$k];
		break;
	}
	if (! $file) $err = 'No file supplied';
}

// make sure there wasn't a problem with the upload
if (! $err)
{
	if (! empty($file['error'])) $err = 'Problem with your file: ' . $file['error'];
	elseif (! is_uploaded_file($file['tmp_name'])) $err = 'Not an uploaded file';
}


if (! $err) // make sure we can determine extension of uploaded file
{
	$ext = file_extension($file['name']);
	if (! $ext) $err = 'Could not determine extension of uploaded file: ' . $file['name'];
}


if (! $err) // make extension is what we requested
{
	if ($ext != $decoder_extension) $err = 'Rendered extension (' . $ext . ') differs from requested (' . $decoder_extension . ')';
}

// make sure we can move the uploaded file
if (! $err)
{
	$path = $media_dir . $job . '.' . $ext;
	if (! file_safe($path)) $err = 'Problem creating directory';
	else if (! @move_uploaded_file($file['tmp_name'], $path)) $err = 'Problem moving: ' . $path;
}

// attempt to change its file permissions
if (! $err)
{
	if (! @chmod($path, 0777)) $err = 'Problem setting permissions of media: ' . $path;
}
if ($err)
{
	header('HTTP/1.1: 400 Bad Request');
	header('Status: 400 Bad Request');
	log_file($err, $dir_log);
}

?>