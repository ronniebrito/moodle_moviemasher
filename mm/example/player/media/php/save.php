<?php
require_once(dirname( dirname( dirname(dirname(dirname(dirname(dirname(dirname(__FILE__)))))))).'/config.php');


$cmid = (empty($_GET['cmid']) ? '' : $_GET['cmid']);

$mash_id= (empty($_GET['mash_id']) ? '' : $_GET['mash_id']);

//$mash= (empty($_GET['mash']) ? '' : $_GET['mash']);

$mash = file_get_contents('php://input');
$mash = str_replace('<moviemasher>','',$mash);
$mash = str_replace('</moviemasher>','',$mash);


$mashR = get_record('moviemasher_mash', 'id', $mash_id);

//$mash = str_replace("&", "e", $mash);
//$mash = addslashes($mash);


$mashR->mash =  $mash;

$mashR->timemodified = time();

update_record('moviemasher_mash', $mashR);


/*
This script is called directly from Movie Masher Applet, in response to a click on the Save button.
The XML formatted mash is posted as raw data, available in php://input
The script saves the XML data to $xml_path - defined below
Status is reported in a javascript alert, by setting the 'get' attribute.
*/

$xml_path = 'temp_mash.xml'; // must be writable by the web server process
$err = '';

file_put_contents($xml_path, $mash);


// setting dirty to zero should cause save button to disable
print '<moviemasher trigger="player.mash.dirty=0" />';
//print '<moviemasher get=\'javascript:alert("' .  addslashes($mash). '");\' />';
?>