<?php
/**
 * Javascript ISWA key
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

include 'iswa.php';
$subset = $_REQUEST['subset'];
$iswa = new ISWA($subset);

$sgs = $iswa->getSymbolGroups();
$bss = $iswa->getBaseSymbols();

$sg = array_shift($sgs);
$sg_code = $sg['code'];
$keys = array();
$i=0;
$keys[$i]=array();

foreach ($bss as $code => $bs){
  if ($bs['group']<>$sg_code){
    $i++;
    $sg_code = $bs['group']; 
    $keys[$i]=array();
  }
  $line = '    ["';
  $line .= $bs['code'] . '","';
  $line .= $bs['view'] . '",';
  $line .= $bs['sid_v'] . ',';
  $line .= $bs['vars'] . ',';
  $line .= $bs['fills'] . ',';
  $line .= $bs['rots'];
  $line .= ']';

  $keys[$i][]=$line;
}

echo 'var keys = [' . "\n";
echo '  [' . "\n";
$sgdata=array();
foreach ($keys as $code => $suba){
  $sgdata[] = implode(',' . "\n",$suba);
}
echo implode("\n" . '  ],[' . "\n", $sgdata);
echo "\n" . '  ]' . "\n";//end symbol group
echo '];' . "\n";//end key
?>
