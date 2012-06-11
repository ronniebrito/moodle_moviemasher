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
include "swclasses.php";

//get input
$bsw = bsw2spaced($_REQUEST['bsw']);
$sym = $_REQUEST['sym'];
$view = $_REQUEST['view'];
$download = $_REQUEST['download'];
$size = $_REQUEST['size'];
if (!$size){$size='1';}
$height = $_REQUEST['height'];
if (!$height){$height='400';}
$width = $_REQUEST['width'];
$offset = $_REQUEST['offset'];
if (!$offset){$offset='50';}
$top_pad = $_REQUEST['top_pad'];
$spacing = $_REQUEST['spacing'];
if (!$spacing){$spacing='10';}
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

  $st = new SignText($bsw,$size,$height-$top_pad,$spacing,$offset);
  $cols_st = $st->getCols();
  $col=0;
  foreach ($cols_st as $i=>$bsw){
    $filename = $dir . '/col_' . str_pad($i+1, 4, "0", STR_PAD_LEFT) . '.png';
    include('column_src.php');
    imagepng($im,$filename); 
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
  header('Content-Disposition: attachment; filename=columns.zip');
  readfile($filename);
  die();
}
?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link href="index.css" rel="stylesheet" type="text/css" media="all">
<link href="columns.css" rel="stylesheet" type="text/css" media="all">
<script type="text/javascript" src="jscolor/jscolor.js"></script>
<script type="text/javascript" src="submit.js"></script>

<?php
echo '<title>' . $msg['swis_desc'] . '</title></head>' . "\n";
echo '<body>';

include 'command.php';
echo '<div class="detail">';
$subhead = $msg['swis_cols'];;
include 'header.php';
//page header

echo '<center>' . "\n";
echo '<FORM name="bswform" onSubmit="return OnSubmitForm();" method="GET">' . "\n";
include 'intab.php';

echo '<br><br>';

echo '<TABLE BORDER CELLPADDING=3>';
echo '<tr><th colspan=3>';
echo $msg['swis_cols'];
echo '</th></tr>' . "\n";

echo '<tr>' . "\n";
echo '<td>' . $msg['swis_size'] . ': <input size="6" name="size" value="' . $size . '"></td>' . "\n";
echo '<td>' . $msg['swis_height'] . ': <input size="6" name="height" value="' . $height . '"></td>' . "\n";
echo '<td>' . $msg['swis_width'] . ': <input size="6" name="width" value="' . $width . '"></td>' . "\n";
echo '</tr>' . "\n";

echo '<tr>' . "\n";
echo '<td>' . $msg['swis_lane_offset'] . ': <input size="6" name="offset" value="' . $offset . '"></td>' . "\n";
echo '<td>' . $msg['swis_top_pad'] . ': <input size="6" name="top_pad" value="' . $top_pad . '"></td>' . "\n";
echo '<td>' . $msg['swis_spacing'] . ': <input size="6" name="spacing" value="' . $spacing . '"></td>' . "\n";
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
  $extra = 'size=' . $size;
  if ($colorize) {
    $extra .= '&colorize=1';
  } else {
    $extra .= '&line=' . $line;
  }
  if ($fill) $extra .= '&fill=' . $fill;
  if ($back) $extra .= '&back=' . $back;
  if ($view) {
    $st = new SignText($bsw,$size,$height-$top_pad,$spacing,$offset);
    $cols = $st->getCols();
    $cnt = count($cols);
    $pre = '<div class="signtextcolumn"><img src="column.php?' . $extra;
    if ($cnt>1) $pre .= '&height=' . $height;
    if ($width) $pre .= '&width=' . $width;
    if ($top_pad) $pre .= '&top_pad=' . $top_pad;
    $pre .= '&spacing=' . $spacing;
    $pre .= '&offset=' . $offset;
    foreach ($cols as $col){
      echo $pre . '&bsw=' . $col . '"></div>';
    }
  }
}

?>
</div>
</body>
</html>﻿﻿﻿﻿﻿﻿
