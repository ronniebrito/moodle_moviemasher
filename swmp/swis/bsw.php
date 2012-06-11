<?php
/**
 * BSW Library for PHP
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

$hello = "0fb14c38e3924ba4b027138c3984d04c2";
$hello_seq = "0fd14c38e39227138c398";
$world = "0fb18738c39c4c24d918738c3934bb4c320538c3924d34c62ef38c3924cb4af";
$world_seq = "0fd18738c39318738c39c2ef38c39220538c392";
$period = "38838c392";
$hello_world = $hello . $world . $period;

$sg_list = array('100','10e','11e','144','14c','186','1a4','1ba','1cd','1f5', '205','216','22a','255','265','288','2a6','2b7','2d5','2e3', '2f7', '2ff','30a','32a','33b','359', '36d','376', '37f', '387');

function hex2bin($str) {
    $bin = "";
    $i = 0;
    do {
        $bin .= chr(hexdec($str{$i}.$str{($i + 1)}));
        $i += 2;
    } while ($i < strlen($str));
    return $bin;
}

function num2hex($num){
  return dechex($num+1229);
}

function hex2num($hex) {
  return hexdec($hex) - 1229;
} 

function bsw2base($bsw){
  $bsw_base = '';
  $chars = str_split($bsw,3);
  sort($chars,SORT_STRING);
  forEach($chars as $char){
    if(isISWA($char)){
      $bsw_base .= $char;
    }
  }
  return $bsw_base;
}

function base2view($base){
  $view = $base . '00';
  if (isHand($base)){
    if(!isSymGrp($base)){
      $view = $base . '10';
    }
  }
  return $view;
}

function base2group($base){
  global $sg_list;
  foreach ($sg_list as $group){
    if (hexdec($base)==hexdec($group)) return $group;
    if (hexdec($base)<hexdec($group)) return $prev;
    $prev = $group;
  }
  return $group;
}

function key2bsw($key){
  $base = substr($key,0,3);
  $fill = substr($key,3,1);
  $rot = substr($key,4,1);
  return $base . fill2char($fill) . rot2char($rot);
}

function bsw2key($bsw){
  $base = substr($bsw,0,3);
  $fill = substr($bsw,3,3);
  $rot = substr($bsw,6,3);
  return $base . char2fill($fill) . char2rot($rot);
}

function bsw2iswa($bsw){
  if ($bsw=="")return;
  $chars = str_split($bsw,3);
  $iswa_chars = '';
  $char = '';
  for ($i=0; $i<count($chars); $i++) {
    $char = $chars[$i];
    if(isISWA($char)){
      $iswa_chars .= $char;
      $i++;
      $iswa_chars .= $chars[$i];
      $i++;
      $iswa_chars .= $chars[$i];
    }
  }
  return $iswa_chars; 
}

function dec2utf($code,$plane=1){
  $a = $code%64;
  $b = floor($code/64);
  $c = floor($b/64);
  $b -= $c*64;
  
  switch($plane){
  case 1:
    $utf8 = "f0";
    $utf8 .= dechex($c + 144);//90
    $utf8 .= dechex($b + 128);//80
    $utf8 .= dechex($a + 128);//80
    break;
  case 15:
    $utf8 = "f3";
    $utf8 .= dechex($c + 176);//B0
    $utf8 .= dechex($b + 128);//80
    $utf8 .= dechex($a + 128);//80
    break;
  case 16:
    $utf8 = "f4";
    $utf8 .= dechex($c + 128);//80
    $utf8 .= dechex($b + 128);//80
    $utf8 .= dechex($a + 128);//80
    break;
  }

  return pack("N",hexdec($utf8));
}

function char2utf($char,$plane=15){
  $code = hexdec($char)+55046;//primary shift
  return dec2utf($code,$plane);
}

function bsw2utf($bsw, $plane=15){
  $bsw_utf = '';
  $chars = str_split($bsw,3);
  forEach($chars as $char){
    $bsw_utf .= char2utf($char,$plane);
  }
  return $bsw_utf;
}

function utf2char($unichar){
  $chars = str_split($unichar,2);
  $plane = $chars[0];
  switch($plane){
    case "f0":
      $a = hexdec($chars[1])-144;
      $b = hexdec($chars[2])-128;
      $c = hexdec($chars[3])-128;
      break;
    case "f3":
      $a = hexdec($chars[1])-176;
      $b = hexdec($chars[2])-128;
      $c = hexdec($chars[3])-128;
      break;
    case "f4":
      $a = hexdec($chars[1])-128;
      $b = hexdec($chars[2])-128;
      $c = hexdec($chars[3])-128;
      break;
  }

  $code = $c + $b*64 + $a * 64 * 64 - 55046;
  if ($code < 256) {
    return '0' . dechex($code);
  } else { 
    return dechex($code);
  }
}

function utf2bsw($bsw_utf){
  $bsw = '';
//  $pattern ='/[\x{1d800}-\x{1dcff}][\x{fd800}-\x{fdcff}][\x{10d800}-\x{10dcff}]/u';
  $pattern ='/[\x{FD800}-\x{FDCFF}]/u';
  preg_match_all($pattern, $bsw_utf,$matches);
  forEach ($matches[0] as $uchar){
    $val = unpack("N",$uchar);
    $val = dechex($val[1]);
    $bsw = $bsw . utf2char($val);
  }
  return $bsw;
}

function char2lane($char){
  $lane = 0;
  switch ($char) {
    case "0fa"://left lane
      $lane=-1;
      break;
    case "0fc"://right lane
      $lane=1;
      break;
    default://center lane
      $lane=0;
      break;
  }
  return $lane;
}

function lane2char($lane){
  $char = "0fb";
  switch ($lane) {
    case -1://left lane
      $char="0fa";
      break;
    case 1://right lane
      $char="0fc";
      break;
    default://center lane
      $char="0fb";
      break;
  }
  return $char;
}

function char2fill($char){
  return dechex(hexdec($char)-908);
}

function fill2char($fill){
  return dechex(hexdec($fill)+908);
}

function char2rot($char){
  return dechex(hexdec($char)-914);
}

function rot2char($rot){
  return dechex(hexdec($rot)+914);
}

function inHexRange($start, $end, $char){
  if (hexdec($char)>=hexdec($start) and hexdec($char)<=hexdec($end)){
    return true;
  } else {
    return false;
  }
}

function isControl($char){
  return inHexRange("fa","ff",$char); 
}

function isISWA($char){
  return inHexRange("100","38b",$char); 
}
function isHand($char){
  return inHexRange("100","204",$char); 
}
function isMove($char){
  return inHexRange("205","2f6",$char); 
}
function isDyn($char){
  return inHexRange("2f7","2fe",$char); 
}
function isHead($char){
  return inHexRange("2ff","36c",$char); 
}
function isTrunk($char){
  return inHexRange("36d","375",$char); 
}
function isLimb($char){
  return inHexRange("376","37e",$char); 
}
function isSeq($char){
  return inHexRange("37f","386",$char); 
}
function isPunc($char){
  $first_char = substr($char,0,3);
  return inHexRange("387","38b",$first_char); 
} 
function isFill($char){
  return inHexRange("38c","391",$char); 
} 
function isRot($char){
  return inHexRange("392","3a1",$char); 
} 
function isNum($char){
  return inHexRange("3a2","5f9",$char); 
}

function isSymGrp($char){
  global $sg_list;
  return in_array($char,$sg_list);
}

function char2token($char){
  $token = '-';
  switch ($char) {
    case "0fa"://left lane
      $token = 'L';
      break;
    case "0fb":// sign box
      $token = 'B';
      break;
    case "0fc"://right lane
      $token = 'R';
      break;
    case "0fd"://sequence
      $token = 'Q';
      break;
  }
  if (isHand($char)) $token = 'h';
  if (isMove($char)) $token = 'm';
  if (isDyn($char)) $token = 'd';
  if (isHead($char)) $token = 'f';
  if (isTrunk($char)) $token = 't';
  if (isLimb($char)) $token = 'x';
  if (isSeq($char)) $token = 's';
  if (isPunc($char)) $token = 'P';
  if (isFill($char)) $token = 'i';
  if (isRot($char)) $token = 'o';
  if (isNum($char)) $token = 'n';
  return $token;
}

function bsw2token($bsw){
  $chars = str_split($bsw,3);
  $key='';
  forEach($chars as $char){
    $key .= char2token($char);
  }
  return $key;
}

function validBSW($bsw){
  $tokens = bsw2token($bsw);
  $pattern = '/^([LBR]([hmdftx]ionn)*(Q([hmdftxs]io)+)?|Pio)+$/i';
  return preg_match($pattern,$tokens);
}

function tokensplit($bsw,$tokenmatch){
  $tokens = bsw2token($bsw);
  $cursor = 0;
  $bsw_array = array();
  forEach ($tokenmatch as $match){
    $len = strlen($match);
    if ($len) {
      $bswd = substr($bsw,$cursor,$len*3);
      $bsw_array[]=$bswd;
      $cursor += $len*3;
    }
  }
  return $bsw_array;
}

function bsw2segment($bsw){
  $tokens = bsw2token($bsw);
  $pattern = '/([LBR]([hmdftx]ionn)*(Q([hmdftxs]io)+)?)*(Pio)?/i';
  preg_match_all($pattern,$tokens,$matches);
  return tokensplit($bsw,$matches[0]);
}

function bsw2unit($bsw){
  $tokens = bsw2token($bsw);
  $pattern = '/(([LBR]([hmdftx]ionn)*(Q([hmdftxs]io)+)?)|Pio)/i';
  preg_match_all($pattern,$tokens,$matches);
  return tokensplit($bsw,$matches[0]);
}

function bsw2spaced($bsw){
  if ($bsw=="")return;
  $bsw = str_replace(" ","",$bsw);
  $bsw = str_replace("\n","",$bsw);
  $bsw = str_replace("\r","",$bsw);
  $bsw = str_replace("\t","",$bsw);
  if (!validBSW($bsw)){return;}
  $units = bsw2unit($bsw);
  $spaced = '';
  forEach ($units as $unit){ 
    $spaced .= ' ' . $unit;
  }
  return trim($spaced);
}

function bsw2cluster($bsw){
  $tokens = bsw2token($bsw);
  $pattern = '/([hmdftx]ionn)+/i';
  preg_match($pattern,$tokens,$match);
  $pos = strpos($tokens,$match[0]);
  $len = strlen($match[0]);
  return substr($bsw,$pos*3,$len*3);
}

function bsw2seq($bsw){
  $tokens = bsw2token($bsw);
  $pattern = '/Q([hmdftxs]io)+/i';
  preg_match($pattern,$tokens,$match);
  if ($match[0]){
    $pos = strpos($tokens,$match[0]);
    $len = strlen($match[0]);
    $seq = substr($bsw,3+$pos*3,$len*3);
  } else {
    $seq = "";
  }
  return $seq;
}

function moveBSW($bsw,$mx,$my){
  if (isPunc($bsw)) return $bsw;
  $first = substr($bsw,0,3);
  $cluster = bsw2cluster($bsw);
  $seq = bsw2seq($bsw);

  $chars = str_split($cluster,3);
  $bsw = $first;
  for ($i=0; $i<count($chars); $i++) {
    //sym as base,fill,rot
    $bsw .= $chars[$i++];
    $bsw .= $chars[$i++];
    $bsw .= $chars[$i++];

    //move x and y
    $x = $chars[$i++];
    $bsw .= num2hex(hex2num($x)-$mx);
    $y = $chars[$i];
    $bsw .= num2hex(hex2num($y)-$my);
  }
  if ($seq) $bsw.= '0fd' . $seq;
  return $bsw;
}

function locationsplit($bsw,$iPunc,$iSign){
//needs cleaned up and simplified
  $bsw_array = array();
  $preLoc = '';
  $unitLoc = '';
  $postLoc = '';

  $segs = bsw2segment($bsw);
  forEach ($segs as $i=>$seg){ 
    if ($i<$iPunc) {
      if( ($i == ($iPunc-1)) and ($iSign==0)){
        //special case to return punc
        $units = bsw2unit($seg);
        forEach($units as $j=>$unit){
          if (($j+1)<count($units)) {
            $preLoc .= $unit;
          } else {
            $unitLoc = $unit;
          }
        }
       } else {
        $preLoc .= $seg;
      }
    } else if ($i>$iPunc) {
      $postLoc .= $seg;
    } else {  //i == iPunc
      $units = bsw2unit($seg);
      forEach($units as $j=>$unit){
        if (($j+1)<$iSign) {
          $preLoc .= $unit;
        } else if (($j+1)>$iSign) {
          $postLoc .= $unit;
        } else {  //(j+1) == iSign
          $unitLoc = $unit;
        }
      }
    }
  } 
  $bsw_array[]=$preLoc;
  $bsw_array[]=$unitLoc;
  $bsw_array[]=$postLoc;
  return $bsw_array;
}
?>
