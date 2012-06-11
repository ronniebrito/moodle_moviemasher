<?php
/**
 * Column image source for sign text
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
$st = new SignText($bsw,$size,$height-$top_pad,$spacing,$offset);

$cols = $st->getCols();
$posX = $st->getPosX();
$posY = $st->getPosY();

$bsw = $cols[$col];
$units = bsw2unit($bsw);
$xpos = $posX[$col];
$ypos = $posY[$col];
$data = '';
foreach ($units as $u=>$unit){
  $xadj = $xpos[$u];
  $yadj = $ypos[$u];
  $first = substr($unit,0,3);
  if(isPunc($first)){
    $data .= $unit . num2hex(-$xadj) . num2hex($yadj);
  } else {
    $bsw = bsw2cluster($unit);
    $chars = str_split($bsw,3);
    $cnt = count($chars);
    if ($bsw=="")$cnt=0;
    for ($i=0;$i<$cnt;$i++){
      $char = $chars[$i];
      $i++;
      $cfill = $chars[$i];
      $i++;
      $crot = $chars[$i];
      $i++;
      $x=hex2num($chars[$i]);
      $i++;
      $y=hex2num($chars[$i]); 
//creates illegal number characters... (but it works for now) max num 2869?
      $data .= $char . $cfill . $crot . num2hex($x-$xadj) . num2hex($y+$yadj);
    }
  }
}
/**
 * color options and transparency
 * 
 * 12 testing options
 * 3 line options - none (black), colorize, color 
 * 2 fill options - transparent or color    
 * 2 size options - 1 or other
 */
if ($colorize){
  $line='';  //ignore line color
} else {
  if (!$line){//default to black
    $line='000000';
  }
  list($r,$g,$b) = array_values(str_split($line,2));
  $rl=hexdec($r);
  $gl=hexdec($g);
  $bl=hexdec($b);
}

if ($fill){
  list($r,$g,$b) = array_values(str_split($fill,2));
  $rf=hexdec($r);
  $gf=hexdec($g);
  $bf=hexdec($b);
} else {
  $trans_fill=1;
  //check for white line
  if ($rl==255 and $gl==255 and $bl==255){
    $fill="000000";
    $rf=0;
    $gf=0;
    $bf=0;
  } else {
    $rf=255;
    $gf=255;
    $bf=255;
  }
}

/**
 * Step 1: break apart
 */  
$keys=array();
$xs=array();
$ys=array();

if ($data){
  $chars = str_split($data,3);
  $cnt = count($chars);
  for ($i=0;$i<$cnt;$i++){
    $base = $chars[$i];
    $i++;
    $hfill = char2fill($chars[$i]);
    $i++;
    $hrot = char2rot($chars[$i]);
    $keys[]=$base . $hfill . $hrot;
    $i++;
    $xs[]=hex2num($chars[$i]);
    $i++;
    $ys[]=hex2num($chars[$i]); 
  }
  /**
   * Step 2: load images and determine size
   */  
  $xMin=$xs[0];
  $xMax=$xMin+2;
  $yMin=$ys[0];
  $yMax=$yMin+2;
} else {
  $xMin=0;
  $xMax=$xMin+2;
  $yMin=0;
  $yMax=$yMin+2;
}

foreach ($keys as $num=> $key) {
    $image="im$num";
    $base = substr($key,0,3);
    $file = 'iswa/' . $base . '/' . $key . '.png';
    $$image= imagecreatefromstring(file_get_contents($file)); 
    if ($line){
      //for solid images
      if (imagecolorstotal( $$image)==1){
        $index=0;
      } else {
        $index=1;
      }
      imageColorSet($$image,$index,$rl,$gl,$bl);
    }
    if ($fill){
      //2 for fill, 1 for line
      if (imagecolorstotal( $$image)==2){
        $index=0;
      } else {
        $index=2;
      }
      imageColorSet($$image,$index,$rf,$gf,$bf);
    }
    $W= ImageSX($$image);
    $H= ImageSY($$image);
    $X= $xs[$num];
    $Y= $ys[$num];
    if ($xMin > $X) { $xMin=$X;}
    if ($yMin > $Y) { $yMin=$Y;}
    if ($xMax < ($X+$W)) { $xMax=$X+$W;}
    if ($yMax < ($Y+$H)) { $yMax=$Y+$H;}
}

/**
 * Step 3: set up the base image
 */
if ($width){
  $w_diff = ($width/$size) - $xMax + $xMin;
  $xMax += ($w_diff/2);
  $xMin = $xMax - ($width/$size);
}
if ($height==$maxheight){
  $im_base = imagecreatetruecolor($xMax-$xMin, $yMax-$yMin+$top_pad);
} else {
  $im_base = imagecreatetruecolor($xMax-$xMin, $height/$size);
}
if ($back){
  sscanf($back, "%2x%2x%2x", $backR, $backG, $backB);
  $background = imagecolorallocate($im_base, $backR, $backG, $backB);
} else {
  $background = imagecolorallocatealpha($im_base, 254, 0, 0,127);
}
imagefill($im_base, 0, 0, $background);
imagealphablending($im_base, false); // turn off the alpha blending to keep the alpha channel
imagesavealpha ($im_base, true );

//add symbols to base
foreach ($keys as $num => $key) {
    $image="im$num";
    $W= ImageSX($$image);
    $H= ImageSY($$image);
    $X= $xs[$num];
    $Y= $ys[$num];

    ImageCopy($im_base, $$image, $X-$xMin, $Y-$yMin+$top_pad, 0, 0, $W, $H); 
    ImageDestroy($$image); 
}

/**
 * Step 4: ugly hack for transparent fills
 */  
if ($trans_fill){
  for ($x=0;$x<$xMax-$xMin;$x++){
    for ($y=0;$y<$yMax-$yMin;$y++){
      $rgb = imagecolorat($im_base,$x,$y);
      $r = $rgb >> 16;
      $g = $rgb >> 8 & 255;
      $b = $rgb & 255;      
      if ($r==$rf and $g==$gf and $b==$bf){
        imagesetpixel($im_base, $x,$y, $background);
      }
    }
  }
}

/**
 * Step 5: resize if needed
 */  
if ($size){
  $imgw = imagesx($im_base);
  $imgh = imagesy($im_base);

  $w = $imgw * $size;
  if ($width) $w = $width;
  if ($height==$maxheight){
    $h = $imgh * $size;
  } else {
    $h = $height;
  }


  $im = imagecreatetruecolor($w, $h);
 
  /* making the new image transparent */
  $background = imagecolorallocate($im, 254, 0, 0);
  ImageColorTransparent($im, $background); // make the new temp image all transparent
  imagealphablending($im, false); // turn off the alpha blending to keep the alpha channel
  imagesavealpha ($im, true );
  imagecopyresampled($im, $im_base, 0, 0, 0, 0, $w, $h, $imgw, $imgh);
  ImageDestroy($im_base);
} else {
  $im = $im_base;
}
?>
