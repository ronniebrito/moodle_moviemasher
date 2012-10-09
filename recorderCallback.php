<?php  // $Id: upload.php,v 1.26 2006/08/08 22:09:56 skodak Exp $


    require_once("../../config.php");
    require_once("lib.php");

//$db->debug = true;

// this is the mash id
    $id = optional_param('id', 0, PARAM_INT);  // Mash ID
    $accept = optional_param('accept', 0, PARAM_INT);  // wheter keep or delete file
	$prepublish = optional_param('prepublish', 1, PARAM_INT);  // generate thumbanil and copy to defiitive area, including database
	$delete= optional_param('delete', 0, PARAM_INT);  //delete file 
	
	


// busca o arquivo no red5 server 
// TODO: parametrizar host red5

	//$source_filepath = $CFG->dirroot.'/mod/moviemasher/Recorder/web/streams/'.$id.'.flv';
	$source_filepath = 'http://150.162.6.190:5080/recorder/streams/'.$id.'.flv';
	//echo $source_filepath;
	
  if ($id) {
       // busca o mash 
		$mash  = get_record('moviemasher_mash', 'id', $id);	
		//var_dump($mash);
		$moviemasher = get_record('moviemasher', 'id', $mash->moviemasher_id);	
		$module = get_record('modules', 'name', 'moviemasher');	
		$cm = get_record('course_modules', 'course', $moviemasher->course, 'module', $module->id);	
    }
	
	
   if(($prepublish)and(!($accept  or $delete ))){	   
	   // just echo file location for preview
	   //echo $CFG->wwwroot.'/mod/moviemasher/Recorder/web/streams/'.$mash->id.'.flv';	   
	   echo $source_filepath;	   
   }
   
   if ($delete){
	// delete file  from temporary area
	   unlink($source_filepath );
   }
   
   
  if($accept){ 
	
	$video->timecreated = time();
	$video->moviemasher_id = $moviemasher->id;
	$video->mash_id = $mash->id;	
	$video_id = insert_record('moviemasher_video', $video);	

	
	mkdir( $CFG->dataroot.'/'.$moviemasher->course );
	mkdir( $CFG->dataroot.'/'.$moviemasher->course.'/moddata/');
	mkdir( $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher');
	mkdir( $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/');
	mkdir( $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/' );
	$dest_filepath = $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/'.$video_id.'.flv';
	
	$video = get_record('moviemasher_video', 'id', $video_id);		

	//echo  $dest_filepath;
	copy($source_filepath , $dest_filepath);
	
	
	// discover duration	
	ob_start();	
	passthru("\"/usr/bin/ffmpeg\" -i \"{$dest_filepath}\" 2>&1");
	$duration = ob_get_contents();
	
	ob_end_clean();
	$search = "/Duration: (.*?),/";
	$duration = preg_match($search, $duration, $matches, PREG_OFFSET_CAPTURE, 3);
	//echo "Duration of " . $dest_filepath . ": " . $matches[1][0];
	$duration = $matches[1][0];
	
	// 00:00:12.47 
	$durationAux  = split(":",$duration);
	//var_dump($durationAux);
	$duration = $durationAux[0] * 3600 + $durationAux[1] * 60 + $durationAux[2];
	
	//echo 'ffmpeg -i '. $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/'.$video_id.'.flv -an -ss 00:00:01 -an -r 1 -vframes 1 -y '. $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/'.$video_id.'.jpg';
	
	

	// generate thumbnail	
	exec('ffmpeg -i '. $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/'.$video_id.'.flv -an -ss 00:00:01 -an -r 1 -vframes 1 -y '. $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/'.$video_id.'.jpg');	
	// check if thumbnail is generated, if not, put a dummy image 
	
	//echo 'ffmpeg -i '. $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/'.$video_id.'.flv -an -ss 00:00:01 -an -r 1 -vframes 1 -y '. $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/'.$video_id.'.jpg';
	$dia = getdate(time());	
	$video->name = $dia['mday'].'_'. $dia['mon'].'_' . $dia['year'].'_'.  $dia['hours'].'_'. $dia['minutes'];	
	$video->duration = $duration;	
	$video->extension = "flv";
	update_record('moviemasher_video', $video);	
	unlink($source_filepath );
	// end file URL , used by recorder for preview	
	echo $CFG->wwwroot.'/file.php/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/'.$video_id.'.flv';
	//echo $duration;
  }

?>
