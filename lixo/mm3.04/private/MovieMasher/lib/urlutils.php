<?php

include_once('MovieMasher/lib/url_to_absolute.php');

function absolute_url($base_url, $relative_url)
{
	return url_to_absolute($base_url, $relative_url);
}

function http_get_file($abs_url, $file_path)
{
	$result = FALSE;
	$ch = curl_init($abs_url);
	if ($ch)
	{
		curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
		curl_setopt($ch, CURLOPT_HEADER, 1);
		curl_setopt($ch, CURLOPT_NOBODY, 1);			// Don't include body
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);	// Return response
		$mime = curl_exec($ch);
		curl_close($ch);
		
		if ($mime && (strpos($mime, '200 OK') !== FALSE)) 
		{

			if (safe_path($file_path) && ((! file_exists($file_path)) || (! is_dir($file_path))))
			{
				$fp = fopen($file_path, "w");
				if ($fp)
				{
					$ch = curl_init($abs_url);
					if ($ch) 
					{
						curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
						curl_setopt($ch, CURLOPT_FILE, $fp);
						curl_setopt($ch, CURLOPT_HEADER, 0);
						curl_exec($ch);
						curl_close($ch);
						
						fflush($fp);
						@chmod($file_path, 0777);
						$result = $mime;
						
					}
					fclose($fp);
				}
			}
		}
	}				
	return $result;

}

function http_get_url($url)
{
	return @file_get_contents($url);
}

function http_post_file($url, $path, $headers = array())
{
	$result = FALSE;
	
	$ch = curl_init($url);
	if ($ch) 
	{
		curl_setopt($ch, CURLOPT_TIMEOUT, 600); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); // return response
		curl_setopt($ch, CURLOPT_POST, 1); 
		curl_setopt($ch,CURLOPT_FAILONERROR, 1);

		$post_fields = array();
		$post_fields['MAX_FILE_SIZE'] = filesize($path);
		$post_fields['Filedata'] = '@' . $path;
		
		curl_setopt($ch, CURLOPT_POSTFIELDS, $post_fields);
		
		if ($headers) curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
			
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);

		$curl_result = curl_exec($ch);
		if (! curl_error($ch)) 
		{
			$result = $curl_result;
			if (! $result) $result = TRUE; // it's okay that the URL didn't return anything
		}
		curl_close($ch);
		
	}
	return $result;
}

function http_post_xml($url, $xml_string, $headers = array())
{
	$result = FALSE;
	
	$ch = curl_init($url);
	if ($ch) 
	{
		curl_setopt($ch, CURLOPT_TIMEOUT, 60); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); // return response
		curl_setopt($ch, CURLOPT_POST, 1); 
		curl_setopt($ch,CURLOPT_FAILONERROR, 1);

		
		curl_setopt($ch, CURLOPT_POSTFIELDS, $xml_string);
		
		if ($headers) curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
			
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);

		$curl_result = curl_exec($ch);
		if (! curl_error($ch)) $result = $curl_result;
		
		curl_close($ch);
		
	}
	return $result;
}

?>