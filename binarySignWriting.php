<?php

$palavra = $_REQUEST['palavra'];
//$palavra = 'adjetivo';
/*$file = 'http://www.nals.cce.ufsc.br/glossario/bsw.php?palavra='.$palavra ;

$f=fopen($file,'r');
$bsw='';
while(!feof($f))
    $bsw.=fread($f,8);
fclose($f);
*/
//$palavra = "1";

$bsw= $palavra;
if($palavra == "1"){
$bsw= "0fb33138c39251d50710e38d39a54551a20e38c39253c4f522a38c39254450815339139c5045272f938c39250a53c0fb23038c3965014f020638c39250450615339139952251115338c3a14f551321438c39250f52d0fb32138c39953150c11538c39655b4f511538c39655c52628938c39256d50415338f3a153c5342f938c39254254c0fb32138c39952e50c11538c3965674f515338f3a15395342f938c39253f54c2d238c39254b500 ";
}
if($palavra == "2"){
$bsw= "0fb30038c39954950c20538c39256a50610038d39357151410038d3935955152db38c39859d4f50fb36138c39252d4f530038c39852d4f520538c3925544ff10038d3935655000fb36138c39251e4f520338e39250952214a38e39251f52216d38d39253351f17638d3925475220fb34d38c3925244f51dc38e39254c5161dc38e39a50b51922138c39651e51622138c3965475152fb38c39653153522a38c39655353822a38d39650e53d";
}

$file = 'http://localhost/moodle/mod/moviemasher/swmp/swis/column.php??size=1&line=000000&fill=FFFFFF&back=FFFFFF&spacing=10&offset=50&bsw='. $bsw;


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
