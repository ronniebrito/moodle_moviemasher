<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title>Example :: Browse :: Movie Masher</title>


<script type='text/javascript' src='../media/js/swfobject/swfobject.js'></script>
<script type="text/javascript">
// <![CDATA[
var base = window.location.href.substr(0, window.location.href.lastIndexOf('/'));
var flashvarsObj = new Object();
flashvarsObj.base = base;
flashvarsObj.debug = 1;
flashvarsObj.evaluate = 1;
flashvarsObj.cmid= '<?php echo $_REQUEST['cm_id']; ?>';
flashvarsObj.user_id= '<?php echo $_REQUEST['userid']; ?>';
flashvarsObj.mash_id= '<?php echo $_REQUEST['mash_id']; ?>';
flashvarsObj.config = "media/xml/config.php?params=<?php echo $_REQUEST['userid']; ?>__<?php echo $_REQUEST['cm_id']; ?>__<?php echo $_REQUEST['mash_id']; ?>";
flashvarsObj.preloader = "../../moviemasher/com/moviemasher/display/Preloader/stable.swf";
var parObj = new Object();
parObj.allowFullScreen = "true";
parObj.id = "moviemasher_player";
swfobject.embedSWF("../../moviemasher/com/moviemasher/core/MovieMasher/stable.swf", "moviemasher_player", "100%", "100%", "10.0.0", "../media/js/swfobject/expressInstall.swf", flashvarsObj, parObj, parObj);


// ]]>



function moviemasher(frame, id)
{	
//	var fr =  document.getElementById(frame).contentDocument;
	return document.getElementById(id);
}

function play(){
 
	var startPosition = moviemasher('player_frame', 'moviemasher_player').evaluate('player.location');
	moviemasher('player_frame', 'moviemasher_player').evaluate('player.play=1');	
	return true;
}

function pausar(){
 
	var startPosition = moviemasher('player_frame', 'moviemasher_player').evaluate('player.location');
	moviemasher('player_frame', 'moviemasher_player').evaluate('player.play=0');	
	return true;
}

</script>
<style type="text/css">
	html {
		height:100%;
		overflow:hidden;
	}
	#moviemasher_player{
		height:100%;
		z-index:0;
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

	<div id="moviemasher_player">
		<strong>You need to upgrade your Flash Plugin to version 10 and enable JavaScript</strong>
	</div>	 

</body>
</html>
