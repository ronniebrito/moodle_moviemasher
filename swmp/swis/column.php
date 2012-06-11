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
$maxheight = 1919;
$bsw = $_REQUEST['bsw'];
$size = $_REQUEST['size'];
if(!$size){$size=1;}
$name = $_REQUEST['name'];
if(!$name){$name='column';}
$height  = $_REQUEST['height'];
if(!$height){$height=$maxheight;}
$width  = $_REQUEST['width'];
$offset = $_REQUEST['offset'];
if (!$offset){$offset='50';}
$top_pad = $_REQUEST['top_pad'];
if (!$top_pad){$top_pad=0;}
$spacing = $_REQUEST['spacing'];
if (!$spacing){$spacing='10';}
$col = $_REQUEST['col']-1;//col num to display
if($col==-1){$col=0;}
$line=$_REQUEST['line'];
$fill=$_REQUEST['fill'];
$back=$_REQUEST['back'];
$colorize= $_REQUEST['colorize'];

header("Content-type: image/png");
header('Content-Disposition: filename=' . $name . '.png');

include 'column_src.php';

ImagePNG($im); 
ImageDestroy($im);
?>
