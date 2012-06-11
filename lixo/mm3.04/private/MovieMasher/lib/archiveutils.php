<?php
/*
Required directly by encoded.php example scripts that receive encoded assets via HTTP as tgz
archive. This file uses PEAR's Archive_Tar class to handle the extraction. Functions will return
FALSE if the class cannot be loaded.
*/

// try to load Archive Tar PEAR class for extraction
@include_once('Archive/Tar.php');

include_once 'MovieMasher/lib/fileutils.php';

function extract_archive($path, $archive_dir)
{

	$result = FALSE;
	if (class_exists('Archive_Tar'))
	{
		if (safe_path($archive_dir)) 
		{
			$tar = new Archive_Tar($path);
			$tar->extract(dirname($archive_dir));
	
			$result = file_exists($archive_dir);
		}
	}
	return $result;
}

?>