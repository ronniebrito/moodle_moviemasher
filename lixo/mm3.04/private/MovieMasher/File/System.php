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
include_once('MovieMasher/File.php');
include_once('MovieMasher/lib/fileutils.php');

class MovieMasher_File_System extends MovieMasher_File
{
	function MovieMasher_File_System($config = array())
	{
		parent::MovieMasher_File($config);	
	}
	function _put($options = array())
	{	
		$result = '';

		$dir_host = $this->_options['DirHost'];
		if (! $dir_host) throw new UnexpectedValueException('Configuration option DirHost required');

		$to_path = (empty($options['path']) ? '' : $options['path']);
		$from_path = (empty($options['url']) ? '' : $options['url']);
		$mime = (empty($options['mime']) ? '' : $options['mime']);
		
		if (! ($to_path && $from_path)) throw new InvalidArgumentException('Send array with url and path keys');

		if (empty($mime)) $mime = mime_from_path($from_path);
		$dir_host = end_with_slash($dir_host);

		
		$from_path = $options['url'];
		
		if (substr($to_path, 0, 1) == '/') $to_path = substr($to_path, 1);
		if (substr($to_path, 0, 1) == '/') $to_path = substr($to_path, 1);
		
		
		$to_path = $dir_host . $to_path;
		
		$extract = ($mime == mime_from_extension('tgz'));
		
		if ($extract) throw new RuntimeException("CoderArchiveExtension not supported with File::System");
		
		if (! safe_path($to_path)) throw new RuntimeException('Could not create path: ' . $to_path);
		
		$file = basename($from_path);
		if (! @rename($from_path, $to_path)) throw new RuntimeException("Could rename from: $from_path to: $to_path");
		if ($this->getOption('Verbose')) $this->log("Renamed $from_path to $to_path");
		@chmod($to_path, 0777);
		
		// TODO: fix this terrible kludge that allows ftp user to delete files
		@chmod(dirname($to_path), 0777);
		@chmod(dirname(dirname($to_path)), 0777);
		
	}
}
?>