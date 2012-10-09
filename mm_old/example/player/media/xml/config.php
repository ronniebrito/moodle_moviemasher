<?php 

echo '<?xml version="1.0"  encoding="utf-8" ?>';
require_once(dirname( dirname( dirname(dirname(dirname(dirname(dirname(dirname(__FILE__)))))))).'/config.php');

  // require_once(dirname( dirname( dirname(dirname(dirname(dirname(dirname(dirname(__FILE__)))))))).'/config.php');
//require_once(dirname(__FILE__).'/lib.php');

$cmid = optional_param('cmid', 0, PARAM_INT);
$userid = optional_param('userid', 0, PARAM_INT);  	 
$mash_id = optional_param('mashid', 0, PARAM_INT);  


$params = optional_param('params', 0, PARAM_RAW);  


$parametros = explode("__",$params);

//var_dump($params);
$userid = $parametros[0];
$cmid = $parametros[1];
$mash_id = $parametros[2];


//echo 'dddd'.$mash_id ;
?>
    <?php
//	$db->debug = true;


ob_start();

  	if ($cmid) {
		
		if (! $cm = get_coursemodule_from_id('moviemasher', $cmid)) {
            error('Course Module ID was incorrect');
        }
    
        if (! $course = get_record('course', 'id', $cm->course)) {
            error('Course is misconfigured');
        }
    
        if (! $moviemasher = get_record('moviemasher', 'id', $cm->instance)) {
            error('Course module is incorrect');
        }
	}
		
		$mash = get_record('moviemasher_mash', 'user_id', $userid, 'moviemasher_id', $moviemasher->id);
?>


<!-- TOP TIER CONFIGURATION LOADED DIRECTLY BY APPLET -->
<moviemasher>
	
	<!-- DEFAULT MASH -->
	<moviemasher config='media/xml/mash.xml' />
    
    
    <?php  echo  stripslashes($mash->mash); ?>
    
	
	<!-- PANEL INTERFACE LAYOUT -->
	<moviemasher config='media/xml/panel.xml' />
	
	<!-- DYNAMIC MEDIA SOURCES --> 
	<moviemasher config='media/xml/source.xml' />
	
	<!-- HANDLERS FOR ALL MEDIA EXCEPT IMAGES -->
	<moviemasher config='media/xml/handler.xml' />

</moviemasher>



<?php

ob_end_flush();
?>
