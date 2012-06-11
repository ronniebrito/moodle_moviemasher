<?php
/**
 * x-ISWA-2010 code pages
 *
 * WARNING * hasn't been updated for BSW 3
 * started, but not finished.
**/
die("Needs BSw 3");
/**
 *
 * Copyright 2007-2010 Stephen E Slevinski Jr
 * Steve (Slevin@signpuddle.net)
 * 
 * This file is part of SWIS: the SignWriting Image Server
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
 * @version 1.0.0
 * @filesource
 */

/**
 * include general iswa library
 */   
include 'iswa.php';
$subset = $_REQUEST['subset'];
$iswa = new ISWA($subset);
$SymbolGroups = $iswa->getSymbolGroups();
$BaseSymbols = $iswa->getBaseSymbols();

/**
 * Flag Description function
 */   
function flagDesc($flags){
echo $flags;
  $flags=str_split($flags,1);
  foreach($flags as $i=>$flag){
    switch($flag){
    case "h":
      $flags[$i]="Hand";
      break;
    case "m":
      $flags[$i]="Movement";
      break;
    case "d":
      $flags[$i]="Dynamic";
      break;
    case "f":
      $flags[$i]="Head";
      break;
    case "t":
      $flags[$i]="Trunk";
      break;
    case "x":
      $flags[$i]="Limb";
      break;
    case "P":
      $flags[$i]="Punctuation";
      break;
    case "s":
      $flags[$i]="Sequence";
      break;
    }
  }
  return implode($flags,', ');
}

/**
 * input variables
 */
$sg_char= $_REQUEST['sg_char']; //SymbolGroup code
$bs_char= $_REQUEST['bs_char'];//BaseSymbol code
$ccd = $_REQUEST['ccd'];//character code decimal
$cch = $_REQUEST['cch'];//character code hex
$sid = $_REQUEST['sid'];//symbol id

if ($ccd){$sg_char = $iswa->base2group(dechex($ccd));$bs_code=dechex($ccd);}
if ($cch){$sg_char = $iswa->base2group($cch);$bs_code=$cch;}
if ($sid){
  $key = $iswa->id2key($sid);
  if ($key){
    $base = substr($key,0,3);
    $sg_char = $iswa->base2group($base);
    $bs_char = $base;
  }
}
//END input vars//

//force SymbolGroup and BaseSymbol
if ($bs_char<>"" and $sg_char==""){ 
  if($bs_char<>"*"){$sg_char = $iswa->base2group($bs_char);}
}

//
// Header
//
echo '<htm><head></head><body>' . "\n";
echo '<center><h1>x-ISWA-2010 Code Pages</h1>' . "\n";
//END Header//

//
//sub header
//
echo '<table cellpadding=20><tr><td>' . "\n";
echo '<form action="data.php" method=get>' . "\n";
echo '<input type=hidden name="subset" value="' . $subset . '">' . "\n";
echo '<input type=hidden name="sg_char" value="*">' . "\n";
echo '<input type=submit value="All SymbolGroups">' . "\n";
echo '</form>' . "\n";

echo '</td><td>' . "\n";

echo '<form action="data.php" method=get>' . "\n";
echo '<input type=hidden name="subset" value="' . $subset . '">' . "\n";
echo '<input type=hidden name="bs_code" value="*">' . "\n";
echo '<input type=submit value="All BaseSymbols">' . "\n";
echo '</form>' . "\n";

echo '</td></tr></table>' . "\n";
//END sub header//

//search form// 
echo '<form action="data.php" method=get>' . "\n";
echo '<input type=hidden name="subset" value="' . $subset . '">' . "\n";
echo '<table cellpadding=5><tr><th>Character Code</th>' . "\n";
echo '<th>Hexideciamal</th><th>Symbol ID</th><th></th></tr><tr>' . "\n";
echo '<td><input name="ccd" value="' . $ccd . '"></td>' . "\n"; echo '<td><input name="cch" value="' . $cch . '"></td>' . "\n";
echo '<td><input name="sid" value="' . $sid . '"></td>' . "\n";
echo '<td><input name="action" type=submit value="Search"></td>' . "\n";
echo '</tr>' . "\n";
echo '</table>';
echo '</form>';
//END search form//

echo '</center><p><hr><p>';
//END input form//

//
//Gather Data for All SymbolGroups
//
if ($sg_char=="*"){
  echo '<h2>SymbolGroup Data</h2>';

  //Data prep for grid ($row)//
  $SGgrid=array();
  foreach ($SymbolGroups as $char => $sg){
    $row=array();
    $row[]= '<center><img src="glyph.php?key=' . $sg['view'] . '"></center>';
    $row[]= 'SymbolGroup ' . ($sg['num']);
    $row[]=$sg['name'];
    $row[]=hexdec($char);
    $row[]= $char;
    $row[]=$iswa->key2id($char,2);
    $row[]=flagDesc($sg['token']);
    $row[]=$sg['bases'];
    $row[]=$sg['color'];
    $SGgrid[]=$row;
  }
} else { 
//END Gather Data for All SymbolGroups//

//
//Lookup Data for SymbolGroup//
//

  if ($sg_char){
  if (!$iswa->validkey($sg_char)){die();}
  $SymbolGroup = $SymbolGroups[$sg_char];
  
  $keys = array_keys($SymbolGroups);
  foreach($keys as $index=>$key){
    if (intval($key) == intval($sg_char)){break;}
  }
  //add scanning buttons//
  $first = $keys[0];
  $prev=$first;
  $last = $keys[(count($SymbolGroups)-1)];
  $next = $last;
  if ($index>0) {$prev = $keys[$index-1];}
  if ($index < count($keys)-1) {$next = $keys[$index+1];}
  echo '<table cellpadding=10><tr><td>' . "\n";
  echo '<h2 id="sgd">SymbolGroup ' . ($SymbolGroup['num']) . ' Data</h2>';

  echo '</td><td>' . "\n";

  echo '<form action="data.php#sgd" method=get>' . "\n";
  echo '<input type=hidden name="subset" value="' . $subset . '">' . "\n";
  echo '<input type=hidden name="sg_char" value="' . $first . '">' . "\n";
  echo '<input type=hidden name="bs_code" value="*">' . "\n";
  echo '<input type=submit value="<<">' . "\n";
  echo '</form>' . "\n";

  echo '</td><td>' . "\n";

  echo '<form action="data.php#sgd" method=get>' . "\n";
  echo '<input type=hidden name="subset" value="' . $subset . '">' . "\n";
  echo '<input type=hidden name="sg_char" value="' . $prev . '">' . "\n";
  echo '<input type=hidden name="bs_code" value="*">' . "\n";
  echo '<input type=submit value="<">' . "\n";
  echo '</form>' . "\n";

  echo '</td><td>' . "\n";

  echo '<form action="data.php#sgd" method=get>' . "\n";
  echo '<input type=hidden name="subset" value="' . $subset . '">' . "\n";
  echo '<input type=hidden name="sg_char" value="' . $next . '">' . "\n";
  echo '<input type=hidden name="bs_code" value="*">' . "\n";
  echo '<input type=submit value=">">' . "\n";
  echo '</form>' . "\n";

  echo '</td><td>' . "\n";

  echo '<form action="data.php#sgd" method=get>' . "\n";
  echo '<input type=hidden name="subset" value="' . $subset . '">' . "\n";
  echo '<input type=hidden name="sg_char" value="' . $last . '">' . "\n";
  echo '<input type=hidden name="bs_code" value="*">' . "\n";
  echo '<input type=submit value=">>">' . "\n";
  echo '</form>' . "\n";

  echo '</td></tr></table>' . "\n";
  //END sub header//


  $SGgrid=array();
  $row=array();

  $row[]= '<center><img src="glyph.php?code=' . $SymbolGroups[$sg_char]['view'] . '"></center>';
  $row[]= 'SymbolGroup ' . ($SymbolGroup['num']);
  $row[]=$SymbolGroup['name'];
  $row[]=dechex($sg_char);
  $hex = $sg_char;
  $row[]= $hex;
  $row[]=$iswa->key2id($sg_char,2);
  $row[]=flagDesc($SymbolGroup['flags']);
  $row[]=$SymbolGroup['bases'];
  $row[]=$SymbolGroup['color'];
  $SGgrid[]=$row;
  }
}
//END Lookup Data for SymbolGroup//

//
//Display SymbolGroup Data
//
if (count($SGgrid)){
  echo '<table border=1 cellpadding=3><tr><th>Symbol</th><th>SymbolGroup Number</th><th>Name</th><th>Character Code</th><th>Hex</th><th>Symbol ID</th><th>Type</th><th>Base Symbols</th><th>Standard Color</th></tr>';
  foreach ($SGgrid as $row){
    echo '<tr>';
    foreach ($row as $index => $cell){
      if ($index==1){
        echo '<td>' . '<a href="data.php?subset=' . $subset . '&sg_char=' . $row[3] . '&bs_code=*#sgd">' . "\n";
        echo $cell . '</a></td>';
      } else { 
        echo '<td>' . $cell . '</td>';
      }
    }
    echo '</tr>';
  }
  echo '</table><br><hr>';
}
//END Display SymbolGroup Data//

//
//Gather Data for All BaseSymbols
//
if ($bs_code=="*"){
  echo '<h2>BaseSymbol Data</h2>';

  //Data prep//
  $BSgrid=array();
  foreach ($BaseSymbols as $code=>$BaseSymbol){
    //skip if sg_sid not match
    $cat = "";$grp="";
    if ($sg_char<>""){
      if ($sg_char<>"*"){
        if ($sg_char == $iswa->base2group($code)){
          //nothing to do 
        } else {
          continue;
        }   
      }
    }
    $row=array();
    $row[]= '<center><img src="glyph.php?code=' . $BaseSymbol['view'] . '"></center>';
    $row[]='BaseSymbol '. ($BaseSymbol['num']);
    $row[]=$BaseSymbol['name'];
    $row[]=$code;
    $row[]=dechex($code);
    $row[]=$iswa->key2id($code,4);
    $vs=array();
    for ($v=0;$v<5;$v++){if (pow(2,$v) & $BaseSymbol['vars']){$vs[]=$v+1;}}
    if (count($vs)==1) {
      $row[]='NA';
    } else {
      $row[]=implode(',',$vs);
    }
    $fs=array();
    for ($f=0;$f<6;$f++){if (pow(2,$f) & $BaseSymbol['fills']){$fs[]=$f+1;}}
    $output .= implode(',',$fs);
    $row[] = implode(',',$fs);
    $rs=array();
    for ($r=0;$r<16;$r++){if (pow(2,$r) & $BaseSymbol['rots']){$rs[]=$r+1;}}
    $row[] = implode(',',$rs);
    $BSgrid[]=$row;
  }
} else if ($bs_code){
  //
  //Lookup Data for BaseSymbol//
  //
  if ($sg_char<>"" and $sg_char<>"*"){
//    if (!$iswa->validkey($bs_code)){die();}//valid symbols under invalid BS
    $BaseSymbol = $BaseSymbols[$bs_code];

    $SGkeys = array_keys($SymbolGroups);
    if($sg_char<>"*" and $sg_char<>""){
      foreach($keys as $SGindex=>$SGkey){
        if (intval($SGkey) == intval($sg_char)){break;}
      }
    } else {
      $sg_char = $SGkeys[0];
      $SGindex=0;
      $SGkey = $SGkey[0];
    }
  }
  $BSkeys = array_keys($BaseSymbols);
  foreach($BSkeys as $BSindex=>$BSkey){
    if (intval($BSkey) == intval($bs_code)){break;}
  }
  //add scanning buttons//
  if ($iswa->validkey($sg_char)){
    $first = $sg_char; 
  } else {
    $first = $SGkeys[0];
  }
  $prev=$first;
  if ($iswa->validkey($sg_char)){
    //check for valid key...
    if(($SGindex+1)==count($SGkeys)) {
      //last BaseSymbol
      $last = $BSkeys[count($BSkeys)-1];
    } else {
      //calculate last
      $last = $SGkeys[$SGindex+1]; 
      do {
        $last -= 96;
      } while (!array_key_exists($last,$BaseSymbols));
    }
  } else {
    $last = $BSkeys[(count($BaseSymbols)-1)];
  }
  $next = $last;
  if ($BSindex>0) {
    $prev = $bs_code; 
    do {
      $prev -= 96; 
    } while (!array_key_exists($prev,$BaseSymbols));
  }
  if ($BSindex < count($BSkeys)-1) {
    $next = $bs_code; 
    do {
      $next += 96;
      if ($next >65000) {$next=$last;}
    } while (!array_key_exists($next,$BaseSymbols));
  }
  if ($next>$last){$next=$last;}
  if ($prev<$first){$prev=$first;}

//  if ($index>0) {$prev = $keys[$index-1];}
//  if ($index < count($keys)) {$next = $keys[$index+1];}
  echo '<table cellpadding=10><tr><td>' . "\n";

  echo '<h2 id="bsd">BaseSymbol ' . ($BaseSymbol['num']) . ' Data</h2>';

  echo '</td><td>' . "\n";

  echo '<form action="data.php#bsd" method=get>' . "\n";
  echo '<input type=hidden name="subset" value="' . $subset . '">' . "\n";
  echo '<input type=hidden name="sg_char" value="' . $sg_char . '">' . "\n";
  echo '<input type=hidden name="bs_code" value="' . $first . '">' . "\n";
  echo '<input type=submit value="<<">' . "\n";
  echo '</form>' . "\n";

  echo '</td><td>' . "\n";

  echo '<form action="data.php#bsd" method=get>' . "\n";
  echo '<input type=hidden name="subset" value="' . $subset . '">' . "\n";
  echo '<input type=hidden name="sg_char" value="' . $sg_char . '">' . "\n";
  echo '<input type=hidden name="bs_code" value="' . $prev . '">' . "\n";
  echo '<input type=submit value="<">' . "\n";
  echo '</form>' . "\n";

  echo '</td><td>' . "\n";

  echo '<form action="data.php#bsd" method=get>' . "\n";
  echo '<input type=hidden name="subset" value="' . $subset . '">' . "\n";
  echo '<input type=hidden name="sg_char" value="' . $sg_char . '">' . "\n";
  echo '<input type=hidden name="bs_code" value="' . $next . '">' . "\n";
  echo '<input type=submit value=">">' . "\n";
  echo '</form>' . "\n";

  echo '</td><td>' . "\n";

  echo '<form action="data.php#bsd" method=get>' . "\n";
  echo '<input type=hidden name="subset" value="' . $subset . '">' . "\n";
  echo '<input type=hidden name="sg_char" value="' . $sg_char . '">' . "\n";
  echo '<input type=hidden name="bs_code" value="' . $last . '">' . "\n";
  echo '<input type=submit value=">>">' . "\n";
  echo '</form>' . "\n";

  echo '</td></tr></table>' . "\n";
  //END sub header//

  $BSgrid=array();
  $row=array();
  $row[]= '<center><img src="glyph.php?code=' . $BaseSymbol['view'] . '"></center>';
  $row[]='BaseSymbol '. ($BaseSymbol['num']);
  $row[]=$BaseSymbol['name'];
  $row[]=$bs_code;
  $row[]=dechex($bs_code);
  $row[]=$iswa->key2id($bs_code,4);
  $vs=array();
  for ($v=0;$v<5;$v++){if (pow(2,$v) & $BaseSymbol['vars']){$vs[]=$v+1;}}
  if (count($vs)==1) {
    $row[]='NA';
  } else {
    $row[]=implode(',',$vs);
  }
  $fs=array();
  for ($f=0;$f<6;$f++){if (pow(2,$f) & $BaseSymbol['fills']){$fs[]=$f+1;}}
  $row[] = implode(',',$fs);
  $rs=array();
  for ($r=0;$r<16;$r++){if (pow(2,$r) & $BaseSymbol['rots']){$rs[]=$r+1;}}
  $row[] = implode(',',$rs);
  $BSgrid[]=$row;
//END Lookup Data for BaseSymbol//
}

//
//Display BaseSymbol Data
//
if (count($BSgrid)){
  echo '<table border=1 cellpadding=3><tr><th>Symbol</th><th>BaseSymbol Number</th><th>Name</th><th>Character Code</th><th>Hex</th><th>Symbol ID</th><th>Variations</th><th>Valid Fills</th><th>Valid Rotations</th></tr>';
  foreach ($BSgrid as $row){
    echo '<tr>';
    foreach ($row as $index=>$cell){
      if ($index==1){
        echo '<td>' . '<a href="data.php?subset=' . $subset . '&';
        echo 'sg_char=' . $sg_char . '&bs_code=' .$row[3] . '#bsd">' . "\n";
        echo $cell . '</a></td>';
      } else { 
        echo '<td>' . $cell . '</td>';
      }
    }
    echo '</tr>';
  }
  echo '</table>';
}
$grid=array();
//END Display BaseSymbol Data//

//
//Display Code Page by BaseSymbol
//
if ($bs_code<>"" and $bs_code<>"*"){
//  if (!$iswa->validkey($bs_code)){die();}//valid symbols under invalid BS
  echo '<h2>BaseSymbol Code Page</h2>';
  //Data prep//
  $grid=array();
  for ($i=0;$i<96;$i++){
    $row=array();

    if ($iswa->validkey($bs_code+$i)){
      $row[]= '<center><img src="glyph.php?code=' . ($bs_code+$i) .'"></center>';
    } else {
      $row[]= '<b>invalid</b>';
    }
    $row[]=$bs_code+$i;
    $row[]=dechex($bs_code+$i);
    $row[]=$iswa->key2id($bs_code+$i);
    if (is_dir("sss")){
      $row[]= '<img src="sss/' . $iswa->key2id($bs_code+$i) . '.png">';
    } else {
      $row[]= '';
    }
    $grid[]=$row;
  }
  //
  //output BaseSymbol Code Page
  //
  echo '<table border=1 cellpadding=3><tr><th>Glyph</th><th>Character Code<br>Decimal</th><th>Character Code<br>Hexidecimal</th><th>Character Name</th></tr>';
  foreach ($grid as $row){
    echo '<tr>';
    foreach ($row as $cell){
      echo '<td>' . $cell . '</td>';
    }
    echo '</tr>';
  }
  echo '</table>';
}
//END Display Code Page//
?>
