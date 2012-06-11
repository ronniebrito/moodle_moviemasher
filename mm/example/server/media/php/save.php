<?php
/*
This script is called directly from Movie Masher Applet, in response to a click on the Save button.
The XML formatted mash is posted as raw data, available in php://input
The script saves the XML data to $xml_path - defined below
Any errors are reported in a javascript alert, by setting the 'get' attribute.
Otherwise an empty moviemasher tag is returned, to indicate success.
*/

$err = '';


// load MovieMasher
if ((! $err) && (! @include_once('MovieMasher/MovieMasher.php'))) $err = 'Problem loading MovieMasher.php';
// load MovieMasher
if ((! $err) && (! @include_once('MovieMasher/Coder/Decoder.php'))) $err = 'Problem loading Decoder.php';

// load objects from configuration
if (! $err)
{
	try
	{
		$moviemasher =& MovieMasher::fromConfig('MovieMasher.xml', 'Client');
	}
	catch(Exception $ex)
	{
		$err = xml_safe($ex->getMessage());
	}
}

// load utilities
if ((! $err) && (! @include_once('MovieMasher/lib/authutils.php'))) $err = 'Problem loading utility script';

// see if the user is autheticated (will NOT exit)
if ((! $err) && (! authenticated())) $err = 'Unauthenticated access';

// make sure required configuration options have been set
if (! $err)
{
	$dir_host = $moviemasher->getOption('DirHost');
	$path_media = $moviemasher->getOption('PathMedia');
	$path_site = $moviemasher->getOption('PathSite');
	if (! ($dir_host && $path_media))
	{
		$err = 'Configuration options DirHost, PathMedia required';
	}
}

// check to make sure data was sent
if (! $err)
{
	$id = (empty($_REQUEST['id']) ? '' : $_REQUEST['id']);
	$mash_string = file_get_contents('php://input');
	if (! ($id && $mash_string)) $err = 'Mash data and id parameter required';
}
// check to make sure XML data is parsable
if (! $err)
{
	$mash_xml = @simplexml_load_string($mash_string);
	if (! $mash_xml) $err = 'Could not parse mash data: ' . $mash_string;
}
// make sure label was set
if (! $err)
{
	$info = MovieMasher_Coder_Decoder::mashInfo($mash_xml);
	$duration =  $info['duration'];
	$label = $mash_xml->mash[0]['label'];
	if (! $label) $err = 'Could not determine mash label';
}
// make sure clip tags are found
if (! $err)
{
	if (! sizeof($mash_xml->mash[0]->clip)) $err = 'No clip tags found';
}
// save mash xml
if (! $err) 
{
	$path_media .= authenticated_userid() . '/';
	$xml_path = $dir_host . $path_media . $id . '.xml'; // must be writable by the web server process
	$mash_existed = file_exists($xml_path);
	if (! safe_path($xml_path)) $err = 'Could not create path to ' . $xml_path;
	else if (! @file_put_contents($xml_path, $mash_string)) $err = 'Problem saving mash';
}

// try reading in media.xml file containing existing media items
if (! $err)
{

	if (substr($path_media, 0, strlen($path_site)) == $path_site)
	{
		$partial_media_path = substr($path_media, strlen($path_site));
	}
	else $partial_media_path = '/' . $path_media;
	$media_file_xml_path = $dir_host . $path_media . 'media.xml';
	
	if (file_exists($media_file_xml_path)) $xml_str = @file_get_contents($media_file_xml_path);
	else $xml_str = '<moviemasher></moviemasher>' . "\n";

	if (! $xml_str) $err = 'Problem loading ' . $media_file_xml_path;
	else
	{
		$media_file_xml = @simplexml_load_string($xml_str);
		if (! is_object($media_file_xml)) $err = 'Problem parsing ' . $xml_str;
	}
}

if (! $err)
{
	if ($mash_existed)
	{
		// remove existing media tag
		$z = sizeof($media_file_xml->media);
		for ($i = 0; $i < $z; $i++)
		{
			if ($media_file_xml->media[$i]['id'] == $id)
			{
				unset($media_file_xml->media[$i]);
				break;
			}
		}
	}	
}


if (! $err)
{
	// add media data to existing media.xml file

	
	// start with an unattributed media tag document
	$media_xml = simplexml_load_string('<moviemasher><media /></moviemasher>');
	
	// add attributes
	$media_xml->media->addAttribute('type', 'mash');
	$media_xml->media->addAttribute('group', 'mash');
	$media_xml->media->addAttribute('id', $id);
	$media_xml->media->addAttribute('label', $label);
	$media_xml->media->addAttribute('duration', $duration);
	$media_xml->media->addAttribute('url', $partial_media_path . $id . '.xml');
	
	// build XML string
	$media_tag = (string) $media_xml->media->asXML();
	$xml_str = MOVIEMASHER_XML_DECLARATION;
	$xml_str .= '<moviemasher>';
	$xml_str .= "\n\t" . $media_tag . "\n";
	
	$children = $media_file_xml->children();
	$z = sizeof($children);
	for ($i = 0; $i < $z; $i++) $xml_str .= "\t" . $children[$i]->asXML() . "\n";
	$xml_str .= '</moviemasher>' . "\n";
	
	// write file
	if (! @file_put_contents($media_file_xml_path, $xml_str)) $err = 'Problem writing ' . $media_file_xml_path;
}

// setting dirty to zero should cause save button to disable
if (! $err) print '<moviemasher trigger="player.mash.dirty=0" />';
else print '<moviemasher get=\'javascript:alert("' .  $err . '");\' />';

?>