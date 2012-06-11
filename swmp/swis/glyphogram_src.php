<?php
/**
 * Glyphogram image source
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
$bases=array();
$fills=array();
$rots=array();
$xs=array();
$ys=array();

if ($bsw){
  $bsw = bsw2cluster($bsw);
  $chars = str_split($bsw,3);
  $cnt = count($chars);
  for ($i=0;$i<$cnt;$i++){
    $bases[]=$chars[$i];
    $i++;
    $fills[]=char2fill($chars[$i]);
    $i++;
    $rots[]=char2rot($chars[$i]);
    $i++;
    $xs[]=hex2num($chars[$i]);
    $i++;
    $ys[]=hex2num($chars[$i]); 
  }
}
/**
 * Step 2: load images and determine size
 */  
$xMin=$xs[0];
$xMax=$xMin+2;
$yMin=$ys[0];
$yMax=$yMin+2;
$centering = 0;
foreach ($bases as $num=> $base) {
    $image="im$num";
    $file = 'iswa/' . $base . '/' . $base . $fills[$num] . $rots[$num] . '.png';
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

    //check for centering
    if (isHead(dechex($code)) or isTrunk(dechex($code))){
      if ($centering==0){
        $cxMin = $X;
        $cxMax = $X + $W;
        $cyMin = $Y;
        $cyMax = $Y + $H;
      } else {
        if ($cxMin > $X) { $cxMin=$X;}
        if ($cyMin > $Y) { $cyMin=$Y;}
        if ($cxMax < ($X+$W)) { $cxMax=$X+$W;}
        if ($cyMax < ($Y+$H)) { $cyMax=$Y+$H;}
      }
      $centering++;
    }
}

if ($centering){
  $cx = ($cxMin+$cxMax)/2;
  $cy = ($cyMin+$cyMax)/2;
  if ($bound=="c" || $bound=="h"){
    if (($cx-$xMin) > ($xMax-$cx)) {
      $xMax = $cx + ($cx - $xMin);
    } else {
      $xMin = $cx - ($xMax - $cx);
    }
  }

  if ($bound=="c" || $bound=="v"){
    if (($cy-$yMin) > ($yMax-$cy)) {
      $yMax = $cy + ($cy - $yMin);
    } else {
      $yMin = $cy - ($yMax - $cy);
    }
  }
}

//add pad
$xMax+=$pad;
$xMin-=$pad;
$yMax+=$pad;
$yMin-=$pad;

/**
 * Step 3: set up the base image
 */  
$im_base = imagecreatetruecolor($xMax-$xMin, $yMax-$yMin);

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
foreach ($bases as $num => $base) {
    $image="im$num";
    $W= ImageSX($$image);
    $H= ImageSY($$image);
    $X= $xs[$num];
    $Y= $ys[$num];

    ImageCopy($im_base, $$image, $X-$xMin, $Y-$yMin, 0, 0, $W, $H); 
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
  $width = imagesx($im_base);
  $height = imagesy($im_base);
  $w = $width*$size;
  $h = $height*$size;
  $im = imagecreatetruecolor($w, $h);


  $background = imagecolorallocate($im, 254, 0, 0);
  ImageColorTransparent($im, $background); // make the new temp image all transparent
 


  /* making the new image transparent */
  imagealphablending($im, false); // turn off the alpha blending to keep the alpha channel
  imagesavealpha ($im, true );
  imagecopyresampled($im, $im_base, 0, 0, 0, 0, $w, $h, $width, $height);
  ImageDestroy($im_base);
} else {
  $im = $im_base;
}

?>
