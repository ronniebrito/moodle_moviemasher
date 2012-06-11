<?php
/*
This script is called directly from Movie Masher Applet, in response to clicks in browser navigation and scrolling.
The count, index and group values are sent as GET parameters, as specified in config.xml.
Additional GET parameters can limit the result set - 'label' will match substrings.
The script searches through the XML file specified in $xml_path - defined below
Media tags matching parameters are included in result set, paged with count and index parameters.
If an error is encountered it is ignored and an empty result set is returned.
This script is called repeatedly as the user scrolls down, until an empty result set is returned.
*/

require_once(dirname( dirname( dirname(dirname(dirname(dirname(dirname(dirname(__FILE__)))))))).'/config.php');

$count = (empty($_GET['count']) ? 10 : $_GET['count']);
$index = (empty($_GET['index']) ? 0 : $_GET['index']);
$group = (empty($_GET['group']) ? '' : $_GET['group']);


$cmid = (empty($_GET['cmid']) ? '' : $_GET['cmid']);


		//echo 'oi '; die();
//$db->debug = true;


//$cm = get_record('course_modules', 'module', $module->id, 'instance' , $moviemasher->id );
          
//var_dump($USER);			
ob_clean();
ob_start();
print '<moviemasher>' . "\n";


	
	//$db->debug = true;
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
		
		$mash = get_record('moviemasher_mash', 'user_id', $USER->id, 'moviemasher_id', $moviemasher->id);
	//busca o mash do usuario
	//$mash = get_record('moviemasher_mash', 'moviemasher_id', $mashid, 'user_id', $USER->id);
	
	// busca os registros de videos
	
	
	$videos = get_records('moviemasher_video', 'mash_id', $mash->id);
	//print_r($videos);
	foreach($videos as $video){		
		print '<media group="video" type="video" id="'.$video->id.'" label="'.$video->name.'" duration="'.$video->duration.'"' ."\n";
		print ' audio="'. $CFG->wwwroot.'/file.php/'.$course->id.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/'.$video->id.'.flv"'."\n";
		print ' url="'. $CFG->wwwroot.'/file.php/'.$course->id.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/'.$video->id.'.flv"'."\n";
		print ' icon="'. $CFG->wwwroot.'/file.php/'.$course->id.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/'.$video->id.'.jpg"'."\n";
		print ' fill="crop" '."\n";
		print '/>'."\n";	
		
	
/*echo ('
<media group="video" type="video" id="53" label="2_1309811789" duration="8.77"
 audio="http://rocha.ava.ufsc.br:8081/~ronnie/etica/moodle/file.php/2/moddata/moviemasher/2/2/53.flv"
 url="http://rocha.ava.ufsc.br:8081/~ronnie/etica/moodle/file.php/2/moddata/moviemasher/2/2/53.flv"
 icon="http://rocha.ava.ufsc.br:8081/~ronnie/etica/moodle/file.php/2/moddata/moviemasher/2/2/53.jpg"
 fill="crop" 
/>
<media group="video" type="video" id="52" label="2_1309802762" duration="3.3"
 audio="http://rocha.ava.ufsc.br:8081/~ronnie/etica/moodle/file.php/2/moddata/moviemasher/2/2/52.flv"
 url="http://rocha.ava.ufsc.br:8081/~ronnie/etica/moodle/file.php/2/moddata/moviemasher/2/2/52.flv"
 icon="http://rocha.ava.ufsc.br:8081/~ronnie/etica/moodle/file.php/2/moddata/moviemasher/2/2/52.jpg"
 fill="crop" 
/>
<media group="video" type="video" id="51" label="2_1309802687" duration="4.36"
 audio="http://rocha.ava.ufsc.br:8081/~ronnie/etica/moodle/file.php/2/moddata/moviemasher/2/2/51.flv"
 url="http://rocha.ava.ufsc.br:8081/~ronnie/etica/moodle/file.php/2/moddata/moviemasher/2/2/51.flv"
 icon="http://rocha.ava.ufsc.br:8081/~ronnie/etica/moodle/file.php/2/moddata/moviemasher/2/2/51.jpg"
 fill="crop" 
/>
');*/
	}		
	
	
?>
<?php
print '</moviemasher>' . "\n";
//echo 'conteudo='.ob_get_contents();

ob_end_flush();
?>