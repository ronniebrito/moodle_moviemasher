<?php  // $Id: upload.php,v 1.26 2006/08/08 22:09:56 skodak Exp $


    require_once("../../config.php");
    require_once("lib.php");

$db->debug = true;

// this is the mash id
    $id = optional_param('id', 0, PARAM_INT);  // Mash ID  
	$name = optional_param('name', 1, PARAM_RAW);  // generate thumbanil and copy to defiitive area, including in database
	$value = optional_param('value', 0, PARAM_RAW);  //delete file

  	if ($id) {
       // busca o mash id 	
		$mash  = get_record('moviemasher_mash', 'id', $id);	
		$moviemasher = get_record('moviemasher', 'id', $mash->moviemasher_id);	
		$module = get_record('modules', 'name', 'moviemasher');	
		$cm = get_record('course_modules', 'course', $moviemasher->course, 'module', $module->id);	
    }	
	$mash->$name= $value;
	update_record('moviemasher_mash', $mash);	

?>
