<?php
/*
This script is called directly from the web browser. The HTML page is returned,
as long as the user can be authenticated via HTTP. This document includes styles
needed for a full window, liquid interface layout. The Movie Masher applet is
embedded using the swfObject JavaScript library.
*/


$err = '';
// load MovieMasher
if ((! $err) && (! @include_once('MovieMasher/MovieMasher.php'))) $err = 'Problem loading MovieMasher.php';

// load objects from configuration
if (! $err)
{
	try
	{
		$moviemasher =& MovieMasher::fromConfig('MovieMasher.xml', 'Client');
	}
	catch(Exception $ex)
	{
		$err = xml_safe($ex->getMessage());
	}
}

// load utilities
if ((! $err) && (! @include_once('MovieMasher/lib/authutils.php'))) $err = 'Problem loading utility script';
	
// autheticate the user (will exit is not possible)
if ((! $err) && (! authenticated())) authenticate(); 
// if error encountered output it and exit, otherwise content below will output
if ($err)
{
	print $err;
	exit;
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title>Example :: Server <?php print @file_get_contents('VERSION.txt'); ?>:: Movie Masher</title>
<script type='text/javascript' src='../media/js/swfobject/swfobject.js'></script>
<script type="text/javascript">
// <![CDATA[
var base = window.location.href.substr(0, window.location.href.lastIndexOf('/'));
var flashvarsObj = new Object();
flashvarsObj.base = base;
flashvarsObj.debug = 1;
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
