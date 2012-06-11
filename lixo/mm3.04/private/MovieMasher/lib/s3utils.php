<?php
include_once('MovieMasher/lib/idutils.php');

@include_once 'Zend/Service/Amazon/S3.php';

function s3_base64($str)
{
	$ret = "";
	for($i = 0; $i < strlen($str); $i += 2)
		$ret .= chr(hexdec(substr($str, $i, 2)));
	return base64_encode($ret);
}

function s3_delete_file($access_key_id, $secret_access_key, $bucket_path)
{
	$result = FALSE;
	if ($access_key_id && $secret_access_key && $bucket_path)
	{
		try
		{
			$s3 = new Zend_Service_Amazon_S3($access_key_id, $secret_access_key);
			
			if ($s3->removeObject($bucket_path))
			{
				$result = TRUE;
			}
		}
		catch (Exception $ex)
		{
			//print $ex->getMessage();
		}
	}


}

function s3_hasher($data, $key)
{
	// Algorithm adapted (stolen) from http://pear.php.net/package/Crypt_HMAC/)
	if(strlen($key) > 64)
		$key = pack("H40", sha1($key));
	if(strlen($key) < 64)
		$key = str_pad($key, 64, chr(0));
	$ipad = (substr($key, 0, 64) ^ str_repeat(chr(0x36), 64));
	$opad = (substr($key, 0, 64) ^ str_repeat(chr(0x5C), 64));
	return sha1($opad . pack("H40", sha1($ipad . $data)));
}

function s3_put_data($access_key_id, $secret_access_key, $bucket_path, $data, $mime)
{
	$result = FALSE;
	if ($access_key_id && $secret_access_key && $bucket_path && $data)
	{
		try
		{
			$s3 = new Zend_Service_Amazon_S3($access_key_id, $secret_access_key);
			$meta = array();
			$meta[Zend_Service_Amazon_S3::S3_ACL_HEADER] = Zend_Service_Amazon_S3::S3_ACL_PUBLIC_READ;
			if ($mime)
			{
				$meta[Zend_Service_Amazon_S3::S3_CONTENT_TYPE_HEADER] = $mime;
			}
		
			if ($s3->putObject($bucket_path, $data, $meta))
			{
				$result = TRUE;
			}
			else print 'putObject failed';
		}
		catch (Exception $ex)
		{
			print $ex->getMessage();
		}
	}
	return $result;
}

function s3_put_file($access_key_id, $secret_access_key, $bucket_path, $file_path, $mime)
{
	$result = FALSE;
	if ($access_key_id && $secret_access_key && $bucket_path && $file_path)
	{
		try
		{
			$s3 = new Zend_Service_Amazon_S3($access_key_id, $secret_access_key);
			$meta = array();
			$meta[Zend_Service_Amazon_S3::S3_ACL_HEADER] = Zend_Service_Amazon_S3::S3_ACL_PUBLIC_READ;
			if ($mime)
			{
				$meta[Zend_Service_Amazon_S3::S3_CONTENT_TYPE_HEADER] = $mime;
			}
		
			if ($s3->putFileStream($file_path, $bucket_path, $meta))
			{
				$result = TRUE;
			}
		}
		catch (Exception $ex)
		{
			//print $ex->getMessage();
		}
	}
	return $result;
}

function s3_upload_data($options = array())
{
	$s3data = array();
	if ( ! ( empty($options['mime']) || empty($options['path'])) )
	{
		
		if (empty($options['uniq_id'])) $options['uniq_id'] = unique_id('s3data');
		if (empty($options['acl'])) $options['acl'] = 'public-read';
		
		$policy = array();
		$policy['expiration'] = gmdate("Y-m-d\TH:i:s.000\Z", strtotime('+ 1 hour'));
		$policy['conditions'] = array();
		$policy['conditions'][] = array('eq', '$bucket', $options['bucket']);
		$policy['conditions'][] = array('eq', '$key', $options['path']);
		$policy['conditions'][] = array('eq', '$acl', $options['acl']);
		$policy['conditions'][] = array('eq', '$Content-Type', $options['mime']);
		
		
		$policy['conditions'][] = array('starts-with', '$Filename', '');
		// for some reason this has to be 'starts-with' rather than 'eq'
		$policy['conditions'][] = array('starts-with', '$success_action_status', '201');
	
		
		$policy = base64_encode(stripslashes(json_encode($policy)));
		
		$s3data['key'] = $options['path'];
		$s3data['bucket'] = $options['bucket'];
		$s3data['acl'] = $options['acl'];
		$s3data['policy'] = $policy;
		$s3data['signature'] = s3_base64(s3_hasher($policy, $options['AWSSecretAccessKey']));
	}
	return $s3data;
}

if (!function_exists('json_encode'))
{
  function json_encode($a=false)
  {
    if (is_null($a)) return 'null';
    if ($a === false) return 'false';
    if ($a === true) return 'true';
    if (is_scalar($a))
    {
      if (is_float($a))
      {
        // Always use "." for floats.
        return floatval(str_replace(",", ".", strval($a)));
      }

      if (is_string($a))
      {
        static $jsonReplaces = array(array("\\", "/", "\n", "\t", "\r", "\b", "\f", '"'), array('\\\\', '\\/', '\\n', '\\t', '\\r', '\\b', '\\f', '\"'));
        return '"' . str_replace($jsonReplaces[0], $jsonReplaces[1], $a) . '"';
      }
      else
        return $a;
    }
    $isList = true;
    for ($i = 0, reset($a); $i < count($a); $i++, next($a))
    {
      if (key($a) !== $i)
      {
        $isList = false;
        break;
      }
    }
    $result = array();
    if ($isList)
    {
      foreach ($a as $v) $result[] = json_encode($v);
      return '[' . join(',', $result) . ']';
    }
    else
    {
      foreach ($a as $k => $v) $result[] = json_encode($k).':'.json_encode($v);
      return '{' . join(',', $result) . '}';
    }
  }
}




?>