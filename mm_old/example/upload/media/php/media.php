<?php
/*
This script is called directly from Movie Masher Applet, in response to clicks in browser navigation and scrolling.
The count, index and group values are sent as GET parameters, as specified in config.xml.
Additional GET parameters can limit the result set - 'label' will match substrings.
The script searches through the XML file specified in $xml_path - defined below
Media tags matching parameters are included in result set, paged with count and index parameters.
If an error is encountered it is ignored and an empty result set is returned.
This script is called repeatedly as the user scrolls down, until an empty result set is returned.
*/


$count = (empty($_GET['count']) ? 10 : $_GET['count']);
$index = (empty($_GET['index']) ? 0 : $_GET['index']);
$group = (empty($_GET['group']) ? '' : $_GET['group']);

print '<moviemasher>' . "\n";

if ($group)
{
	$xml_path = '../xml/media';
	if ($group != 'image') $xml_path .= '_' . $group;
	$xml_path .= '.xml';

	// try reading in XML file
	$xml_str = file_get_contents($xml_path, 1);
	$media_xml = @simplexml_load_string($xml_str);
	if ($media_xml) // loop through 'media' tags within XML file
	{
		foreach ($media_xml->media as $tag)
		{
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
						$a = (string) $tag[$k];
						// will match if parameter is empty, equal to or (for label) within attribute
						$ok = ((! $v) || ($v == $a) || ( ($k == 'label') && (strpos(strtolower($a), strtolower($v)) !== FALSE)));
				}
				if (! $ok) break;		
			}
			if ($ok) 
			{
				if ($index) $index --;
				else // tag is within specified range
				{
					print "\t" . $tag->asXML() . "\n";
					$count --;
					if (! $count) break; // tag is last in range - done
				}
			}
		}
	}
}
print '</moviemasher>' . "\n";
?>