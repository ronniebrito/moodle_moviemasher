<?php
/**
 * ISWA Extract 
 * 
 * Copyright 2007-2010 Stephen E Slevinski Jr
 * Steve (Slevin@signpuddle.net)
 * 
 * This file is part of SWIS: the SignWriting Image Server.
 * 
 * SWIS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * SWIS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with SWIS.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * END Copyright
 *  
 * @copyright 2007-2010 Stephen E Slevinski Jr 
 * @author Steve (slevin@signpuddle.net)  
 * @license http://www.opensource.org/licenses/gpl-3.0.html GPL
 * @access public
 * @package SWIS
 * @version 1.2.0
 * @filesource
 *   
 */

/**
 * include general iswa library
 */   
include 'bsw.php';
include 'swclasses.php';
include 'pclzip/pclzip.lib.php';

$bsw = $_REQUEST['bsw'];
$bsw = trim(str_replace(" ","",$bsw));
$utf = $_REQUEST['utf'];
$utf = str_replace(" ","",$utf);
if ($utf){
  $bsw=utf2bsw($utf);
}

//checking data
if (!ValidBSW($bsw)){
  die('Invalid Binary SignWriting');
}

//checking dir
$dir = 'extract';
if (!is_dir($dir)){
  $rs = @mkdir( $dir, 0777 );
  if(! $rs ) {
    die('This install of the SignWriting Image Server is not configured for extracts');
  }
}

//do I want year and month...
//aw yeah!
$year = date('Y');
$dir .= "/$year";
if (!is_dir($dir)){
  $rs = @mkdir( $dir, 0777 );
  if(! $rs ) {
    die('Fail: could not make directory for this year for ' . $year);
  }
}

$month = date('m');
$dir .= "/$month";
if (!is_dir($dir)){
  $rs = @mkdir( $dir, 0777 );
  if(! $rs ) {
    die('Fail: could not make directory for this month for ' . $month);
  }
}

//get directory stamp
//$stamp = $_REQUEST['stamp'];
//if (!$stamp){
  $stamp = time();  //only one person gets!
//}
$stamp = '1264858152';
while(is_dir($dir . '/' . $stamp)){
  $stamp = time();
}
$dir .= "/$stamp";
if (!is_dir($dir)){
  $rs = @mkdir( $dir, 0777 );
  $rs = @mkdir( $dir . '/iswa', 0777 );
  if(! $rs ) {
    die('Fail: could not make directory for this stamp for ' . $stamp);
  }
}

//main extract array of symbols
$extract = array();

//get iswa list of bsw
$chars = str_split(bsw2iswa($bsw),9);
//get a list of chars
foreach ($chars as $char){
  $key = bsw2key($char);
  $extract[$key]=1;
  $key = base2view(substr($char,0,3));
  $extract[$key]=1;
  $key = base2view(base2group(substr($char,0,3)));
  $extract[$key]=1;
}

ksort($extract);

//cycle through the iswa chars and copy
if (!is_dir($dir . '/iswa')){ mkdir($dir . '/iswa');}
foreach($extract as $key=>$val){
  $base = substr($key,0,3);
  $file = 'iswa/' . $base . '/' . $key . '.png';
//  echo "<img src='" . $file . "'>&nbsp;&nbsp;";
  $idir = $dir . '/iswa/' . $base;
  if (!is_dir($idir)){ mkdir($idir);}
  $source = 'iswa/' . $base .  '/' . $key . '.png';
  $dest = $idir . '/' . $key . '.png';
  if (!is_file($dest)) {copy($source,$dest);}
}

//copy swis ref files
$files=array('MochiKit.js','bsw.js','swclasses.js');
foreach($files as $file){
  $source = $file;
  $dest = $dir . '/iswa/' . $file;
  if (!is_file($dest)) {copy($source,$dest);}
}

//copy swis/iswa ref files
$files=array('by-sa.png','index.html','OFL-FAQ.txt','ofl.png','OFL.txt');

foreach($files as $file){
  $source = 'iswa/' . $file;
  $dest = $dir . '/iswa/' . $file;
  if (!is_file($dest)) {copy($source,$dest);}
}

$source = 'bswref.js';
$dest = $dir . '/iswa/index.js';
if (!is_file($dest)) {copy($source,$dest);}
$source = 'bswref.css';
$dest = $dir . '/iswa/index.css';
if (!is_file($dest)) {copy($source,$dest);}

//copy Cat pages
$cats = str_split("1234567",1);
//get a list of chars
foreach ($cats as $cat){
  $source = 'iswa/cat_' . $cat . '.html';
  $dest = $dir . '/' . $source;
  if (!is_file($dest)) {copy($source,$dest);}
}

//copy symbolgroup pages
foreach ($sg_list as $char){
  $source = 'iswa/' . $char . '_sg.html';
  $dest = $dir . '/' . $source;
  if (!is_file($dest)) {copy($source,$dest);}
}

//copy basesymbol pages
$chars = str_split(bsw2base($bsw),3);
//get a list of chars
foreach ($chars as $char){
  $source = 'iswa/' . $char . '/' . $char . '_bs.html';
  $dest = $dir . '/' . $source;
  if (!is_file($dest)) {copy($source,$dest);}
}

//create page documents .. written as HTML
$copyright = 'Stephen E Slevinski Jr.';
$html_output_pre = <<<EOF
<htm>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link href="iswa/index.css" rel="stylesheet" type="text/css" media="all">
    <script type="text/javascript" src="iswa/MochiKit.js"></script>
    <script type="text/javascript" src="iswa/bsw.js"></script>
    <script type="text/javascript" src="iswa/swclasses.js"></script>
    <script type="text/javascript" src="iswa/index.js"></script>
    <script type="text/javascript">
      var bsw = '
EOF;

$html_output_post = <<<EOF
';
      function AnalyzeInput(){
        return bsw;
      }
      var iswa_dir = 'iswa/';

      function imgSrc (cSym,other){
        switch (cSym.length) {
          case 3:
            var view = base2view(cSym);
            return 'iswa/' + cSym + '/' + view + '.png'; 
            break;
          case 4:
            alert ("old BSW call");
            break;
          case 5://key call
            var base = cSym.slice(0,3); 
            return 'iswa/' + base + '/' + cSym + '.png'; 
            break;
          case 9://3 char call
            var base = cSym.slice(0,3); 
            var fill = char2fill(cSym.slice(3,6)); 
            var rot = char2rot(cSym.slice(6,9)); 
            return 'iswa/' + base + '/' + base + fill + rot + '.png'; 
            break;
          default://unknown
            alert ("unknown length " + cSym);
            break;
        }
      }

      callLater(.1,ViewOutput);

    </script>

  </head>
  <body>
<table cellpadding="5" width="100%"><tr><td valign="top"><a href="http://scripts.sil.org/OFL"><img src="iswa/ofl.png"></a></td><td align=middle>
<h1>SignPuddle Reader</h1>
</td><td valign="top" align="right"><a href="http://creativecommons.org/licenses/by-sa/3.0/"><img src="iswa/by-sa.png"></a></td></tr></table>

<div>
<center>
<FORM>
<INPUT TYPE=BUTTON OnClick="ViewOutput();" VALUE="View">
<INPUT TYPE=BUTTON OnClick="DetailOutput();" VALUE="Detail">
<INPUT TYPE=BUTTON OnClick="SortOutput();" VALUE="Sort">
<INPUT TYPE=BUTTON OnClick="IndexOutput();" VALUE="Index">
<INPUT TYPE=BUTTON OnClick="FrequencyOutput();" VALUE="Frequency">
<INPUT TYPE=BUTTON OnClick="FormatOutput();" VALUE="Format">
</FORM>
</center>
</div>

<div id="output">loading</div>

<br clear="all">
<center><hr>
<b>Copyright 
EOF;
$html_output_post .= $year . ' ' . $copyright;
$html_output_post .= <<<EOF
<br>
 Some Rights Reserved.</b><br>
Except where otherwise noted, this work is licensed under<br>
<a href="http://creativecommons.org/licenses/by-sa/3.0/">
Creative Commons Attribution ShareAlike 3.0</a>
</center></body></html>
EOF;

//put index file
$html_output = $html_output_pre . $bsw . $html_output_post;
$file = 'index.html';
file_put_contents ($dir . '/index.html',$html_output);
//now to zip directory

$archive = new PclZip($dir . '.zip');
$v_dir = $dir; //getcwd(); // or dirname(__FILE__);
$v_remove = $v_dir;
// To support windows and the C: root you need to add the 
// following 3 lines, should be ignored on linux
  if (substr($v_dir, 1,1) == ':') {
    $v_remove = substr($v_dir, 2);
  }
  $v_list = $archive->create($v_dir, PCLZIP_OPT_REMOVE_PATH, $v_remove);
  if ($v_list == 0) {
    die("Error : ".$archive->errorInfo(true));
  }

//now output file!
  $filename = $dir . '.zip';
  header("Content-Length: " . filesize($filename));
  header('Content-Type: application/zip');
  header('Content-Disposition: attachment; filename=signpuddle_reader.zip');
  readfile($filename);?>

