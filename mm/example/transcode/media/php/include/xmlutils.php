<?php
function xml_append($xml_object, $tag)
{
	if (is_object($tag))
	{
		$doc = DOMDocument::loadXML($xml_object->asXML(), LIBXML_NOEMPTYTAG);
		$dom = DOMDocument::loadXML($tag->asXML(), LIBXML_NOEMPTYTAG);
		$xml_string = xml_strip_declaration($dom->saveXML(null, LIBXML_NOEMPTYTAG | LIBXML_NOXMLDECL));
		$frag = $doc->createDocumentFragment();
		$frag->appendXML($xml_string);
		$doc->documentElement->appendChild($frag);
		$xml_object = simplexml_load_string($doc->saveXML());
	}
	return $xml_object;
}
function xml_from_string($xml_str, $options = NULL)
{
	if (is_null($options)) $options = (LIBXML_NOCDATA | LIBXML_NOENT);
	$result = FALSE;
	$xml = @simplexml_load_string($xml_str, 'SimpleXMLElement', $options);
	if (is_object($xml))
	{
		$xml_str = $xml->asXML();
		$xml = @simplexml_load_string($xml_str, 'SimpleXMLElement', $options);
		if (is_object($xml)) $result = $xml;
	}
	return $result;
}
function xml_pretty($xml_str, $strip_declaration = TRUE)
{
	$dom = DOMDocument::loadXML($xml_str, LIBXML_NOBLANKS);
	$dom->formatOutput = true;
	$s = $dom->saveXML();
	if ($strip_declaration) $s = xml_strip_declaration($s);
	return $s;
}
function xml_safe($s)
{
	if ($s)
	{
		$s = (string) $s;
		$s = str_replace('"', '\'', $s);
		$s = str_replace('#', '*', $s);
		$s = str_replace("\n", ' ', $s);
		$s = str_replace("\r", ' ', $s);
		$s = htmlspecialchars($s);
		$s = str_replace('\'', '&apos;', $s);
	}
	return $s;
}
function xml_strip_declaration($xml_string)
{
	if ($xml_string)
	{
		$lines = explode("\n", $xml_string, 2);
		if (preg_match('/^\<\?xml/', $lines[0])) array_shift($lines);
		$xml_string = join("\n", $lines);
	}
	return $xml_string;
}	
function xml_write($writer, $data = array(), $key = '')
{
	reset($data);
	$is_numeric = NULL;
	foreach($data as $k => $v)
	{
		if (is_null($is_numeric)) $is_numeric = is_numeric($k);
		
		if ($key && $is_numeric) $k = $key;
		if (is_array($v)) 
		{
			$is_list = __xml_is_list($v);
			if (! $is_list) $writer->startElement($k);
			xml_write($writer, $v, $k);
			if (! $is_list) $writer->fullEndElement(); // $k	
		}
		else __xml_write_string($writer, $k, $v);
	}
}
function xml_writer($first_tag = '', $is_document = FALSE)
{
	$writer = new XMLWriter();
	$writer->openMemory();
	$writer->setIndent(TRUE);
	if ($is_document) $writer->startDocument('1.0', 'UTF-8');
	if ($first_tag) $writer->startElement($first_tag);
	return $writer;
}
function __xml_is_list($v)
{
	$is = FALSE;
	if (is_array($v))
	{
		foreach($v as $key => $value)
		{
			$is = is_numeric($key);
			break;
		}
	}
	return $is;
}
function __xml_write_string($writer, $k, $s)
{
	$writer->startElement($k);
	if (substr($s, 0, 1) == '<') $writer->writeRaw($s);
	else $writer->text($s);
	$writer->fullEndElement(); // $k
}
?>