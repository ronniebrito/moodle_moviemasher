<?php
/**
 * SignWriting MediaWiki Plugin 
 * 
 * Copyright 2007-2010 Stephen E Slevinski Jr
 * Steve (Slevin@signpuddle.net)
 * 
 * This file is part of SWMP: the SignWriting MediaWiki Plugin.
 * 
 * SWMP is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * SWMP is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with SWMP.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * END Copyright
 *  
 * @copyright 2007-2010 Stephen E Slevinski Jr 
 * @author Steve (slevin@signpuddle.net)  
 * @license http://www.opensource.org/licenses/gpl-3.0.html GPL
 * @access public
 * @package SWMP 
 * @version 1.2.2
 * @filesource
 *   
 */

include 'swis/bsw.php';
include 'swis/swclasses.php';

$wgSWMPVersion = '1.2.2';
$wgExtensionCredits['parserhook'][]=array(
	'name' => 'SignWriting MediaWiki Plugin',
	'version' => $wgSWMPVersion,
	'author' => 'Stephen E Slevinski Jr',
	'url' => 'http://www.signpuddle.net/swmp',
	'description' => 'This Extension adds SignWriting support to MediaWiki'
	);

// utf-8 plane 15 transformation
$wgHooks['ParserBeforeStrip'][] = 'fnSWMPHook';
function fnSWMPHook(&$parser, &$text, &$stripState){

//plane 15 UTF-8 with white space
$patternMany ='/[\x{FD800}-\x{FDCFF}]+[ +[\x{FD800}-\x{FDCFF}]+]*/u';
$patternOne ='/[\x{FD800}-\x{FDCFF}]/u';

if (preg_match_all($patternMany, $text,$matches)) {
  forEach ($matches[0] as $match){
    $text = str_replace($match,"<signtext>" . utf2bsw($match) . "</signtext>",$text);
  }
}
  
  return true;
}

$wgExtensionFunctions[] = 'efSWMPSetupSym';
$wgExtensionFunctions[] = 'efSWMPSetupSign';
$wgExtensionFunctions[] = 'efSWMPSetupSignBox';
$wgExtensionFunctions[] = 'efSWMPSetupSignText';
$wgExtensionFunctions[] = 'efSWMPSetupSeq';

function efSWMPSetupSym() {
	global $wgParser;
	$wgParser->setHook('sym','efSWMPRenderSym');
}

function efSWMPSetupSign() {
	global $wgParser;
	$wgParser->setHook('sign','efSWMPRenderSign');
}

function efSWMPSetupSignBox() {
	global $wgParser;
	$wgParser->setHook('signbox','efSWMPRenderSignBox');
}

function efSWMPSetupSignText() {
	global $wgParser;
	$wgParser->setHook('signtext','efSWMPRenderSignText');
}

function efSWMPSetupSeq() {
	global $wgParser;
	$wgParser->setHook('seq','efSWMPRenderSignSeq');
}

function efSWMPRenderSym ( $input, $args, $parser ) {
	global $wgScriptPath;
	$output = '<img src="' . $wgScriptPath . '/extensions/swmp/swis/glyph.php?bsw=';
	$output .= $input;
	$output .= '">';
	return $output;
}

function efSWMPRenderSign( $input, $args, $parser ) {
	global $wgScriptPath;
	$input = preg_replace('/\s+/m' , '', $input);
	$parser->disableCache();//should solve caching problem.
	$output = '<table cellpadding=5>';
	
	$output .= '<tr><td>';
	$output .= '<img src="' . $wgScriptPath . '/extensions/swmp/swis/glyphogram.php?bsw=';
	if ($input){
		$output .= $input;
	} else {
		$output .= '0fb10038d39b49c4a110038d3934b4498&size=.4';
	}
	$output .= '">';
	$output .= '</td></tr></table>';
	
	# sneak past the parser due to added <p>'s
	return $output;
}

function efSWMPRenderSignText( $input, $args, $parser ) {
	global $wgScriptPath;
	$input = preg_replace('/\s+/m' , '', $input);
	$parser->disableCache();//should solve caching problem.
	$output = '<table cellpadding=5>';
	
	$output .= '<tr><td>';
        $size = .7;
        $height = 400;
        //quick hack so scripts works
        chdir('extensions/swmp/swis');
        $st = new SignText($input,$size,$height);
        chdir('../../..');
        $cols = $st->getCols();
        $cnt = count($cols);
        $pre = '<div class="signtextcolumn" ';
        //should be in style sheet
        $pre .= 'style="position: relative;float:left;padding:10px;border: 2px #cccccc solid;">';
        $pre .= '<img src="' . $wgScriptPath . '/extensions/swmp/swis/column.php?size=' . $size;
        if ($cnt>1) $pre .= '&height=' . $height;
        foreach ($cols as $col){
          $output .= $pre . '&bsw=' . $col . '"></div>';
        }
        if ($cnt==0){
	  $output .= '<div class="signtextcolumn" ';
          $output .= 'style="position: relative;float:left;padding:10px;border: 2px #cccccc solid;">';
	  $output .= '<img src="' . $wgScriptPath . '/extensions/swmp/swis/glyphogram.php?bsw=0fb10038d39b49c4a110038d3934b4498&size=.4"></div>';
	}
	$output .= '</td></tr></table>';
	
	# sneak past the parser due to added <p>'s
	return $output;
}

function efSWMPRenderSignBox( $input, $args, $parser ) {
	global $wgScriptPath;
	$output = '<img src="' . $wgScriptPath . '/extensions/swmp/swis/glyphogram.php?bsw=';
	if ($input){
		$output .= $input;
	} else {
		$output .= '0fb10038d39b49c4a110038d3934b4498&size=.4';
	}
	$output .= '">';
	return $output;
}

function efSWMPRenderSignSeq( $input, $args, $parser ) {
	global $wgScriptPath;
	$output ='<table border="1" cellpadding="5">' . "\n";
	$input = bsw2iswa($input);
        $seq = str_split($input,9);
	foreach ($seq as $bsw) {
		$output .='<tr><td>';
		$output .= '<img src="' . $wgScriptPath . '/extensions/swmp/swis/glyph.php?bsw=' . $bsw . '&size=.7&line=999999">' . "\n";
		$output .='</td></tr>' . "\n";
	}
	$output .= '</table>' . "\n";
	return $output;
}

function efSWMPRenderSignSeqBR( $input, $args, $parser ) {
	global $wgScriptPath;
	$seq = explode(",",trim($input));
	foreach ($seq as $code) {
		$output .= '<img src="' . $wgScriptPath . '/extensions/swmp/swis/glyph.php?code=' . $code . '&size=.7&line=999999"><br/>' . "\n";
	}
	return $output;
}
?>
