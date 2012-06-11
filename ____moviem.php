<?php 
   require_once(dirname(dirname(dirname(__FILE__))).'/config.php');
    require_once(dirname(__FILE__).'/lib.php');
    
?>
    
    
<script type='text/javascript' src='<?php echo $CFG->wwwroot . '/mod/moviemasher/mm/example/media/'; ?>js/swfobject/swfobject.js'></script>
<script type="text/javascript">
// <![CDATA[
var base = window.location.href.substr(0, window.location.href.lastIndexOf('/'));
var flashvarsObj = new Object();
flashvarsObj.base = base;
flashvarsObj.debug = 1;
flashvarsObj.cmid= '<?php echo $id; ?>';
flashvarsObj.config = "<?php echo $CFG->wwwroot; ?>/mod/moviemasher/mm/example/moodle/media/xml/config.php?user=<?php echo $USER->id; ?>_cmid=<?php echo $cm->id; ?>";
flashvarsObj.preloader = "<?php echo $CFG->wwwroot . '/mod/moviemasher/mm/'; ?>moviemasher/com/moviemasher/display/Preloader/stable.swf";
swfobject.embedSWF("<?php echo $CFG->wwwroot . '/mod/moviemasher/mm/'; ?>moviemasher/com/moviemasher/core/MovieMasher/stable.swf", "moviemasher_container", "100%", "100%", "10.0.0", "<?php echo $CFG->wwwroot . '/mod/moviemasher/mm/example/media/'; ?>js/swfobject/expressInstall.swf", flashvarsObj);
// ]]>
</script>
<style type="text/css">
	html{
		height:100%;
		overflow:hidden;
	}
	#moviemasher_container {
		height:100%;
		z-index: 0;
	}
	body {
		height:100%;
		margin:0px;
		padding:0px;
		background-color:#FFFFFF;
	}
</style>

	<div id="moviemasher_container">
		<strong>You need to upgrade your Flash Plugin to version 10 and enable JavaScript</strong>
	</div>