<?php

function xml_from_string($xml_str)
{
	$result = FALSE;
	$xml = @simplexml_load_string($xml_str);
	if (is_object($xml)) 
	{
		$xml_str = $xml->asXML();
		$xml = @simplexml_load_string($xml_str);
		if (is_object($xml)) $result = $xml;
	}
	return $result;
}

function xml_safe($s)
{
	if ($s)
	{
		$s = (string) $s;
		$s = str_replace('"', '\'', $s);
		$s = str_replace("\n", ' ', $s);
		$s = str_replace("\r", ' ', $s);
		$s = htmlspecialchars($s);
		$s = str_replace('\'', '&apos;', $s);
	}
	return $s;
}

?>