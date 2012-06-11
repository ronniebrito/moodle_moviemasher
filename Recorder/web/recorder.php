﻿<?php


require_once(dirname(dirname(dirname(dirname(dirname(__FILE__))))).'/config.php');
//require_once(dirname(dirname(dirname(__FILE__).'/lib.php')));

//$db->debug = true;
$id = optional_param('id', 0, PARAM_INT); // course_module ID, or

if ($id) {
	if (! $cm = get_coursemodule_from_id('moviemasher', $id)) {
		error('Course Module ID was incorrect');
	}

	if (! $course = get_record('course', 'id', $cm->course)) {
		error('Course is misconfigured');
	}

	if (! $moviemasher = get_record('moviemasher', 'id', $cm->instance)) {
		error('Course module is incorrect');
	}
		
	// busca o mash id 	
	$mash  = get_record('moviemasher_mash', 'moviemasher_id', $moviemasher->id,  'user_id', $USER->id );	

} 
	
	
?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
	<head>
		<title>recorder</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<script type="text/javascript" src="swfobject.js"></script>
		<script type="text/javascript">
			<!-- Adobe recommends that developers use SWFObject2 for Flash Player detection. -->
			<!-- For more information see the SWFObject page at Google code (http://code.google.com/p/swfobject/). -->
			<!-- Information is also available on the Adobe Developer Connection Under "Detecting Flash Player versions and embedding SWF files with SWFObject 2" -->
			<!-- Set to minimum required Flash Player version or 0 for no version detection -->
			var swfVersionStr = "10.1.52";
			<!-- xiSwfUrlStr can be used to define an express installer SWF. -->
			var xiSwfUrlStr = "";
			var flashvars = {};
			var params = {};
			params.quality = "high";
			params.bgcolor = "#ffffff";
			params.play = "true";
			params.loop = "true";
			params.wmode = "window";
			params.scale = "showall";
			params.menu = "true";
			params.devicefont = "false";
			params.salign = "";
			params.allowscriptaccess = "always";
			flashvars.id = "<?php echo($mash->id); ?>";
			var attributes = {};
			attributes.id = "recorder";
			attributes.name = "recorder";
			attributes.align = "middle";
			swfobject.createCSS("html", "height:100%; background-color: #ffffff;");
			swfobject.createCSS("body", "margin:0; padding:0; overflow:hidden; height:100%;");
			swfobject.embedSWF(
				"recorder.swf", "flashContent",
				"330", "650",
				swfVersionStr, xiSwfUrlStr,
				flashvars, params, attributes);
		</script>       
	</head>
	<body>
		<!-- SWFObject's dynamic embed method replaces this alternative HTML content for Flash content when enough JavaScript and Flash plug-in support is available. -->
		<div id="flashContent">
			<a href="http://www.adobe.com/go/getflash">
				<img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />
			</a>
			<p>This page requires Flash Player version 10.1.52 or higher.</p>
		</div>
        
        
	</body>
</html>
