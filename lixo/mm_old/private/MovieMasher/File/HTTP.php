<?php
/*
* The contents of this file are subject to the Mozilla Public
* License Version 1.1 (the "License"); you may not use this
* file except in compliance with the License. You may obtain a
* copy of the License at http://www.mozilla.org/MPL/
* 
* Software distributed under the License is distributed on an
* "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express
* or implied. See the License for the specific language
* governing rights and limitations under the License.
* 
* The Original Code is 'Movie Masher'. The Initial Developer
* of the Original Code is Doug Anarino. Portions created by
* Doug Anarino are Copyright (C) 2007-2011 Syntropo.com, Inc.
* All Rights Reserved.
*/
include_once(dirname(dirname(__FILE__)) . '/File.php');
include_once(dirname(dirname(__FILE__)) . '/lib/urlutils.php');

class MovieMasher_File_HTTP extends MovieMasher_File
{
	function MovieMasher_File_HTTP($config = array())
	{
		parent::MovieMasher_File($config);	
	}
	function &_put($options = array())
	{	
		$result = '';
		//$this->log(print_r($options, 1));
		$path = $options['url'];
		$url = 'http:/' . $options['path'];
		
		$result = http_post_file($url, $path);
		
		if (! $result) throw new RuntimeException('Could not post file: ' . $url);
		return $result;
	}
}
?>