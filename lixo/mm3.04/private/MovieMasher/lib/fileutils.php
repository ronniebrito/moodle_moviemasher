<?php
/*
Functions in this file are used throughout classes and examples for general help with file handling.

*/

include_once('MovieMasher/lib/shellutils.php');

function end_with_slash($path)
{
	if ($path && (substr($path, -1) != DIRECTORY_SEPARATOR))
	{
		$path .= DIRECTORY_SEPARATOR;
	}
	return $path;
}

function dir_path($file_path)
{
	if (substr($file_path, -1) != DIRECTORY_SEPARATOR)
	{
		$file_path = dirname($file_path) . DIRECTORY_SEPARATOR;
	}
	return $file_path;
}

function directory_size_kb($dir)
{
	$size = 0;
	$cmd = 'du -s ' . $dir;
	$result = shell_command($cmd);
	if ($result)
	{
		$result = explode("\t", $result);
		$result = array_shift($result);
		if (is_numeric($result)) $size += $result;
	}
	return $size;
}

function file_extension($url, $dont_change_case = 0)
{
	$extension = '';
	$parsed = parse_url($url, PHP_URL_PATH);
	if ($parsed)
	{
		$extension = pathinfo($parsed, PATHINFO_EXTENSION);
		if (! $dont_change_case) $extension = strtolower($extension);
	}
	return $extension;

}

function file_get($path)
{
	return @file_get_contents($path, 1);
}

function files_in_dir($dir, $just_names = FALSE, $filter = 'files')
{
	$result = false;
	if ($dir && is_dir($dir))
	{
		$dir = end_with_slash($dir);
		if ($handle = opendir($dir)) 
		{
			$result = array();
			while (FALSE !== ($file = readdir($handle)))
			{
				if ($file != "." && $file != "..") 
				{
					if (! $just_names) $file = $dir . $file;
					switch($filter)
					{
						case 'files':
							if (is_file($dir . $file)) $result[] = $file;
							break;
						case 'dirs':
							if (is_dir($dir . $file)) $result[] = $file;
							break;
						default:
							$result[] = $file;
					}
				}
			}
			closedir($handle);
		}
	}
	return $result;
}

function move_files_having_extension($extension, $archive_path, $media_path, $dont_replace = FALSE)
{
	$result = FALSE;
	// make sure parameters are defined
	if ($extension && $archive_path && $media_path)
	{
		$archive_path = end_with_slash($archive_path);
		$media_path = end_with_slash($media_path);
		
		// make sure archive path exists
		if (file_exists($archive_path))
		{
			// make sure we have somewhere to move to
			if (safe_path($media_path)) 
			{
				if ($handle = opendir($archive_path)) 
				{
					$result = TRUE;
					while ($result && (FALSE !== ($file = readdir($handle))))
					{
						if ($file != "." && $file != "..") 
						{
							if (is_file($archive_path . $file))
							{
								$ext = file_extension($archive_path . $file);
								if ($ext == $extension)
								{
									if ((! $dont_replace) || (! file_exists($media_path . $file)))
									{
										$result = @rename($archive_path . $file, $media_path . $file);
									}
								}
							}
						}
					}
					closedir($handle);
				}
			}
		}
	}
    return $result;
}

function remove_dir_and_files($path)
{
	$result = FALSE;
	if ($path && file_exists($path) && is_dir($path))
	{
		$path = end_with_slash($path);
		
		if ($handle = opendir($path)) 
		{
			$result = TRUE;
			while ($result && (FALSE !== ($file = readdir($handle))))
			{
				if ($file != "." && $file != "..") 
				{
					if (is_dir($path . $file))
					{
						$result = remove_dir_and_files($path . $file);
					}
					else
					{
						$result = @unlink($path . $file);
					}
				}
			}
			closedir($handle);
		}
		if ($result) $result = @rmdir($path);
	}
    return $result;

}

function safe_path($path)
{
	$result = FALSE;
	if ($path)
	{
		$ext = file_extension($path); // will be empty if path is directory
		$dirs = explode(DIRECTORY_SEPARATOR, $path);
		if ($ext) array_pop($dirs); // get rid of file name if path is file
		$dir = join(DIRECTORY_SEPARATOR, $dirs);
		if (file_exists($dir)) 
		{
			$result = TRUE;
			@chmod($dir, 0777);
		}
		else $result = @mkdir($dir, 0777, TRUE);
	}
	return $result;
}

?>