<?php
/*
This script is called directly from Movie Masher Applet, in response to clicks in browser navigation
and scrolling. The count, index and group values are sent as GET parameters, as specified in
panels.xml. Additional GET parameters are used to limit the result set. If the user is authenticated
the script searches either the relevant XML file, depending on group parameter. Media tags matching
parameters are included in result set, paged with count and index parameters. If an error is
encountered it is ignored and an empty result set is returned. This script is called repeatedly as
the user scrolls down, until an empty result set is returned.
*/

$err = '';

// load MovieMasher
if ((! $err) && (! @include_once('MovieMasher/MovieMasher.php'))) $err = 'Problem loading MovieMasher.php';

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

// check to make sure required parameters have been sent
if (! $err)
{
	$count = (empty($_GET['count']) ? 10 : $_GET['count']);
	$index = (empty($_GET['index']) ? 0 : $_GET['index']);
	$group = (empty($_GET['group']) ? '' : $_GET['group']);
	if (! $group ) $err = 'Parameter group required';
}

// check to make sure required configuration options have been set
if (! $err)
{
	
	$path_media = $moviemasher->getOption('PathMedia');
	$path_site = $moviemasher->getOption('PathSite');
	$dir_host = $moviemasher->getOption('DirHost');
	if (! ($dir_host && $path_media && $path_site)) $err = 'Configuration options DirHost, PathMedia, PathSite required';
}

// try reading in XML file
if (! $err)
{
	$file = 'media';
	switch($group) // group parameter determines which xml file we search through
	{
		case 'mash':
		case 'video':
		case 'audio':
		case 'image': 
			$file = $path_media . authenticated_userid() . '/' . $file;
			break;
		default: $file = $path_site . 'media/xml/' . $file . '_' . $group;
	}
	
	$path = $dir_host . $file . '.xml';
	
	// if file doesn't exist, assume user hasn't uploaded anything yet
	if (file_exists($path)) $xml_str = @file_get_contents($path, 1);
	else $xml_str = '<moviemasher></moviemasher>' . "\n";
	
	if (! $xml_str) $err = 'Problem reading ' . $path;
	else
	{
		$media_xml = @simplexml_load_string($xml_str);
		if (! is_object($media_xml)) $err = 'Problem parsing ' . $xml_str;
	}
}

$xml = ''; // output string
$xml .= '<moviemasher>' . "\n";

if (! $err)
{
	// loop through 'media' tags within XML file
	foreach ($media_xml->media as $tag)
	{
		// loop through all parameters
		$ok = 1;
		reset($_GET);
		foreach($_GET as $k => $v)
		{
			switch($k)
			{
				case 'index':
				case 'count':
					break;
				default:
					$test = (string) $tag[$k];
					// will match if parameter is empty, equal to or (for label) within attribute
					$ok = ((! $v) || ($v == $test) || ( ($k == 'label') && (strpos(strtolower($test), strtolower($v)) !== FALSE) )) ;
			}
			if (! $ok) break;		
		}
		if ($ok) 
		{
			// only add tag if within specified range
			if ($index) $index --;
			else
			{
				$xml .= "\t" . $tag->asXML() . "\n";
				$count --;
				if (! $count) break;
			}
		}
	}
}
$xml .= '</moviemasher>' . "\n";
print $xml;
?>
