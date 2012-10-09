<?php
include_once(dirname(__FILE__) . '/fileutils.php');
function log_file($s, $dir_log)
{
	if ($dir_log && $s)
	{
		if (file_safe($dir_log))
		{
			$prelog = date('H:i:s') . ' ';
			$prelog .= basename($_SERVER['SCRIPT_NAME']);
			$path = $dir_log . 'log_' . date('Y-m-d') . '.txt';
			$existed = file_exists($path);
			$fp = fopen($path, 'a');
			if ($fp)
			{
				$s = $prelog . ' ' . $s . "\n";
				fwrite($fp, $s, strlen($s));
				fclose($fp);
			}
			if (! $existed) @chmod($path, 0777);
		}
	}
}
?>