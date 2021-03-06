<?php

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

$upload_dir = '../user/'; // needs to be writable by web server process
//$media_file = '../xml/media.xml'; // needs to be writable by web server process

$err = '';

// make sure $_FILES is set and has upload key
if (empty($_FILES) || empty($_FILES['Filedata'])) $err = 'No files supplied';

// make sure there wasn't a problem with the upload
if (! $err)
{
	$file = $_FILES['Filedata'];
	if (! empty($file['error'])) $err .= 'Problem with your file: ' . $file['error'];
	elseif (! is_uploaded_file($file['tmp_name'])) $err = 'Not an uploaded file';
}

// check to make sure file has acceptable extension
if (! $err)
{
	$extension = strtolower(substr($file['name'], strrpos($file['name'], '.') + 1));
	switch ($extension)
	{			
		case 'txt':
			break;
		case 'html':
			break;
		case 'htm':
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
	$label = $file['name'];
	//$id = unique_id('media' . $label);
	$id = 'x'.$mash_id;
	$url = 'media/user/' . $id . '.' . $extension;
	$path = $upload_dir . $id . '.' . $extension;	
	
	$dest_filepath = $CFG->dataroot.'/'.$moviemasher->course.'/moddata/moviemasher/'.$cm->id.'/'.$mash->user_id.'/' .$id . '.' . $extension;
	move_uploaded_file($file['tmp_name'],$dest_filepath);
	
	$mash->text = addslashes(file_get_contents_utf8($dest_filepath));		
	if ($extension =="txt"){
		$mash->text = "<html> <pre style='word-wrap: break-word; white-space: pre-wrap;'>".$mash->text ."</pre></html>";
	}
}

function file_get_contents_utf8($fn) { 
     $content = file_get_contents($fn); 
      return mb_convert_encoding($content, 'UTF-8', 
          mb_detect_encoding($content, 'UTF-8, ISO-8859-1', true)); 
} 


update_record('moviemasher_mash', $mash);
//$err = 'kljlkj';
if ($err) $attibs = 'get=\'javascript:alert("' .  $err . '");\'';
else $attibs = 'trigger="browser.parameters.group=SL"'. ' get=\'javascript:window.parent.frames["player_frame"].location.reload();alert("Carregado");javascript:window.parent.showRecorder();\'';
print '<moviemasher ' . $attibs . '	/>' . "\n\n";

?>
