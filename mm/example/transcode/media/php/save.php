<?php 
/*
This script is called directly from Movie Masher Applet, in response to a click on the Save button.
The XML formatted mash is posted as raw data, available in php://input
The script saves the XML data to $xml_path - defined below
Any errors are reported in a javascript alert, by setting the 'get' attribute.
Otherwise an empty moviemasher tag is returned, to indicate success.
*/

$err = '';
$dir_log = '';

// load utilities
$include = dirname(__FILE__) . '/include/';
if ((! $err) && (! @include_once($include . 'authutils.php'))) $err = 'Problem loading authentication utility script';
if ((! $err) && (! @include_once($include . 'configutils.php'))) $err = 'Problem loading configuration utility script';
if ((! $err) && (! @include_once($include . 'fileutils.php'))) $err = 'Problem loading file utility script';
if ((! $err) && (! @include_once($include . 'httputils.php'))) $err = 'Problem loading http utility script';
if ((! $err) && (! @include_once($include . 'logutils.php'))) $err = 'Problem loading log utility script';
if ((! $err) && (! @include_once($include . 'xmlutils.php'))) $err = 'Problem loading xml utility script';
if (! $err) // pull in configuration so we can log other errors
{
	$config = config_get();
	$dir_log = config_path(empty($config['DirLog']) ? '' : $config['DirLog']);
	$err = config_error($config);
}

if (! $err) // see if the user is autheticated (does not redirect or exit)
{
	if (! auth_ok()) $err = 'Unauthenticated access';
}
if (! $err) // pull in other configuration and check for required input
{
	$dir_host = config_path(empty($config['DirHost']) ? $_SERVER['DOCUMENT_ROOT'] : $config['DirHost']);

	$path_cgi = config_path(empty($config['PathCGI']) ? substr(dirname(__FILE__), strlen($dir_host)) : $config['PathCGI']);
	$path_site = config_path(empty($config['PathSite']) ? config_path(dirname(dirname($path_cgi))) : $config['PathSite']);
	$path_media = config_path(empty($config['PathMedia']) ? config_path(dirname($path_cgi)) . 'user' : $config['PathMedia']);

	$id = (empty($_REQUEST['id']) ? '' : $_REQUEST['id']);
	$duration = (empty($_REQUEST['duration']) ? '' : $_REQUEST['duration']);
	$mash_string = file_get('php://input');

	$log_requests = (empty($config['LogRequests']) ? '' : $config['LogRequests']);
	$log_responses = (empty($config['LogResponses']) ? '' : $config['LogResponses']);
	if ($log_requests) log_file($_SERVER['QUERY_STRING']  . "\n" . $mash_string, $dir_log);

	// make sure required parameters have been sent
	if (! ($id && $mash_string && $duration)) $err = 'Mash duration, id and data required';
}
// check to make sure XML data is parsable
if (! $err)
{
	$mash_xml =xml_from_string($mash_string);
	if (! $mash_xml) $err = 'Could not parse mash data: ' . $mash_string;
}
// make sure label was set
if (! $err)
{
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
	$path_media .= auth_userid() . '/';
	$xml_path = $dir_host . $path_media . $id . '.xml'; // must be writable by the web server process
	if (! file_put($xml_path, $mash_string)) $err = 'Problem saving mash';
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

	if (file_exists($media_file_xml_path)) $xml_str = file_get($media_file_xml_path);
	else $xml_str = '<moviemasher />' . "\n";

	if (! $xml_str) $err = 'Problem loading ' . $media_file_xml_path;
	else
	{
		$media_file_xml = xml_from_string($xml_str);
		if (! is_object($media_file_xml)) $err = 'Problem parsing ' . $xml_str;
	}
}

if (! $err)
{
	$media_tag = null;
	// find existing media tag
	$media_tags = $media_file_xml->media;
	$z = sizeof($media_tags);
	for ($i = 0; $i < $z; $i++)
	{
		$media_tag = $media_tags[$i];
		if ($media_tags[$i]['id'] == $id) break;
		$media_tag = null;
	}
}


if (! $err)
{
	// add media data to existing media.xml file
	$media_tag_existed = ! is_null($media_tag);
	if (! $media_tag_existed) 
	{
		$media_tag = new SimpleXMLElement('<media type="mash" group="mash" />');
		$media_tag['id'] = $id;
		$media_tag['source'] = $partial_media_path . $id . '.xml';
	}
	$media_tag['label'] = $label;
	$media_tag['duration'] = $duration;

	
	$xml_str = '';
	$xml_str .= "<moviemasher>\n";
	
	if (! $media_tag_existed) $xml_str .= "\t" . xml_pretty($media_tag->asXML()) . "\n";

	$children = $media_file_xml->children();
	$z = sizeof($children);
	for ($i = 0; $i < $z; $i++) $xml_str .= "\t" . $children[$i]->asXML() . "\n";
	$xml_str .= '</moviemasher>' . "\n";

	// write file
	if (! file_put($media_file_xml_path, $xml_str)) $err = 'Problem writing ' . $media_file_xml_path;
}

// setting dirty to zero should cause save button to disable
if (! $err) $xml = '<moviemasher trigger="player.mash.dirty=0" />';
else
{
	$xml = '<moviemasher get=\'javascript:alert("' .  $err . '");\' />';
	log_file($err, $dir_log);
}
print $xml . "\n\n";
if (! empty($log_responses)) log_file($xml, $dir_log);


?>