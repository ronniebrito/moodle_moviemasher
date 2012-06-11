<?php

//var_dump($_REQUEST);

require_once(dirname( dirname( dirname(dirname(dirname(dirname(dirname(dirname(__FILE__)))))))).'/config.php');

//$db->debug = true;

$cmid = (empty($_GET['cmid']) ? '' : $_GET['cmid']);

$mash_id= (empty($_GET['mash_id']) ? '' : $_GET['mash_id']);

//$mash= (empty($_GET['mash']) ? '' : $_GET['mash']);


//mash.xml is buggy
$mash = file_get_contents('php://input');

$mash = str_replace('<moviemasher>','',$mash);
$mash = str_replace('</moviemasher>','',$mash);

$mashR = get_record('moviemasher_mash', 'id', $mash_id);

$mash = str_replace("&", "e", $mash);
$mash = addslashes($mash);

//echo $mash;
$mashR->mash =  utf8_encode($mash);

update_record('moviemasher_mash', $mashR);
/*
This script is called directly from Movie Masher Applet, in response to a click on the Save button.
The XML formatted mash is posted as raw data, available in php://input
The script saves the XML data to $xml_path - defined below
Status is reported in a javascript alert, by setting the 'get' attribute.
*/



?>