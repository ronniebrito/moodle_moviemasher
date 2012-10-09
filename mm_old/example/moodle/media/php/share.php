<?php
/*
This script is called directly from Movie Masher Applet, in response to a click on the Share button.
The XML formatted mash is posted as raw data, available in php://input stream. The script saves the
XML data to the media/mash directory, after adding a 'config' attribute to its mash tag pointing to
the media/xml/panel_player.xml file. This allows us to later load the mash xml file directly as the
main config file, such that the player-only interface is loaded too. The script also saves an HTML
file to the media/html directory, which is the file that will be loaded by Facebook. If all goes
well, the user is redirected to Facebook's sharer script, by setting the 'get' attribute. Otherwise,
an error is reported in a javascript alert, by setting the 'get' attribute.
*/
$id = (empty($_REQUEST['id']) ? '' : $_REQUEST['id']);
	

$err = '';
if (! $id) $err = 'Parameter id required';

if (! $err)
{
	$xml_path = '../mash/' . $id . '.xml'; // directory must be writable by the web server process
	
	// see xml/control_save.xml to see how this parameter is set
	$duration = (empty($_REQUEST['duration']) ? '' : $_REQUEST['duration']);
	// we're just testing for some duration, but you could also check for length
	if (! $duration) $err = 'Please include at least one clip in your mash';
}

// check to make sure data was sent
if (! $err)
{
	$mash_str = file_get_contents('php://input');
	if (! $mash_str) $err = 'Mash data required';
}
// check to make sure we can parse it as XML
if (! $err)
{
	$mash_xml = @simplexml_load_string($mash_str);
	if (! is_object($mash_xml)) $err = 'Could not parse mash XML';
}
// check to make sure there's at least one mash tag
if (! $err)
{
	$mash_tags = $mash_xml->xpath('//mash');
	if (! sizeof($mash_tags)) $err = 'Could not find a mash tag in XML';
}
// make sure we can read title out of first mash tag
if (! $err)
{
	$mash_tag = $mash_tags[0];
	$title = (string) $mash_tag['label'];
	if (! $title) $err = 'A label must be supplied';
}
// try to read in template file
if (! $err)
{
	// $config_url, $movie_url and $moviemasher_url variables are expected to be set in template ($title and $description are option)
	$moviemasher_url = 'http://' . $_SERVER["HTTP_HOST"] . dirname(dirname(dirname(dirname(dirname($_SERVER["PHP_SELF"])))));
	$config_url = $moviemasher_url . '/example/moodle/media/mash/' . $id . '.xml';
	$mash_tag['config'] = 'media/xml/panel_player.xml';
	$movie_url = $moviemasher_url . '/moviemasher/com/moviemasher/core/MovieMasher/stable.swf';
	//$movie_url .= 'config=' . urlencode($config_url);
	//$movie_url .= '&amp;base=' . urlencode($moviemasher_url . '/example/share');
	ob_start();
	@include('./html.php');
	$html = ob_get_clean();
	if (! $html) $err = 'Was not able to read in html.php file';
}
// save out html file
if (! $err)
{
	$file_path = '../html/' . $id . '.html';
	if (! @file_put_contents($file_path, $html)) $err = 'Problem saving HTML file to ' . $file_path;
}
// save out xml file
if (! $err)
{
	if (! $mash_xml->asXML($xml_path)) $err = 'Problem saving XML to ' . $xml_path;
}
// report error or popup Facebook sharer script
if ($err) $err = 'get=\'javascript:alert("' .  $err . '");\'';
else $err = 'target="_blank" get=\'http://www.facebook.com/sharer.php?u=' . urlencode($moviemasher_url . '/example/moodle/media/html/' . $id . '.html') . '&amp;t=' . urlencode($title) . '\'';

print '<moviemasher ' . $err . ' />';

?>
