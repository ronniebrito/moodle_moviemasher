<?php

require_once(dirname(dirname(dirname(__FILE__))).'/config.php');

$bsw = $_REQUEST['palavra'];

$file= $CFG->wwwroot.'/mod/moviemasher/swmp/swis/column.php??size=1&line=000000&fill=FFFFFF&back=FFFFFF&spacing=10&offset=50&bsw='. $bsw;

$f=fopen($file,'r');
$dataImage='';
while(!feof($f))
    $dataImage.=fread($f,8);
fclose($f);


$fp = fopen('temp/'.md5(substr( $bsw, 0 ,128)).'.png', 'w');
fwrite($fp, $dataImage);
fclose($fp);

echo $bsw; 

?>
