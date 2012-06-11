<?php
/**
 * Column image for sign text
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
 * include, attributes, and header
 */ 
include 'bsw.php';
include 'swclasses.php';
$bsw = $_REQUEST['bsw'];
$size = $_REQUEST['size'];
$height  = $_REQUEST['height'];
if(!$size){$size=1;}
if(!$height){$height=1919;}

echo '<html><head>';
echo '<link href="columns.css" rel="stylesheet" type="text/css" media="all">';
echo '</head><body>';

$st = new SignText($bsw,$size,$height);
$cols = $st->getCols();
$cnt = count($cols);
$pre = '<div class="signtextcolumn"><img src="column.php?size=' . $size;
if ($cnt>1) $pre .= '&height=' . $height;
foreach ($cols as $col){
  echo $pre . '&bsw=' . $col . '"></div>';
}
echo '</body></html>';
?>
