<?php
/*
This script is called from Movie Masher Applet.
The uploaded file is in _FILES['Filedata'], but the script just grabs the first key.
If the file uploads correctly and its extension is acceptable, the following happens:
	* the base file name is changed to 'media'
	* a quasi unique ID is generated for the media file
	* a directory is created in media/upload, the ID is used for the name
	* the file is moved to this directory, and a 'meta' directory is created alongside it
	* extension, type and name properties are cached to the 'meta' directory for later use
The media ID is passed as a parameter to encode.php, by setting the 'url' attribute in response.
If an error is encountered it is displayed in a javascript alert, by setting the 'get' attribute.
If possible, the response to client is logged.
*/

$err = '';

// load MovieMasher
if ((! $err) && (! @include_once('MovieMasher/MovieMasher.php'))) $err = 'Problem loading MovieMasher script';

// load objects from configuration
if (! $err)
{
	try
	{
		$moviemasher_file =& MovieMasher::fromConfig('MovieMasher.xml', 'File');
		$moviemasher_coder =& MovieMasher::fromConfig('MovieMasher.xml', 'Coder', 'Encoder');
	}
	catch(Exception $ex)
	{
		$err = xml_safe($ex->getMessage());
	}
}

// make sure required configuration options have been set
if (! $err)
{
	$dir_host = $moviemasher_file->getOption('DirHost');
	$path_media = $moviemasher_file->getOption('PathMedia');
	if (! ($dir_host && $path_media)) $err = 'Configuration options DirHost, PathSite, PathMedia required';
}

// check to make sure required parameters were sent
if (! $err)
{
	$id = (empty($_REQUEST['id']) ? '' : $_REQUEST['id']);
	$u = (empty($_REQUEST['u']) ? '' : $_REQUEST['u']);
	if (! ($u && $id)) $err = 'Parameter u and id required';
}


// make sure $_FILES actually has a file for us
if (! $err) 
{
	$path_media .=  $u . '/';
	$file = $moviemasher_file->uploadedFile();
	if (! $file) $err = 'There was a problem with your upload.';
}

// make sure file name and size are acceptable
if (! $err) 
{
	$file_name = stripslashes($file['name']);
	$file_size = $file['size'];
	$err = $moviemasher_file->fileError($file_name, $file_size);
}

// make sure a directory had been created during choose.php
if (! $err)
{
	$type = type_from_path($file_name);
	$extension = file_extension($file_name);
	$path = $dir_host . $path_media . $id;
	if (! safe_path($path)) $err = 'Problem creating media directory: ' . $path;
}

// move file into its media directory
if (! $err)
{
	$coder_filename = $moviemasher_coder->getOption('CoderFilename');
	$path .= '/' . $coder_filename . '.' .  $extension;
	if (! @move_uploaded_file($file['tmp_name'], $path)) $err = 'Problem moving file to: ' . $path;
}

// attempt to change its file permissions
if (! $err)
{
	if (! @chmod($path, 0777)) $err = 'Problem setting permissions of media: ' . $path;
}

// build tag, print and log, if possible
$xml = '<moviemasher ';
if ($err) $xml .= 'progress="100" status="" get=\'javascript:alert("' .  $err . '");\' ';
else
{
	// get CGI control to load encode.php in one second
	$xml .= 'url="media/php/encode.php?id=' . $id . '" ';
	$xml .= 'progress="1" status="Preparing..." delay="1" ';
}
$xml .= "/>\n\n";

// print and log tag, if possible
print $xml;
if (! empty($moviemasher_file)) $moviemasher_file->log($xml);

?>
