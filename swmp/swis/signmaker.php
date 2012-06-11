<?php
/**
 * SignMaker Page
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
$lang='en';
include 'iswa.i18n.php';
include 'iswa.i18n.sym.php';
$msg = array_merge($messages[$lang],$symNames[$lang]);
include 'swis.i18n.php';
$msg = array_merge($messages[$lang],$msg);

echo '<html><head>';
echo '<link href="palette.css" rel="stylesheet" type="text/css" media="all">';
echo '<link href="signmaker.css" rel="stylesheet" type="text/css" media="all">';
$css = $_REQUEST['css'];
if ($css){
  echo '<link href="' . $css . '.css" rel="stylesheet" type="text/css" media="all">';
}
echo '<script type="text/javascript" src="MochiKit.js"></script>';
echo '<script type="text/javascript" src="bsw.js"></script>';
echo '<script type="text/javascript" src="swclasses.js"></script>';
echo '<script type="text/javascript" src="key.php?subset=' . $_REQUEST['subset'] . '"></script>';
echo '<script type="text/javascript" src="palette.js"></script>';
echo '<script language="Javascript">';
echo 'bsw = "' . $_REQUEST['bsw'] . '";' . "\n";
echo 'bsw = bsw.replace(/\s+/g, "");';
$bsw = $_REQUEST['bsw'];
echo 'sid = "' . $_REQUEST['sid'] . '";' . "\n";
echo 'acceptSM = "image_sign.php";' . "\n";
echo '</script>';
echo '<script type="text/javascript" src="signmaker.js"></script>';
echo '<script language="Javascript">';
echo 'connect(window, "onload", loadSignMaker);' . "\n";
echo '</script>';

echo '</head><body>';

include 'command.php';
//echo '<div id="command" class="command">';
//echo '&nbsp;';
//echo '</div>';

echo '<div class="palette">';
echo '</div>';
echo '<div id="detail" class="detail">';

$subhead = $msg['swis_signmaker'];
include 'header.php';
//  echo '<div id="header"></div>';

  echo '<br clear="all">';
  echo '<div id="signmaker">';
  //hacked borders due to IE positioning
    echo '<div id="signboxTop"></div>';
    echo '<div id="signboxLeft"></div>';
    echo '<div id="signbox"></div>';
    echo '<div id="signboxRight"></div>';
    echo '<div id="signboxBottom"></div>';
  echo '</div>';
  echo '<div id="sequence"></div>';
  echo '<div id="smcommand"></div>';
  echo '<br clear="all">';

  echo '<div id="footer"></div>';

echo '</div>';

echo '<div id="palette">';
echo '</div>';
echo '</body></html>';
?>
