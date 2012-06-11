<?php
/* 
Functions in this file are used by REST implementations to authenticate requests. The openssl PHP
module needs to be installed or all functions will simply return FALSE.
*/

include_once('MovieMasher/lib/xmlseclibs.php');

function private_signature($key_path, $data)
{
	$result = FALSE;
	if (function_exists('openssl_get_privatekey') && function_exists('openssl_sign') && function_exists('openssl_free_key'))
	{
		$key = @file_get_contents($key_path);
		if ($key)
		{
			$pkeyid = openssl_get_privatekey($key);
			if ($pkeyid)
			{
				if (openssl_sign($data, $result, $pkeyid)) 
				{
					$result = base64_encode($result);
				}
				openssl_free_key($pkeyid);
			}
		}
	}
	return $result;
}

function public_verify($data, $signature, $key)
{
	$result = FALSE;

	if (function_exists('openssl_get_publickey') && function_exists('openssl_verify') && function_exists('openssl_free_key'))
	{
		$pubkeyid = @openssl_get_publickey($key);
		if ($pubkeyid)
		{
			$ok = @openssl_verify($data, base64_decode($signature), $pubkeyid);
			$result = ($ok == 1);
			
			openssl_free_key($pubkeyid);
		}
	}
	return $result;
}

function read_rsa_bytes($bytes, &$offset)
{
	$len = substr($bytes, $offset, 4);
	$len = unpack("N", $len);
	$len = $len[1];
	$offset += 4;
	$bytes = substr($bytes, $offset, $len);
	$offset += $len;
	return $bytes;
}
	
function x509_from_rsa($key)
{
	$result = FALSE;
	if (class_exists('XMLSecurityKey'))
	{
		$parts = explode(' ', $key);
		$bytes = ($parts[1]);
		$bytes = base64_decode($bytes);
	
		$offset = 0;
		$encoding = read_rsa_bytes($bytes, $offset);
		$exponent = read_rsa_bytes($bytes, $offset);
		$modulus = read_rsa_bytes($bytes, $offset);
		
		$result = XMLSecurityKey::convertRSA($modulus, $exponent);
	}
	return $result;

}


			
?>