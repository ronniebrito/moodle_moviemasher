<?php

require_once(dirname( dirname( dirname(dirname(dirname(dirname(dirname(dirname(__FILE__)))))))).'/config.php');
/*
This script is called directly from Movie Masher Applet, in response to a click on upload button.
The uploaded file is in _FILES['Filedata'].
If the file uploads and its extension is acceptable, the following happens:
	* a quasi unique ID is generated for the media file
	* the base file name is changed to this ID, retaining file extension
	* the file is moved to $upload_dir - defined below
	* a media tag is inserted into $media_file for the uploaded file
Any error encountered is reported in a javascript alert, by setting the 'get' attribute.
Otherwise the 'trigger' attribute is used to switch the browser view to the images tab.
*/

function difftime($hs,$ms,$ss, $mss, $he, $me, $se, $mse){
		return round(($he * 60 * 60 + $me *60 + $se + $mse * 0.001) - ($hs * 60 * 60 + $ms *60 + $ss + $mss * 0.001),2);
}


$mash = (empty($_REQUEST['mash']) ? "" : $_REQUEST['mash']);
$mash = file_get_contents('php://input');


$upload_dir = '../user/'; // needs to be writable by web server process
$media_file = '../xml/media.xml'; // needs to be writable by web server process

$err = '';
// make sure $_FILES is set and has upload key
if (empty($_FILES) || empty($_FILES['Filedata'])) $err = 'No files supplied';

// make sure there wasn't a problem with the upload
if (! $err)
{
	$file = $_FILES['Filedata'];
	if (! empty($file['error'])) $err = 'Problem with your file: ' . $file['error'];
	elseif (! is_uploaded_file($file['tmp_name'])) $err = 'Not an uploaded file';
}

// check to make sure file has acceptable extension
if (! $err)
{
	$extension = strtolower(substr($file['name'], strrpos($file['name'], '.') + 1));
	switch ($extension)
	{
		case 'jpeg': 
			$extension = 'jpg';
		case 'jpg':
			break;
		case 'ping':
			$extension = 'png';
		case 'png':
			break;
		case 'giff':
			$extension = 'gif';
		case 'gif':
			break;
		case 'srt':		
			$extension = 'srt';
			break;			
		case 'tswml':		
			$extension = 'tswml';
			break;
		default: 
			$err = 'Unsupported file extension ' . $extension;
	}
}
// load utilities
if ((! $err) && (! @include_once('../../../../private/MovieMasher/lib/idutils.php'))) $err = 'Problem loading utility script';


//move file and set its permissions
if (! $err)
{
	$type = 'image';
	$label = $file['name'];
	$id = unique_id('media' . $label);
	$url = 'media/user/' . $id . '.' . $extension;
	$path = $upload_dir . $id . '.' . $extension;
	if (! @move_uploaded_file($file['tmp_name'], $path)) $err = 'Problem moving file to ' . $path;
	elseif (! @chmod($path, 0777)) $err = 'Problem setting permissions';
}


// finds top level track
$pattern = '/track=\"(.*?)\"/';
$count = preg_match_all($pattern, $mash, $matches);
$track = 0;
for($t = 0; $t<$count ;$t++){
	if($matches[1][$t] > $track){ $track = $matches[1][$t]; $track++;}	
}
//$content = $mash;
//var_dump($matches);
if($extension == "srt"){
		
		$pattern = "/.+\n(\d\d)\:(\d\d)\:(\d\d)\,(\d\d\d).*\s\-\-\>\s(\d\d)\:(\d\d)\:(\d\d)\,(\d\d\d).*?\n(.+)\n/";
		$subject = file_get_contents($path);		
/*$subject ="1
00:00:04,126 --> 00:00:06,885
Sábado ensolarado

2
00:00:06,886 --> 00:00:10,851
por causa da massa de ar seco sobre o país

3
00:00:10,852 --> 00:00:13,752
A defesa civil recomenda

";*/
		$count = preg_match_all($pattern, $subject, $matches);

		
	$content = "";
		
	for($i =0 ; $i< $count; $i++){
		$dif = difftime($matches[1][$i],$matches[2][$i],$matches[3][$i],$matches[4][$i],$matches[5][$i],$matches[6][$i],$matches[7][$i],$matches[8][$i]);			
		
		$txt = $matches[9][$i];		
		 $txt = str_replace("\n","", $txt);
		$txt = str_replace("\t","", $txt);
		 $txt = str_replace("\r","", $txt);
		 $txt = str_replace("
","", $txt);
//$txt = "test";
		$content .= '<clip type="effect" id="captioneffect" track="1" start="'.(($matches[1][$i]*360+$matches[2][$i]*60+$matches[3][$i])*10).'" forecolor="000000" font="default" lengthseconds="'.$dif.'" backcolor="FFFFFF" longtext="'.$txt.'" length="'.($dif*10).'" textsize="10" label="Caption" padding="1" backalpha="50" />';	
	
	}
//var_dump($content);
}

if($extension=="tswml" ){
	
	
$subject = '<signbox index="1" start="00:00:04,000" end="00:00:07,061">
<sign lane="0">
  <sym x="-18" y="-18">2ff00</sym>
  <sym x="-40" y="-21">21600</sym>
</sign>
<sign lane="0">
  <sym x="-18" y="-18">2ff00</sym>
  <sym x="-6" y="-8">22a00</sym>
</sign>
<sign lane="0">
  <sym x="-18" y="-18">2ff00</sym>
  <sym x="-40" y="-21">21600</sym>
</sign>
<sign lane="0">
  <sym x="-18" y="-18">2ff00</sym>
  <sym x="-50" y="-33">22a00</sym>
</sign></signbox>      ';

$subject = file_get_contents($path);
$subject = str_replace("\n","",$subject);

	$content = "";
	//$pattern ="/<signbox.*?start=\"(\d\d)\:(\d\d)\:(\d\d)\,(\d\d\d)\".*?end=\"(\d\d)\:(\d\d)\:(\d\d)\,(\d\d\d)\".*?(.*?)<\/signbox>/is";
	$pattern ="/<signbox.*?start=\"(\d\d)\:(\d\d)\:(\d\d)\,(\d\d\d)\".*?end=\"(\d\d)\:(\d\d)\:(\d\d)\,(\d\d\d)\".*?>(.*?)<\/signbox>/is";
	//$subject = file_get_contents($path);
	$count = preg_match_all($pattern, $subject, $matches);	
	
	
//	$content = "";
//	var_dump($matches);
	for( $i =0 ;$i < $count;$i++){
	$durationSeconds = difftime($matches[1][$i],$matches[2][$i],$matches[3][$i],$matches[4][$i],$matches[5][$i],$matches[6][$i],$matches[7][$i],$matches[8][$i]);
		$startSeconds = difftime($matches[1][$i],$matches[2][$i],$matches[3][$i],$matches[4][$i],0,0,0,0);
		$bsw = "";

		$pattern = "/<sign.*?>(.*?)<\/sign>/";
		$countSigns = preg_match_all($pattern,$matches[9][$i], $signs);
		//echo "signs for i = ". $i;var_dump($signs);

		for( $j =0 ;$j < $countSigns;$j++){			
				$pattern = "/<sym.*?x=\"(.*?)\".*?y=\"(.*?)\".*?>(.*?)<\/sym>/";
				$countSymbols = preg_match_all($pattern, $signs[1][$j], $symbols);
					//	echo " symbols for i = ". $i . " j = ". $j;
					//var_dump($symbols);
				$bsw .= "0fb";
				for( $k =0 ;$k < $countSymbols;$k++){
			     	$char = substr($symbols[3][$k],0,3);
					$fill = substr($symbols[3][$k],3,1);
					$rot = substr($symbols[3][$k],4,1);


					$fill = dechex($fill + 908);
					$rot =  dechex($rot + 914);
					$x = $symbols[1][$k];
					$y = $symbols[2][$k];
					
					$x =  dechex($x + 1229);
					$y = dechex($y + 1229);
					//0fb10e38c3924e64f2
					//echo " symbol=". $symbols[3][$k]. " is x=". $symbols[1][$k]. " y=". $symbols[2][$k] . " char =".$char . " rot= ". $rot . " fill=". $fill. " x = ". $x;
				//	$x = "4cd";
				//	$y = "4cd";
					$bsw .= $char.$fill.$rot.$x.$y;					
					//echo " bsw= ". $bsw. "<br>";					
				}
			
		}
		$content .= '<clip type="effect" id="signboxeffect" track="3" start="'.(($matches[1][$i]*360+$matches[2][$i]*60+$matches[3][$i])*10).'" label="Sign Writing" lengthseconds="'.$durationSeconds.'" bsw="'.$bsw.'" href="http://www.signbank.org/signpuddle2.0/searchquery.php?bldSearch=01-01-001-01,01,01,98,97" length="'.($durationSeconds*10).'" >		<clip type="image" id="'.substr($bsw,0, 128).'" audio="0" label="SW" trimstart="0" track="-1" fill="scale" start="0" length="'.($durationSeconds*10).'"/>		</clip> <media group="image" type="image"  id="'.substr($bsw,0, 128).'" label="SW" url="'.$CFG->wwwroot.'/mod/moviemasher/temp/'.md5(substr($bsw,0, 128)).'.png" fill="crop" />';

//$content .= '<clip type="effect" id="signboxeffect" track="3" start="'.(($matches[1][$i]*360+$matches[2][$i]*60+$matches[3][$i])*10).'" length="'.($durationSeconds*10).'" label="Sign Writing" lengthseconds="'.$durationSeconds.'" bsw="'.$bsw.'" href="http://localhost/moodle/mod/moviemasher/swmp/swis/image_sym.php?bsw='.$bsw.'" >		<clip type="image" id="'.substr($bsw,0, 128).'" bsw="'.$bsw.' "audio="0" label="SW" trimstart="0" track="-1" fill="scale" start="0" length="'.($durationSeconds*10).'"/>		</clip> <media group="image" type="image"  id="'.substr($bsw,0, 128).'" label="SW" url="../../../../../swmp/swis/column.php?bsw='.$bsw.'" fill="crop" />';
			
			// retrieve bsw image files
			file_get_contents($CFG->wwwroot."/mod/moviemasher/binarySignWriting.php?palavra=".$bsw );		
	}
}

//echo  "<pre>".$content."</pre>";

//$content = '<clip type="image" id="cc02f4e63d4f15e8295dfbc1d068ca47" length="50" lengthseconds="5" fill="stretch" label="Desert.jpg" track="-1"/>   <clip type="image" id="cc02f4e63d4f15e8295dfbc1d068ca47" fill="stretch" lengthseconds="5.0" track="0" length="50" label="Desert.jpg"/>' ;
//$content = $mash;

//$err = rawurlencode(addslashes($content));
if ($err ){
	$attibs = 'get=\'javascript:alert("' .  $err . '");\'';
}else{
	 if($extension=="srt" or $extension == "tswml"){
	


						

					//	$attibs = 'get=\'javascript:addSubtitles("'. rawurlencode(addslashes('v< > " sd "vv')) .'");\'';
						
						$attibs = 'get=\'javascript:addSubtitles("'. rawurlencode(addslashes($content)) .'");\'';
						//$attibs = 'get=\'javascript:alert("'. rawurlencode(addslashes($content)) .'");\'';
			
			
		}else{
			$attibs = 'trigger="browser.parameters.group=SW"';
						//$attibs = 'get=\'javascript:alert("'. rawurlencode(addslashes($content)) .'");\'';
		}
}


if ($err) $attibs = 'get=\'javascript:alert("' .  $err . '");\'';
//else $attibs = 'trigger="browser.parameters.group=image"';
print '<moviemasher ' . $attibs . '	/>' . "\n\n";

?>
