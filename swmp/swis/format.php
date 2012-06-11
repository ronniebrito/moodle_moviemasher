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
include "bsw.php";
include "swclasses.php";

//get input
$bsw = bsw2spaced($_REQUEST['bsw']);

//start page
?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link href="index.css" rel="stylesheet" type="text/css" media="all">
<script type="text/javascript" src="submit.js"></script>

<?php
echo '<title>' . $msg['swis_desc'] . '</title></head>' . "\n";
echo '<body>';

include 'command.php';
echo '<div class="detail">';
$subhead = $msg['swis_format'];
include 'header.php';
//page header
echo '<center>' . "\n";
echo '<FORM name="bswform" onSubmit="return OnSubmitForm();" method="GET">' . "\n";

include 'intab.php';

echo '</center>';

//remove white space
$bsw = str_replace(" ","",$bsw);
$bsw = str_replace("\n","",$bsw);
$bsw = str_replace("\r","",$bsw);
$bsw = str_replace("\t","",$bsw);

$units = bsw2unit($bsw);
//4 formats...
$fbsw = '';//binary signwriting
$fupua = '';//unicode private use area
$fswcm = '';//signwriting cartesian markup
$fswpm = '';//signwriting polar markup
$fbswml = '';//binary signwriting markup

foreach ($units as $ubsw){
  if (isPunc($ubsw)){ 
    $fbsw .= $ubsw . ' ';
    $fupua .= bsw2utf($ubsw) . ' ';
    $fswcm .= bsw2utf($ubsw,1);
    $fswpm .= bsw2utf($ubsw,1);
    $fbswml .= '&lt;punc&gt;' . bsw2key($ubsw) . '&lt;/punc&gt;<br>';
  } else {
    $unit = new Sign($ubsw);
    $ubsw = moveBSW($unit->getBSW(),$unit->getCenterX(), $unit->getCenterY());
    $fbsw .= $ubsw . ' ';
    $fupua .= bsw2utf($ubsw) . ' ';

    $first = substr($ubsw,0,3);
    $cluster = bsw2cluster($ubsw);
    $seq = bsw2seq($ubsw);
    $chars = str_split($cluster,3);
    $fswcm .= char2token($first);
    $fswpm .= char2token($first);
    $fbswml .= '&lt;sign lane="' . char2lane($first) . '"&gt;<br>';
    for ($i=0; $i<count($chars); $i++) {

      //first 3 are symbol
      $sbsw = $chars[$i];
      $i++;
      $sbsw .= $chars[$i];
      $i++;
      $sbsw .= $chars[$i];
      //next 2 are coordinates
      $i++;
      $sx = hex2num($chars[$i]);
      $i++;
      $sy = hex2num($chars[$i]);

      //center coordinates on symbol
      $sym = new Symbol($sbsw);
      $scx = round($sx+($sym->getWidth()/2));
      $scy = round($sy+($sym->getHeight()/2));
      //now to determine degrees
      //convoluted for easy...
$sd = ($scx < 0)
        ? round(rad2deg(atan2($scx,-$scy)))+360      // TRANSPOSED !! y,x params
        : round(rad2deg(atan2($scx,-$scy))); 
//      $sd = round(rad2deg(atan2(-$scy, -$scx)));
      
      //now to determine length
      $sl = round(sqrt(pow($scx,2) + pow($scy,2)));

      $fswcm .= bsw2utf($sbsw,1) . $sx . ',' . $sy;
      if (count($chars)==5){
        $fswpm .= bsw2utf($sbsw,1) . '0°0';
      } else {
        $fswpm .= bsw2utf($sbsw,1) . $sd . '°' . $sl;
      }
      $fbswml .= '&nbsp;&nbsp;&lt;sym x="' . $sx . '" y="' . $sy . '"&gt;' . bsw2key($sbsw) . '&lt;/sym&gt;<br>';
    }
    $fswcm .= ' ';
    $fswpm .= ' ';
    if ($seq){
      $fswcm .= ' Q' . bsw2utf($seq,1) . ' ';
      $fswpm .= ' Q' . bsw2utf($seq,1) . ' ';
      $chars = str_split($seq,9);
      for ($i=0; $i<count($chars); $i++) {
        $sbsw = $chars[$i];
        $fbswml .= '&nbsp;&nbsp;&lt;seq&gt;' . bsw2key($sbsw) . '&lt;/seq&gt;<br>';
      }
    }
    $fbswml .= '&lt;/sign&gt;<br>';
  }
}
if ($bsw){
  echo '<h2>BSW</h2>' . $fbsw;
  echo '<h2>Unicode PUA</h2>' . $fupua;
  echo '<h2>SignWriting Cartesian Markup</h2>' . $fswcm;
  echo '<h2>SignWriting Polar Markup</h2>' . $fswpm;
  echo '<h2>BSWML</h2>' . $fbswml;
}
?>

</div>
<br clear="all"><br>
<hr>
<?php include 'footer.php';?>
<hr><br>
</body>
</html>﻿﻿﻿﻿﻿﻿
