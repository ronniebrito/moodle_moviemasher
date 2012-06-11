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
parObj.wmode = "transparent";
parObj.id = "moviemasher_editor";
swfobject.embedSWF("../../moviemasher/com/moviemasher/core/MovieMasher/stable.swf", "moviemasher_container", "100%", "100%", "10.0.0", "../media/js/swfobject/expressInstall.swf", flashvarsObj, parObj, parObj);




function moviemasher(id)
{
	//return (navigator.appName.indexOf("Microsoft") == -1) ? document[parObj.id] : window[parObj.id];
	return (navigator.appName.indexOf("Microsoft") == -1) ? document[id] : window[id];
}
function evaluateExpression(form)
{
	var expression = form.expression.value;
	 
	if (expression.length)
	{
		form.result.value = moviemasher().evaluate(expression);
	}
	return false;
}



function addSubtitles(subs){
	var mash = moviemasher("moviemasher_editor").evaluate('mash.xml');
//subs = decode(subs);
	mash = mash.replace('</mash>',subs+'</mash>');
	//	mash.replace('/lengthseconds/i',"sds");
	moviemasher("moviemasher_editor").evaluate(mash);
		
		//moviemasher("moviemasher_editor").evaluate('player.play=1');
}

// ]]>
</script>
<style type="text/css">
	html {
		height:100%;
		overflow:hidden;
	}
	#moviemasher_container , #moviemasher_container2{
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
	<div id="moviemasher_container">
		<strong>You need to upgrade your Flash Plugin to version 10 and enable JavaScript</strong>
	</div>
</body>
</html>
