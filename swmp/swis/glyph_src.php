<?php
/**
 * Glyph image source
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
//code, base, key, or bsw
if ($code){
  //determine BaseSymbol
  $base = intval(($code-1)/96)*96 + 1;
  $offset = $code-$base;
  $drot = $offset % 16;
  $dfill = ($offset-$drot)/16;
  $base = dechex(intval(($code-1)/96) + 256);
  $key = $base . dechex($dfill) . dechex($drot);
} else if ($base){
  $key = base2view($base);
} else if ($key){
  $base = substr($key,0,3);
} else if ($bsw){
  $base = substr($bsw,0,3);
  if (strlen($bsw)>3){
    $hfill = char2fill(substr($bsw,3,3));
    $hrot = char2rot(substr($bsw,6,3));
    $key = $base . $hfill . $hrot;
  } else {
    $key = base2view($base);
  }
} else {
  die();
}
$file = 'iswa/' . $base . '/' . $key . '.png';
$im_src = imagecreatefrompng($file);
if ($colorize) $line='';
if (!$colorize and !$line){$line = "000000";}
if ($line){
  list($r,$g,$b) = array_values(str_split($line,2));
  $r=hexdec($r);
  $g=hexdec($g);
  $b=hexdec($b);
  //2 for fill, 1 for line
  if (imagecolorstotal( $im_src)==1){
    $index=0;
  } else {
    $index=1;
  }
  imageColorSet($im_src,$index,$r,$g,$b);
}

if ($fill){
  list($r,$g,$b) = array_values(str_split($fill,2));
  $r=hexdec($r);
  $g=hexdec($g);
  $b=hexdec($b);
  //2 for fill, 1 for line
  if (imagecolorstotal( $im_src)==2){
    $index=0;
  } else {
    $index=2;
  }
  imageColorSet($im_src,$index,$r,$g,$b);
}

if ($size){
  $width = imagesx($im_src);
  $height = imagesy($im_src);
  $w = $width*$size;
  $h = $height*$size;
  $im = imagecreatetruecolor($w, $h);
 
  /* making the new image transparent */
  $background = imagecolorallocate($im, 254, 0, 0);
	ImageColorTransparent($im, $background); // make the new temp image all transparent
	imagealphablending($im, false); // turn off the alpha blending to keep the alpha channel
  imagesavealpha ($im, true );
	imagecopyresampled($im, $im_src, 0, 0, 0, 0, $w, $h, $width, $height);
} else {
  $im = $im_src;
}
?>
