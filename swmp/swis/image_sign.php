<?php
//setup language
//needs to be refactored...
$lang='en';
include 'iswa.i18n.php';
include 'iswa.i18n.sym.php';
$msg = array_merge($messages[$lang],$symNames[$lang]);
include 'swis.i18n.php';
$msg = array_merge($messages[$lang],$msg);

//add libraries
include "iswa.php";

//get input
$bsw = bsw2spaced($_REQUEST['bsw']);
$sym = $_REQUEST['sym'];
$view = $_REQUEST['view'];
$download = $_REQUEST['download'];

$size = $_REQUEST['size'];
$pad = $_REQUEST['pad'];
$bound = $_REQUEST['bound'];
if (!$size){$size='1';}
$line = $_REQUEST['line'];
if (!$line){$line='000000';}
$fill = $_REQUEST['fill'];
if (!$fill){$fill='FFFFFF';}
$fill_trans = $_REQUEST['fill_trans'];
$back = $_REQUEST['back'];
if (!$back){$back='FFFFFF';}
$back_trans = $_REQUEST['back_trans'];
$colorize = $_REQUEST['colorize'];

//start page
if ($download){
  include 'pclzip/pclzip.lib.php';

  $bsw = str_replace(" ","",$bsw);
  $bsw = str_replace("\n","",$bsw);
  $bsw = str_replace("\r","",$bsw);
  $bsw = str_replace("\t","",$bsw);
  if (!validBSW($bsw)){
    die('Invalid Binary SignWriting');
  }

  //setup fill/back trans
  if ($fill_trans) $fill='';
  if ($back_trans) $back='';

  //checking dir
  $dir = 'extract';
  if (!is_dir($dir)){
    $rs = @mkdir( $dir, 0777 );
    if(! $rs ) {
      die('This install of the SignWriting Image Server is not configured for extracts');
    }
  }

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

  $stamp = time();  //only one person gets!
//$stamp = '1264858152';
  while(is_dir($dir . '/' . $stamp)){
    $stamp = time();
  }
  $dir .= "/$stamp";
  if (!is_dir($dir)){
    $rs = @mkdir( $dir, 0777 );
    if(! $rs ) {
      die('Fail: could not make directory for this stamp for ' . $stamp);
    }
  }

  //get a list of chars
  $units = bsw2unit($bsw);
  $units = array_unique($units);
  foreach ($units as $bsw){
    $base = substr($bsw,0,3);
    if (isPunc($base)){
      include('glyph_src.php');
      imagepng($im,$dir . '/' . $bsw . '.png'); 
    } else {
      include('glyphogram_src.php');
      imagepng($im,$dir . '/' . $bsw . '.png'); 
    }
  }
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
  header('Content-Disposition: attachment; filename=signs.zip');
  readfile($filename);
  die();
}
?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link href="index.css" rel="stylesheet" type="text/css" media="all">
<script type="text/javascript" src="jscolor/jscolor.js"></script>
<script type="text/javascript" src="submit.js"></script>

<?php
echo '<title>' . $msg['swis_desc'] . '</title></head>' . "\n";
echo '<body>';

include 'command.php';
echo '<div class="detail">';
$subhead = $msg['swis_signs'];;
include 'header.php';
//page header

echo '<center>' . "\n";
echo '<FORM name="bswform" onSubmit="return OnSubmitForm();" method="GET">' . "\n";
include 'intab.php';

echo '<br><br>';

echo '<TABLE BORDER CELLPADDING=3>';
echo '<tr><th colspan=3>';
echo $msg['swis_signs'];
echo '</th></tr>' . "\n";

echo '<tr>' . "\n";
echo '<td>' . $msg['swis_size'] . ': <input size="6" name="size" value="' . $size . '"></td>' . "\n";
echo '<td>' . $msg['swis_pad'] . ': <input size="6" name="pad" value="' . $pad . '"></td>' . "\n";
echo '<td>' . $msg['swis_bound'] . ': '; 
echo '<select name="bound">' . "\n";
echo '<option value="t" ';
if ($bound=="t")  {echo "selected";}
echo '>' . $msg['swis_tight'];
echo '<option value="c" ';
if ($bound=="c")  {echo "selected";}
echo '>' . $msg['swis_center'];
echo '<option value="h" ';
if ($bound=="h")  {echo "selected";}
echo '>' . $msg['swis_h_center'];
echo '<option value="v" ';
if ($bound=="v")  {echo "selected";}
echo '>' . $msg['swis_v_center'];
echo '</select>' . "\n";

echo '</td>' . "\n";
echo '</tr>' . "\n";

echo '<tr>' . "\n";
echo '<td valign=top>' . $msg['swis_line'] . '<input size="6" name="line" class="color" value="' . $line . '">';
echo '<br>' . $msg['swis_colorize'] . ': <input type="checkbox" name="colorize" ';
if ($colorize) echo 'checked';
echo '>' . "\n";
echo '</td>' . "\n";
echo '<td valign=top>' . $msg['swis_fill'] . ': <input size="6" name="fill" class="color" value="' . $fill . '">';
echo '<br>' . $msg['swis_transparent'] . ': <input type="checkbox" name="fill_trans" ';
if ($fill_trans) echo 'checked';
echo '>' . "\n";
echo '</td>' . "\n";
echo '<td valign=top>' . $msg['swis_back'] . ': <input size="6" name="back" class="color" value="' . $back . '">';
echo '<br>' . $msg['swis_transparent'] . ': <input type="checkbox" name="back_trans" ';
if ($back_trans) echo 'checked';
echo '>' . "\n";
echo '</td>' . "\n";
echo '</tr>' . "\n";

echo '<tr>' . "\n";
echo '<td colspan=3 align=middle><INPUT TYPE=SUBMIT name="view" onClick="document.pressed=sym" VALUE="' . $msg['swis_view'] . '">&nbsp;&nbsp;' . "\n";
echo '<INPUT TYPE=SUBMIT name="download" onClick="document.pressed=sym" VALUE="' . $msg['swis_download'] . '"></td>' . "\n";
echo '</tr>' . "\n";

echo '</table>';
echo '</FORM>' . "\n";

//remove white space
$bsw = str_replace(" ","",$bsw);
$bsw = str_replace("\n","",$bsw);
$bsw = str_replace("\r","",$bsw);
$bsw = str_replace("\t","",$bsw);
if (!validBSW($bsw)){
  if ($bsw) echo '<i>' . $msg['iswa_invalid'] . ' ' . $msg['iswa_bsw'] . '</i>';
} else {
  //set up fill/back trans
  if ($fill_trans) $fill='';
  if ($back_trans) $back='';
  //build extra attributes
  $extra = '';
  if ($size) {
    $extra .= '&size=' . $size;
  }
  if ($pad) {
    $extra .= '&pad=' . $pad;
  }
  if ($bound<>"t") {
    $extra .= '&bound=' . $bound;
  }
  if ($colorize) {
    $extra .= '&colorize=1';
  } else {
    $extra .= '&line=' . $line;
  }
  $extra .= '&fill=' . $fill;
  $extra .= '&back=' . $back;
  if ($view) {
    $units = bsw2unit($bsw);
    $units = array_unique($units);
    sort($units,SORT_STRING);
    forEach($units as $bsw){
      $base = substr($bsw,0,3);
      if (isPunc($base)){
        echo '<p><img src="glyph.php?bsw=' . $bsw . $extra . '&name=' . $bsw . '">';
      } else {
        echo '<p><img src="glyphogram.php?bsw=' . $bsw . $extra . '&name=' . $bsw . '">';
      }
    }
  }
}

?>
</div>
</body>
</html>﻿﻿﻿﻿﻿﻿
