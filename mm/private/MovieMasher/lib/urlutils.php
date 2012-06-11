<?php

include_once(dirname(__FILE__) . '/url_to_absolute.php');
include_once(dirname(__FILE__) . '/http_build_url.php');

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
		$options = array();
		$options[CURLOPT_FOLLOWLOCATION] = 1;
		$options[CURLOPT_HEADER] = 1;
		$options[CURLOPT_NOBODY] = 1;
		$options[CURLOPT_RETURNTRANSFER] = 1;
		__curl_set_options($ch, $options);
		
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
						$options = array();
						$options[CURLOPT_FOLLOWLOCATION] = 1;
						$options[CURLOPT_FILE] = $fp;
						$options[CURLOPT_FOLLOWLOCATION] = 1;
						$options[CURLOPT_HEADER] = 0;
		
						__curl_set_options($ch, $options);
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

function http_get_url($url, $headers = array())
{
	$result = FALSE;
	
	$ch = curl_init($url);
	if ($ch) 
	{
		$options = array();
		$options[CURLOPT_RETURNTRANSFER] = 1;
		if ($headers) $options[CURLOPT_HTTPHEADER] = $headers;
			
		__curl_set_options($ch, $options);

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

function http_post_file($url, $path, $headers = array())
{
	$result = FALSE;
	
	$ch = curl_init($url);
	if ($ch) 
	{
		$post_fields = array();
		$post_fields['MAX_FILE_SIZE'] = filesize($path);
		$post_fields['Filedata'] = '@' . $path;
		
		$options = array();
		$options[CURLOPT_RETURNTRANSFER] = 1;
		$options[CURLOPT_POST] = 1;
		$options[CURLOPT_POSTFIELDS] = $post_fields;
		if ($headers) $options[CURLOPT_HTTPHEADER] = $headers;
			
		__curl_set_options($ch, $options);

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
		$options = array();
		$options[CURLOPT_RETURNTRANSFER] = 1;
		$options[CURLOPT_POST] = 1;
		$options[CURLOPT_POSTFIELDS] = $xml_string;
		if ($headers) $options[CURLOPT_HTTPHEADER] = $headers;
			
		__curl_set_options($ch, $options);

		$curl_result = curl_exec($ch);
		if (! curl_error($ch)) $result = $curl_result;
		
		curl_close($ch);
		
	}
	return $result;
}

function __curl_set_options($ch, $options = array())
{
	if (! isset($options[CURLOPT_SSL_VERIFYPEER])) curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
	//if (! isset($options[CURLOPT_SSL_VERIFYHOST])) curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
	if (! isset($options[CURLOPT_SSLVERSION])) curl_setopt($ch, CURLOPT_SSLVERSION, 3);
	if (! isset($options[CURLOPT_TIMEOUT])) curl_setopt($ch, CURLOPT_TIMEOUT, 600); 
	if (! isset($options[CURLOPT_FAILONERROR])) curl_setopt($ch,CURLOPT_FAILONERROR, 1);
	
	foreach($options as $k => $v)
	{
		curl_setopt($ch, $k, $v);
	}

}

?>