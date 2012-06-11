<?php
/**
 * Glyph image
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
 * include general iswa library
 */   
include 'bsw.php';
$code = $_REQUEST['code'];
$base = $_REQUEST['base'];
$key = $_REQUEST['key'];
$bsw = $_REQUEST['bsw'];
$size = $_REQUEST['size'];
$line = $_REQUEST['line'];
$fill = $_REQUEST['fill'];
$colorize = $_REQUEST['colorize'];
$name= $_REQUEST['name'];
if(!$name){$name='glyph';}
header("Content-type: image/png");
header('Content-Disposition: filename=' . $name . '.png');

include 'glyph_src.php';

imagepng($im);

?>

