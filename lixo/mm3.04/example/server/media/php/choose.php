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

// load objects from configuration
if (! $err)
{
	try
	{
		$moviemasher_file =& MovieMasher::fromConfig('MovieMasher.xml', 'File');
		$moviemasher_client =& MovieMasher::fromConfig('MovieMasher.xml', 'Client');
		$moviemasher_coder =& MovieMasher::fromConfig('MovieMasher.xml', 'Coder', 'Encoder');
	}
	catch(Exception $ex)
	{
		$err = xml_safe($ex->getMessage());
	}
}

// load utilities
if ((! $err) && (! @include_once('MovieMasher/lib/authutils.php'))) $err = 'Problem loading utility script';

// load utilities
if ((! $err) && (! @include_once('MovieMasher/lib/idutils.php'))) $err = 'Problem loading utility script';

// load utilities
if ((! $err) && (! @include_once('MovieMasher/lib/dateutils.php'))) $err = 'Problem loading utility script';

// see if the user is autheticated (will NOT exit)
if ((! $err) && (! authenticated())) $err = 'Unauthenticated access';

// check to make sure parameters were sent
if (! $err)
{
	$file_name = (empty($_REQUEST['file']) ? '' : $_REQUEST['file']);
	$file_size = (empty($_REQUEST['size']) ? '' : $_REQUEST['size']);
	if (! ($file_name && $file_size)) $err = 'Parameters file, size required';
}

// make sure required configuration options have been set
if (! $err)
{
	$path_media = $moviemasher_file->getOption('PathMedia');
	if (! ($path_media)) $err = 'Configuration option PathMedia required';
}
if (! $err)
{
	$path_media .=  authenticated_userid() . '/';
	if ($moviemasher_file->uploadsLocally())
	{
		$dir_host = $moviemasher_file->getOption('DirHost');
		if (! ($dir_host)) $err = 'Configuration option DirHost required';
	}
}
// make sure file name and size is acceptable
if (! $err) $err = $moviemasher_file->fileError($file_name, $file_size);

if (! $err)
{
	
	$type = type_from_path($file_name);
	switch($type)
	{
		case 'image':
		case 'video':
		case 'audio': break;
		default: $err = 'Unsupported file type: ' . $type;	
	}
}
if (! $err)
{
	$extension = file_extension($file_name);
	$id = unique_id('media' . $file_name . $file_size);
	$coder_filename = $moviemasher_coder->getOption('CoderFilename');
	$attributes = '';
	if (! $moviemasher_file->uploadsLocally())
	{
		try
		{
			// File == S3 or similar service
			$attributes .= $moviemasher_file->uploadAttributes($file_name, $file_size, $path_media . $id . '/' . $coder_filename);
			$attributes .= ' url="media/php/encode';
		}
		catch(Exception $ex)
		{
			$err = xml_safe($ex->getMessage());
		}
	}
	else $attributes .= ' upload="media/php/upload';
	$attributes .= '.php?id=' . $id . '&amp;u=' . authenticated_userid() . '"';
	
	$xml = '<moviemasher ' . $attributes . ' />';
	
}
if (! $err)
{
	$meta = array();
	$meta['label'] = $file_name;
	$meta['type'] = $type;
	$meta['extension'] = $extension;
	if ($moviemasher_client->progressesLocally())
	{
		$xml_string = '';
		$xml_string .= '<Progress>' . "\n";
		$xml_string .= "\t" . '<PercentDone>2</PercentDone>' . "\n";
		$xml_string .= "\t" . '<Date>' . http_date_string() . '</Date>' . "\n";
		$xml_string .= "\t" . '<Status>Queued</Status>' . "\n";
		$xml_string .= '</Progress>' . "\n";
		
		$meta['progress'] = $xml_string;
	}
	$meta_path = $path_media . $id . '/';
	if ($moviemasher_file->uploadsLocally()) $meta_path = $dir_host . $meta_path;
	if (! $moviemasher_file->addMeta($meta_path, $meta)) $err = 'Problem saving media meta data: ' . $meta_path;
	
	
}
if ($err) $xml = '<moviemasher progress="-1" status="' .  $err . '" />';

print $xml;

if (! empty($moviemasher_file)) $moviemasher_file->log($xml);

?>