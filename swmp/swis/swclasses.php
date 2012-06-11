<?php
/**
 * SignWriting Classes library for PHP
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
 * key to png image
 */ 
function key2png($key){
  $base = substr($key,0,3);
  $file = 'iswa/' . $base . '/' . $key . '.png';
  $png = @file_get_contents($file);
  return $png;
}

/**
 * Symbol Class
 */ 
class Symbol {
  private $base;
  private $key;
  private $bsw;
  private $png;
  private $width;
  private $height;
  private $centerX;
  private $centerY;

  public function __construct($cSym) {
    switch(strlen($cSym)){
      case 3:
        $this->base = $cSym;
        $this->key = base2view($cSym);
        $this->bsw = key2bsw($this->key);
        break;
      case 5:
        $this->base = substr($cSym,0,3);
        $this->key = $cSym;
        $this->bsw = key2bsw($this->key);
        break;
      case 9:
        $this->base = substr($cSym,0,3);
        $this->key = bsw2key($cSym);
        $this->bsw = $cSym;
        break;
    }
    $this->png = key2png($this->key);
    $img = imagecreatefromstring($this->png); 
    $this->width = ImageSX($img);
    $this->height = ImageSY($img);
    $this->centerX = ImageSX($img)/2;
    $this->centerY = ImageSY($img)/2;
    imagedestroy($img);
  }

  public function getPNG(){
    return $this->png;
  }

  public function getWidth(){
    return $this->width;
  }

  public function getHeight(){
    return $this->height;
  }

  public function getCenterX(){
    return $this->centerX;
  }

  public function getCenterY(){
    return $this->centerY;
  }

}

/**
 * Sign Class
 */ 
class Sign {
  private $bsw;
  private $lane;
  private $cluster;
  private $seq;

  private $width;
  private $height;
  private $centerX;
  private $centerY;

  public function __construct($bsw) {
    $this->bsw = $bsw;
    $this->lane = substr($bsw,0,3);
    $this->cluster = bsw2cluster($bsw);
    $this->seq = bsw2seq($bsw);

    /**
     * Step 1: break apart
     */  
    $keys=array();
    $xs=array(); // x position
    $ys=array(); // y position
    $ws=array(); // width
    $hs=array(); // height

    $bsw = bsw2cluster($bsw);
    $chars = str_split($bsw,3);
    $cnt = count($chars);
    if ($bsw!=""){
      for ($i=0;$i<$cnt;$i++){

        $char = $chars[$i];
        $i++;

        $fill = char2fill($chars[$i]);
        $i++;

        $rot = char2rot($chars[$i]);
        $key = $char . $fill . $rot;
        $keys[]=$key;
        $i++;

        $xs[]=hex2num($chars[$i]);

        $i++;

        $ys[]=hex2num($chars[$i]); 


        $sym = new Symbol($key);
        $ws[] = $sym->getWidth();
        $hs[] = $sym->getHeight();
      }


      /**
       * Step 2: determing width, height, and center
       */
      $xMin=$xs[0];
      $xMax=$xMin+2;
      $yMin=$ys[0];
      $yMax=$yMin+2;
      $cxMin=0;
      $cxMax=0;
      $cyMin=0;
      $cyMax=0;
      $centering=0; // centering count

    } else { //make up values
      $xMin=0;
      $xMax=$xMin+2;
      $yMin=0;
      $yMax=$yMin+2;
      $cxMin=0;
      $cxMax=0;
      $cyMin=0;
      $cyMax=0;
      $centering=0; // centering count
    }

    foreach ($keys as $num=> $key) {
      $base = substr($key,0,3);
      $W= $ws[$num];
      $H= $hs[$num];
      $X= $xs[$num];
      $Y= $ys[$num];
      if ($xMin > $X) { $xMin=$X;}
      if ($yMin > $Y) { $yMin=$Y;}
      if ($xMax < ($X+$W)) { $xMax=$X+$W;}
      if ($yMax < ($Y+$H)) { $yMax=$Y+$H;}
      //check for centering
      if (isHead($base) or isTrunk($base)){
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
    $this->width = $xMax - $xMin;
    $this->height = $yMax - $yMin;
    if ($centering){
      $this->centerX = ($cxMin + $cxMax)/2 - $xMin;
      $this->centerY = ($cyMin + $cyMax)/2 - $yMin;
    } else {
      $this->centerX = ($xMin + $xMax)/2;
      $this->centerY = ($yMin + $yMax)/2;
    }
    //rebuild bsw with zero relative x and y
    $this->bsw = $this->lane;
    foreach ($keys as $num=> $key) {
      $this->bsw .= key2bsw($key);
      $X= $xs[$num];
      $this->bsw .= num2hex($X-$xMin);//$this->centerX);
      $Y= $ys[$num];
      $this->bsw .= num2hex($Y-$yMin);//$this->centerY);
    }

//already zero based
//    $this->centerX -= $xMin;
//    $this->centerY -= $yMin;
    if ($this->seq) $this->bsw.='0fd' . $this->seq;
  }
  public function getBSW(){
    return $this->bsw;
  }

  public function getWidth(){
    return $this->width;
  }

  public function getHeight(){
    return $this->height;
  }

  public function getCenterX(){
    return $this->centerX;
  }

  public function getCenterY(){
    return $this->centerY;
  }
}

/**
 * SignText Class
 */ 
class SignText {
  private $bsw;
  private $size=1;
  private $width=250;  // column width
  private $height=1919; // column height

  private $offset=50; // lane offset
  private $padding=45; // height padding
  private $spacing=10; // sign spacing 
  //(2 between signs, 1 sign to punc, 3 punc to sign)

  private $cols = array();//array of bsw adjusted segments for height
  private $posX = array();//array of arrays for x positions
  private $posY = array();//array of arrays for y positions

  public function __construct($bsw,$size=1,$height=1919,$spacing=10,$offset=50) {
    //set variables//
    $this->bsw = $bsw;
    $this->size = $size;
    $this->height = $height/$size;
    $this->spacing = $spacing;
    $this->offset = $offset;
    $this->units = bsw2unit($bsw);

    //init variables
    $curH = $this->padding;
    $prev = '';
    $col = '';
    $posX = array();
    $posY = array();
    //punc vs sign, spacing and lanes
    $prev='';

    $cnt = count($this->units);
    for ($i=0;$i<$cnt;$i++){

      $unitbsw = $this->units[$i];
      $chars = str_split($unitbsw,3);
      $first = $chars[0];
      //unit type for spacing test later
      if  (isPunc($first)){
        $cur="P";//punctuation
        $lane=0;
      } else {
        $cur="S";//sign
        $lane = char2lane($first);
      }
      //adjust padding based on punc/sign order
      switch ($prev . $cur){
      case 'SS'://sign sign
        $padding = $this->spacing*2;
        break;
      case 'SP'://sign punctuation
      case 'PP'://punctuation punctuation
        $padding = $this->spacing;
        break;
      case 'PS'://punctuation sign
        $padding = $this->spacing*3;
        break;
      default:
        $padding = 0;
      }
      $prev = $cur;

      if ($cur=="P"){
        $unit = new Symbol($unitbsw); 
      } else {
        $unit = new Sign($first . bsw2cluster($unitbsw));
        $unitbsw = $unit->getBSW();
      }
      if (($curH + $padding + $unit->getHeight())<$this->height){
        //go ahead and add
        $col .= $unitbsw;
        //this is the value to center
        $posX[] = ($unit->getCenterX()) - ($this->offset * $lane);
        $posY[] = $curH + $padding;
        $curH += $padding + $unit->getHeight();
      } else {
        //finalize column list
        $this->cols[]=$col;
        $this->posX[] = $posX;
        $this->posY[] = $posY;
        $col='';
        $posX = array();
        $posY = array();
        $curH = $this->padding;
        $prev = '';
        $i--;
      }
        
    }
    if ($col) {
      $this->cols[] = $col;
      $this->posX[] = $posX;
      $this->posY[] = $posY;
    }
  }
  
  public function getCols() {
    return $this->cols;
  }

  public function getPosX() {
    return $this->posX;
  }

  public function getPosY() {
    return $this->posY;
  }

  public function getWidth(){
    return $this->width;
  }

  public function getHeight(){
    return $this->height;
  }
  
}
?>
