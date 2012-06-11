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

include_once('MovieMasher/lib/fileutils.php');
include_once('MovieMasher/lib/xmlutils.php');

define('MOVIEMASHER_XML_DECLARATION', '<?' . 'xml version="1.0" encoding="UTF-8"' . '?>');

class MovieMasher
{
	 
	var $_options; // current runtime options
	var $_configDefaults; // default runtime options
	var $_optionsDefaults; // default runtime options
	var $__localHost = FALSE; // will contain address used by flashplayer to access local web server
	var $__host = FALSE; // will contain address used by flashplayer to access local web server
	function MovieMasher($config = array())
	{
		$this->_options = array();
		reset($config);
		foreach($config as $k => $v)
		{
			$this->_options[$k] = $v;
		}
		$this->_populateDefaults();
		foreach($this->_configDefaults as $k => $v)
		{
			if (! isset($this->_options[$k])) 
			{
				$this->_options[$k] = (isset($v['default']) ? $v['default'] : '');
			}
		}
		foreach($this->_optionsDefaults as $k => $v)
		{
			if (! isset($this->_options[$k])) 
			{
				$this->_options[$k] = (isset($v['default']) ? $v['default'] : '');
			}
		}
		
		// make sure paths have trailing slashes		
		
		$this->_options['DirLog'] = end_with_slash($this->_options['DirLog']);
		$this->_options['DirCache'] = end_with_slash($this->_options['DirCache']);
		$this->_options['DirHost'] = end_with_slash($this->_options['DirHost']);
		$this->_options['DirTemporary'] = end_with_slash($this->_options['DirTemporary']);
	}
	function addDelimiters($s, $delimiter = '/', $just_end = 0)
	{
		return $this->_addDelimiters($s, $delimiter, $just_end);
	}
	function &arrayFromXML($xml, $tag_name = '')
	{
		$a = array();
		if ($tag_name) 
		{
			
			$xml = $xml->xpath('//' . $tag_name);
			if (sizeof($xml)) 
			{
				$xml = $xml[0];
			}
			else $xml = '';
		}
		if ($xml)
		{
			$tags = $xml->children();
		
			$z = sizeof($tags);
			for ($i = 0; $i < $z; $i++)
			{
				
				$x = $tags[$i];
				$a[$x->getName()] = (string) $x;
			}
		}		
		return $a;
	}
	function &fromConfig($xml, $module, $implementation = '', $init_options = array())
	{
		if (! $xml) throw new InvalidArgumentException('Send XML configuration or path to it for first argument');
		if (! $module) throw new InvalidArgumentException('Send module name for second argument');
		$config_is_file = '';
		if (is_string($xml))
		{
			if (substr($xml, 0, 1) != '<')
			{
				$config_is_file = $xml;
				$xml_string = file_get($xml);
				if (! $xml_string) throw new RuntimeException('Could not load XML file: ' . $xml);
				$xml = $xml_string;
			}
			$xml = @simplexml_load_string($xml);
		}
		if (! is_object($xml)) throw new RuntimeException('Could not parse XML: ' . $xml);
		
		
		$options = array();
		$options['module'] = $module;
		
		// add tags under MovieMasher tag, or root if tag not nested
		$moviemasher_options = MovieMasher::arrayFromXML($xml, 'MovieMasher');
		if (! $moviemasher_options) $moviemasher_options = MovieMasher::arrayFromXML($xml);
		$options = array_merge($options, $moviemasher_options);
		
		// add tags specific to module
		//$options = array_merge($options, MovieMasher::arrayFromXML($xml, $module));
		
		// if implementation was specified as argument, see if it's specified in the configuration
		if ((! $implementation) && (! empty($options[$module]))) $implementation = $options[$module];

		// if no implementation was specified anywhere then we'll wind up instancing immediate subclass of MovieMasher
		if ($implementation) 
		{
			// but one was, so set it and add tags specific to implementation
			$options[$module] = $implementation;
			$options = array_merge($options, MovieMasher::arrayFromXML($xml, $module . $implementation));
		}
		if ($init_options) $options = array_merge($options, $init_options);
		$path = $name = $module;
		$c = 'MovieMasher';
		if (! empty($implementation)) 
		{
			$path .= '/' . $implementation;
			$name .= '_' . $implementation;
			$c .= '_' . $name;
		}
		include_once('MovieMasher/' . $path . '.php');
		if ($config_is_file && empty($options['PathConfiguration'])) $options['PathConfiguration'] = $config_is_file;
		
		
		$result = new $c($options);
		if (! is_object($result)) throw new RuntimeException('Could not instance class: ' . $c);
		
		$result->validateConfiguration();
		
		return $result;
	}
	function getConfigDefault($k = '')
	{
		return ($k ? (isset($this->_configDefaults[$k]['default']) ? $this->_configDefaults[$k]['default'] : '') : $this->_configDefaults);
	}
	function getOption($k = '')
	{
		$val = '';
		if ($k && isset($this->_options[$k]))
		{
			$val = $this->_options[$k];
			if (substr($k, 0, 4) == 'Host')
			{
				// support retrieval of host from URL
				if (strpos($val, '://')) 
				{
					$val = @file_get_contents($val);
					$this->_options[$k] = $val; // caches lookup while this instance persists
				}
			}
		}
		return $val;
	}
	function getVersion()
	{
		if (empty($this->__version))
		{
			$this->__version = @file_get_contents('MovieMasher/VERSION.txt', 1);
			if (! $this->__version) $this->__version = (empty($this->_options['Version']) ? '' : $this->_options['Version']);
			
		}
		return $this->__version;
		
	}
	function help($parameter = '', $as_array = 0, $configORoption = null)
	{
		
		$helps = array();
		if ($parameter)
		{
			$s = '';
			if (! empty($this->_configDefaults[$parameter])) $s = $this->_configDefaults[$parameter];
			else if (! empty($this->_optionsDefaults[$parameter])) $s = $this->_optionsDefaults[$parameter];
			if (is_array($s))
			{
				if ($as_array) $helps = $s;
				else $helps[] = $s['value'] . ' ' . $s['description'] . (empty($s['default']) ? '' : ' Default: ' . $s['default'] . '.');	
			}
		}
		else
		{
			if (is_null($configORoption)) $configORoption = 'options';
			$defs = '_' . $configORoption . 'Defaults';
			foreach($this->$defs as $parameter => $s)
			{
				if ($as_array)
				{
					$s['id'] = $parameter;
					$helps[] = $s;
				}
				else $helps[] = $parameter . ': ' . $s['value'] . ' ' . $s['description'] . (empty($s['default']) ? '' : ' Default: ' . $s['default'] . '.');	
			}
		}
		if (! $helps) $helps = array('Help not found ' . $parameter);
		if (! $as_array) $helps = join("\n", $helps) . "\n";
		return $helps;
	}
	function log($s, $priority = '')
	{
		
		if (! empty($this->_options['DirLog']))
		{
			if (! file_exists($this->_options['DirLog'])) mkdir($this->_options['DirLog'], 0777);
			
			if (file_exists($this->_options['DirLog']))
			{
				$prelog = date('Y-m-d H:i:s') . ' ';
				$prelog .= (empty($_SERVER['REQUEST_URI']) ? $_SERVER['SCRIPT_NAME'] : $_SERVER['REQUEST_URI']) . "\n";
				$path = $this->_addDelimiters($this->_options['DirLog']) . 'log_' . date('Y-m-d') . '.txt';
				$existed = file_exists($path);
				
				$fp = fopen($path, 'a');
				if ($fp)
				{
					$s = $prelog . $s . "\n";
					
					fwrite($fp, $s, strlen($s));
					fclose($fp);
				}
				if (! $existed) @chmod($path, 0777);
			}
		}
		

	}
	function &parse($template_path, $template_data = array())
	{
		extract($template_data);
		ob_start();
		include($template_path);
		$s = ob_get_clean();
		return $s;
	}
	function setOption($name, $val)
	{
		$this->_options[$name] = $val;
	}
	function setOptions($options)
	{
		foreach($options as $k => $v)
		{
			$this->setOption($k, $v);	
		}
	}
	function validateConfiguration()
	{
	}
	function validateOptions($onlyknown = 0)
	{
		reset($this->_options);
		
		foreach($this->_options as $name => $val)
		{
			if ((! isset($this->_optionsDefaults[$name])))
			{
				if ($onlyknown) throw new UnexpectedValueException('Configuration option ' . $name . ' unknown');
			}
			elseif ((! strlen($val)) && empty($this->_optionsDefaults[$name]['emptyok']))
			{
				throw new UnexpectedValueException('Configuration option ' . $name . ' required');				
			}
		}
	}
	function _addDelimiters($s, $delimiter = '/', $just_end = 0)
	{
		if (! $s) return $delimiter;
		if ((! $just_end) && (substr($s, 0, 1) != $delimiter)) $s = $delimiter . $s;
		if (substr($s, -1) != $delimiter) $s .= $delimiter;
		return $s;	
	}
	function _populateDefaults()
	{
		$this->_configDefaults = array();
		$this->_optionsDefaults = array();
		
		
		$this->_configDefaults['File'] = array(
			'value' => 'STRING',
			'description' => "The MovieMasher_File implementation to use for storage.",	
			'default' => 'System',
		);
		$this->_configDefaults['Client'] = array(
			'value' => 'STRING',
			'description' => "The MovieMasher_Client implementation to use.",	
			'default' => 'Local',
		);
		
		$this->_configDefaults['DirCache'] = array(
			'value' => 'DIR',
			'description' => "Downloaded files will be created and eventually removed from this directory.",	
			'default' => '',
			'emptyok' => 1,
		);
		$this->_configDefaults['DirLog'] = array(
			'value' => 'DIR',
			'description' => "Date specific log files will be created in this directory.",	
			'default' => '',
			'emptyok' => 1,
		);
		$this->_configDefaults['DirTemporary'] = array(
			'value' => 'DIR',
			'description' => "Temporary files will be created and removed from this directory.",	
			'default' => '/tmp/moviemasher/',
			'emptyok' => 1,
		);
		$this->_configDefaults['DirHost'] = array(
			'value' => 'DIR',
			'description' => "Root directory for storage.",
			'default' => '',
			'emptyok' => 1,
		);
		$this->_configDefaults['Host'] = array(
			'value' => 'ALIAS',
			'description' => "How to refer to host from another machine, can be server address or URL returning one.",	
			'default' => '',
			'emptyok' => 1,
		);
		$this->_configDefaults['HostLocal'] = array(
			'value' => 'ALIAS',
			'description' => "How to refer to host from this machine, can be server address or URL returning one.",	
			'default' => 'localhost',
			'emptyok' => 1,
		);
		$this->_configDefaults['HostCGI'] = array(
			'value' => 'ALIAS',
			'description' => "How to refer to CGI host from another machine, can be server address or URL returning one.",	
			'default' => '',
			'emptyok' => 1,
		);
		$this->_configDefaults['LogErrors'] = array(
			'value' => 'BOOLEAN',
			'description' => "If true, errors will be added to the log.",	
			'default' => 1,
			'emptyok' => 1,
		);
		$this->_configDefaults['PathConfiguration'] = array(
			'value' => 'PATH',
			'description' => "XML formatted configuration file for new instances.",	
			'default' => '',
			'emptyok' => 1,
		);
		$this->_configDefaults['Verbose'] = array(
			'value' => 'BOOLEAN',
			'description' => "If true, much more feedback will be logged.",	
			'default' => 0,
			'emptyok' => 1,
		);
	}
	function _removeDelimiters($s, $delimiter = '/')
	{
		if (substr($s, 0, 1) == $delimiter) $s = substr($s, 1);
		if (substr($s, -1) == $delimiter) $s = substr($s, 0, -1);
		return $s;	
	}
}
?>