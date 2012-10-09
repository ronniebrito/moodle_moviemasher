<?php
require_once(dirname( dirname( dirname(dirname(dirname(dirname(dirname(dirname(__FILE__)))))))).'/config.php');


$cmid = (empty($_GET['cmid']) ? '' : $_GET['cmid']);

$mash_id= (empty($_GET['mash_id']) ? '' : $_GET['mash_id']);

//$mash= (empty($_GET['mash']) ? '' : $_GET['mash']);

$mash = file_get_contents('php://input');
$mash = str_replace('<moviemasher>','',$mash);
$mash = str_replace('</moviemasher>','',$mash);


$mashR = get_record('moviemasher_mash', 'id', $mash_id);

//$mash = str_replace("&", "e", $mash);
//$mash = addslashes($mash);


$mashR->mash =  $mash;

$mashR->timemodified = time();

update_record('moviemasher_mash', $mashR);

//export to tswml

$subject = stripslashes($mash);
$pattern = "/<clip.*?id=\"signboxeffect\".*?start=\"(.*?)\".*?bsw=\"(.*?)\".*?length=\"(.*?)\".*?\/>/is";

//$subject = '<clip type="effect" id="signboxeffect" track="3" start="50" length="4" label="Sign Writing" lengthseconds="legnsecs">		<clip type="image" id="sad" bsw="0fb33038d3924b84c130338c3944b84b618238d3994e64c42e238f3924e14e10fb30038c3984bb4bb30038c3964bb4bc20538c3924e34c620538c3924c64e211a38d3924d54e1" audio="0" label="SW" trimstart="0" track="-1" fill="scale" start="0" length="lenght"/>		</clip> <media group="image" type="image"  id="imgid" label="Frog" url="http://localhost/mod/moviemasher/temp/url.png" fill="crop" /><clip type="effect" id="signboxeffect" track="3" start="inicio" length="diuracao" label="Sign Writing" lengthseconds="legnsecs">		<clip type="image" id="sad" bsw="BSW" audio="0" label="SW" trimstart="0" track="-1" fill="scale" start="0" length="lenght"/>		</clip> <media group="image" type="image"  id="imgid" label="Frog" url="http://localhost/mod/moviemasher/temp/url.png" fill="crop" /><clip type="effect" id="signboxeffect" track="3" start="inicio3" length="diuracao" label="Sign Writing" lengthseconds="legnsecs">		<clip type="image" id="sad" bsw="BSW" audio="0" label="SW" trimstart="0" track="-1" fill="scale" start="0" length="lenght"/>		</clip> <media group="image" type="image"  id="imgid" label="Frog" url="http://localhost/mod/moviemasher/temp/url.png" fill="crop" />';
$subscount = preg_match_all($pattern, $subject, $matches);
//var_dump($matches);
$content = "";



for($i = 0 ; $i < $subscount ; $i++){
	$startFrame = $matches[1][$i];
	$lenghtSeconds = $matches[3][$i] / 10;
	// frame to seconds
	$startSeconds = $startFrame / 10;
	$endSeconds = $startSeconds + $lenghtSeconds;

//TODO: configure hours and convert microseconds to miliseconds
	$start = date("00:i:s,000 ", $startSeconds);
	$end =  date("00:i:s,000", $endSeconds);

	$content .= "<signbox index=\"". ($i+1)."\"  start=\"".$start."\" end=\"" .$end."\">\n";
	// bsw to swml
	$bsw = $matches[2][$i];
	$signsCount = preg_match_all("/0fb/is",$bsw,$signMatches);
	$splitedSymbol = preg_split("/0fb/is",$bsw);
	for($j = 1 ; $j <= $signsCount; $j++){
		$symbolsCount= strlen($splitedSymbol[$j])/15;
		$content .= "<sign lane=\"0\">\n";
		//var_dump($splitedSymbol[$j]);
		for($k = 0 ; $k < $symbolsCount; $k++){
			/*33b
			38c
			392
			4bb
			4bb
			
			219
			38c
			392
			4c5
			4f0
			
			16d
			38d
			392
			4c3
			4d8
			*/
			$char = substr($splitedSymbol[$j],$k*15+0,3);
			$fill = substr($splitedSymbol[$j],$k*15+3,3);
			$rot = substr($splitedSymbol[$j],$k*15+6,3);
			$fill = hexdec($fill) - 908;
			$rot =  hexdec($rot) - 914;
			$x = substr($splitedSymbol[$j],$k*15+9,3);
			$y = substr($splitedSymbol[$j],$k*15+12,3);			
			$x =  hexdec($x) - 1229;
			$y = hexdec($y)- 1229;
			$content .= "<sym x=\"". $x."\" y=\"".$y."\">".$char.$fill.$rot."</sym>\n";	
		}
		$content .="</sign>\n";			
	}	
	$content .= "</signbox>\n";
}
// POG - ?
$content = str_replace("<sym x=\"-1229\" y=\"-1229\" > -908-914 </sym>","",$content);
file_put_contents("legendaES.tswml", $content);

/*
This script is called directly from Movie Masher Applet, in response to a click on the Save button.
The XML formatted mash is posted as raw data, available in php://input
The script saves the XML data to $xml_path - defined below
Status is reported in a javascript alert, by setting the 'get' attribute.
*/

$xml_path = 'temp_mash.xml'; // must be writable by the web server process
$err = '';

file_put_contents($xml_path, $mashR->mash );


// setting dirty to zero should cause save button to disable
print '<moviemasher trigger="player.mash.dirty=0" />';
//print '<moviemasher get=\'javascript:alert("' .  addslashes($bsw). '");\' />';
?>
