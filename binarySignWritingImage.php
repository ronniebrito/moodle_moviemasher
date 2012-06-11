<?php

//ob_start();
//header("Content-Type: image/png"); 
//var_dump($_REQUEST);
$bsw = $_REQUEST['bsw'];

$file = 'http://localhost/moodle/mod/moviemasher/swmp/swis/column.php?bsw='. $bsw;

//$file = 'http://www.google.com.br/images/experiments/nav_logo78.png';
$f=fopen($file,'r');
$data='';
while(!feof($f))
    $data.=fread($f,8);
fclose($f);


//echo file_get_contents('http://www.libras.ufsc.br/hiperlab/swmediawiki/swmp/swis/glyphogram.php?bsw='. $bsw );
echo $data;

//ob_end_flush();
?>
