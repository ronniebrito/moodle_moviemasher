<?php
/**
 * Glyphogram image
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
$bsw=$_REQUEST['bsw'];
$size=$_REQUEST['size'];
$pad=$_REQUEST['pad'];
$bound=$_REQUEST['bound'];
$name= $_REQUEST['name'];
if(!$name){$name='glyphogram';}
header("Content-type: image/png");
header('Content-Disposition: filename=' . $name . '.png');

/**
 * color options and transparency
 * 
 * 12 testing options
 * 3 line options - none (black), colorize, color 
 * 2 fill options - transparent or color    
 * 2 size options - 1 or other
 */
$line=$_REQUEST['line'];
$fill=$_REQUEST['fill'];
$back=$_REQUEST['back'];
$colorize= $_REQUEST['colorize'];

include 'glyphogram_src.php';

ImagePNG($im); 
ImageDestroy($im);
?>
