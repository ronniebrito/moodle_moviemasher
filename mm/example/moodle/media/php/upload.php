<?php

//die();

require_once(dirname( dirname( dirname(dirname(dirname(dirname(dirname(dirname(__FILE__)))))))).'/config.php');

$cmid = optional_param('cmid', 0, PARAM_INT);
$userid = optional_param('userid', 0, PARAM_INT);  	 
$mash_id = optional_param('id', 0, PARAM_INT);  


$mash_id = (empty($_GET['id']) ? 0 : $_GET['id']);


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
		
		
/*
This script is called directly from Movie Masher Applet, in response to a click on upload button.
The uploaded file is in _FILES['Filedata'].
If the file uploads and its extension is acceptable, the following happens:
	* a quasi unique ID is generated for the media file
	* the base file name is changed to this ID, retaining file extension
	* the file is moved to $upload_dir - defined below
	* a media tag is inserted into $media_file for the uploaded file
Any error encountered is reported in a javascript alert, by setting the 'get' attribute.
Otherwise the 'trigger' attribute is used to switch the browser view to the images tab.
*/


$err = '';

// make sure $_FILES is set and has upload key
if (empty($_FILES) || empty($_FILES['Filedata'])) $err = 'No files supplied';

// make sure there wasn't a problem with the upload
if (! $err)
{
	$file = $_FILES['Filedata'];
	//$err = var_dump($file);
	if (! empty($file['error'])) $err .= 'Problem with your file: ' . $file['error']. $file['name']. $file['tmp_name']. " :(";
	elseif (! is_uploaded_file($file['tmp_name'])) $err = 'Not an uploaded file';
}
//$err = $_FILES['Filedata'];
//$err = "ss";
// check to make sure file has acceptable extension
if (! $err)
{
	$extension = strtolower(substr($file['name'], strrpos($file['name'], '.') + 1));
	switch ($extension)
	{		
		case 'flv':
			break;
		case 'mpeg':
			break;
		case 'mpg':
			break;
		case 'avi':
			break;

		case 'mpeg4':
			break;
		case 'mp4':
			break;
		default: 
			$err = 'Unsupported file extension ' . $extension;
	}
}
// load utilities
if ((! $err) && (! @include_once('../../../../private/MovieMasher/lib/idutils.php'))) $err = 'Problem loading utility script';

//move file and set its permissions
if (! $err)
{

	
	$video->timecreated = time();
	$video->moviemasher_id = $moviemasher->id;
	$video->mash_id = $mash->id;	
	$video_id = insert_record('moviemasher_video', $video);	
	
		
	mkdir( $CFG->dataroot.'/'.$moviemasher->course.'/');
	mkdir( $CFG->dataroot.'/'.$moviemasher->course.'/moddata/');
	mkdir( $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher');
	mkdir( $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/');
	mkdir( $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/' );	
	$dest_filepath = $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/'.$video_id.'.'.$extension;	
	move_uploaded_file($file['tmp_name'],$dest_filepath);
	$video = get_record('moviemasher_video', 'id', $video_id);	
	// discover duration	
	ob_start();	
	passthru("\"/usr/bin/ffmpeg\" -i \"{$dest_filepath}\" 2>&1");
	$duration = ob_get_contents();
	
	ob_end_clean();
	//echo $duration;
	$search = "/Duration: (.*?),/";
	$duration = preg_match($search, $duration, $matches, PREG_OFFSET_CAPTURE, 3);
	//echo "Duration of " . $dest_filepath . ": " . $matches[1][0];
	$duration = $matches[1][0];
	
	// 00:00:12.47 
	$durationAux  = split(":",$duration);
	//var_dump($durationAux);
	$duration = $durationAux[0] * 3600 + $durationAux[1] * 60 + $durationAux[2];	
	
	// generate thumbnail
	
	exec('ffmpeg -i '. $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/'.$video_id.'.'.$extension.' -an -ss 00:00:01 -an -r 1 -vframes 1 -y '. $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/'.$video_id.'.jpg');
	
	//$err = $duration;
	$video->name = $file['name'];
	$video->extension = $extension;
	$video->duration = $duration;	
	update_record('moviemasher_video', $video);	
}

if ($err) $attibs = 'get=\'javascript:alert("' .  $err . '");\'';
else $attibs = 'trigger="browser.parameters.group=SL"'. ' get=\'javascript:alert("Arquivo carregado");\'';
print '<moviemasher ' . $attibs . '	/>' . "\n\n";
?>
