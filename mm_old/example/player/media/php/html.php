<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" >
<head>
<?php
/* 
This template script is included by share.php which captures its output for saving as an HTML file.

The following variables are REQUIRED to be set before inclusion:

$config_url - movie masher configuration file
$movie_url - used in og:video meta tag
$moviemasher_url - movie masher installation (parent of example directory)

The following variables are OPTIONAL:

$title - used in title and og:title meta tag
$description - used in og:description and description meta tags

*/
if (empty($title)) $title = 'My Mash';
if (empty($description)) $description = 'Check out this video I made with Movie Masher, the open source online video editor. Click their logo in the bottom right to make your own to share.';

/*


*/
print '
	<meta proprery="og:title" content="' . $title . '" /> 
	<meta property="og:type" content="article"/>
	<meta property="og:site_name" content="Movie Masher"/>
	<meta proprery="og:description" content="' . $description . '" /> 
	<meta property="og:image" content="' . $moviemasher_url . '/example/moodle/media/image/icon.jpg" /> 
	<meta property="og:url" content="' . $movie_url . '" />
	<meta property="og:video" content="' . $movie_url . '" />
	<meta property="og:video:width" content="330" />
	<meta property="og:video:height" content="274" />
	<meta property="og:video:type" content="application/x-shockwave-flash" />
';
?>
<meta name="description" content="<?php print $description; ?>" />
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title><?php print $title; ?></title>
<script type='text/javascript' src='<?php print $moviemasher_url; ?>/example/media/js/swfobject/swfobject.js'></script>
<script type="text/javascript">
// <![CDATA[
var flashvarsObj = new Object();
flashvarsObj.base = "<?php print $moviemasher_url; ?>/example/moodle";
flashvarsObj.debug = 1;
flashvarsObj.config = "<?php print $config_url; ?>";
flashvarsObj.preloader = "<?php print $moviemasher_url; ?>/moviemasher/com/moviemasher/display/Preloader/stable.swf";
swfobject.embedSWF("<?php print $moviemasher_url; ?>/moviemasher/com/moviemasher/core/MovieMasher/stable.swf", "moviemasher_container", "100%", "100%", "10.0.0", "", flashvarsObj);
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
