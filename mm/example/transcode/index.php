<?php
/*
This script is called directly from the web browser. The HTML page is returned,
as long as the user can be authenticated via HTTP. This document includes styles
needed for a full window, liquid interface layout. The Movie Masher applet is
embedded using the swfObject JavaScript library.
*/

ini_set('display_errors', 1);
error_reporting(E_ALL);

$err = '';
$dir_log = '';

// load utilities
if ((! $err) && (! @include_once(dirname(__FILE__) . '/media/php/include/authutils.php'))) $err = 'Problem loading authentication utility script';
if ((! $err) && (! @include_once(dirname(__FILE__) . '/media/php/include/configutils.php'))) $err = 'Problem loading configuration utility script';
if ((! $err) && (! @include_once(dirname(__FILE__) . '/media/php/include/logutils.php'))) $err = 'Problem loading log utility script';

if (! $err) // pull in configuration so we can log other errors
{
	$config = @parse_ini_file('moviemasher.ini');
	$dir_log = config_path(empty($config['DirLog']) ? '' : $config['DirLog']);
	$err = config_error($config);
}
// autheticate the user (will exit if not possible)
if ((! $err) && (! auth_ok())) auth_challenge();

if ($err) // if error encountered output it and exit, otherwise content below will output
{
	print $err;
	log_file($err, $dir_log);
	exit;
}
// Player control dimensions are double preprocessed dimensions
$encoder_dimensions = (empty($config['EncoderDimensions']) ? '208x117' : $config['EncoderDimensions']);
list($video_width, $video_height) = explode('x', $encoder_dimensions);
$video_width *= 2;
$video_height *= 2;
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title><?php print $config['Client'] . '-' . $config['File'];?> Example :: Server <?php print @file_get_contents('VERSION.txt', 1); ?>:: Movie Masher</title>
<script type='text/javascript' src='../media/js/swfobject/swfobject.js'></script>
<script type="text/javascript">
// <![CDATA[
var base = window.location.href.substr(0, window.location.href.lastIndexOf('/'));
var flashvarsObj = new Object();
flashvarsObj.base = base;
flashvarsObj.debug = 1;
flashvarsObj.video_width = <?php print $video_width;?>;
flashvarsObj.video_height = <?php print $video_height;?>;
flashvarsObj.config = "media/xml/config.xml";
flashvarsObj.preloader = "../../moviemasher/com/moviemasher/display/Preloader/stable.swf";
var parObj = new Object();
parObj.allowFullScreen = "true";
swfobject.embedSWF("../../moviemasher/com/moviemasher/core/MovieMasher/stable.swf", "moviemasher_container", "100%", "100%", "10.0.0", "../media/js/swfobject/expressInstall.swf", flashvarsObj, parObj, parObj);
// ]]>
</script>
<style type="text/css">
	html {
		height:100%;
		overflow:hidden;
	}
	#moviemasher_container {
		height:100%;
	}
	body {
		height:100%;
		margin:0px;
		padding:0px;
		background-color:#FFFFFF;
	}
</style>
</head>
<body>
	<div id="moviemasher_container">
		<strong>You need to upgrade your Flash Plugin to version 10 and enable JavaScript</strong>
	</div>
</body>
</html>
