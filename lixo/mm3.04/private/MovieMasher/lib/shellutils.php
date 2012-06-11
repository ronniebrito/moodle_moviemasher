<?php

function nextResourceLine($resource)
{
	$s = '';
	while((!feof($resource)) && (($c = fread($resource, 1)) != ':')) { $s .= $c; }
	return $s;
}

function shell_command($s, $target = ' 2>&1', $dont_escape = 0)
{
	$result = '';
	ob_start();
	if (! $dont_escape) $s = shell_escape($s);
	system($s . $target, $output);
	if ($output) $result .= $output . "\n";
	$output=ob_get_clean();
	if ($output) $result .= $output . "\n";
	return $result;
}

function shell_converse($conversation = array(), $env = array(), $cwd = '/tmp')
{
	$result = '';
	$z = sizeof($conversation);
	if ($z > 1)
	{
		$descriptorspec = array(
		   0 => array("pipe", "r"),  // stdin is a pipe that the child will read from
		   1 => array("pipe", "w"),  // stdout is a pipe that the child will write to
		   2 => array("pipe", "w") // stderr is a file to write to
		);
		
		$cmd = shell_escape($conversation[0]);
		
		
		
		$process = proc_open($cmd, $descriptorspec, $pipes, $cwd, $env);
		
		if (is_resource($process)) 
		{
		
			for ($i = 1; $i < $z; $i++)
			{
				$cmd = shell_escape($conversation[$i]);
				$result .= nextResourceLine($pipes[2]);
				fwrite($pipes[0], $cmd . "\n");
			}
			
			$result .= nextResourceLine($pipes[2]);
			
			fclose($pipes[2]);
			fclose($pipes[1]);
			fclose($pipes[0]);
			
			
			$code = proc_close($process);
			$result .= join("\n", $conversation); 
		}
	}
	return $result;
}

function shell_escape($cmd)
{
	
	// Escape whole string
	$cmdQ = escapeshellcmd($cmd);
	
	 // Build array of quoted parts, and the same escaped
	preg_match_all('/\'[^\']+\'/', $cmd, $matches);
	$matches = current($matches);
	$quoted = array();
	foreach( $matches as $match )
		$quoted[escapeshellcmd($match)] = $match;
	
	// Replace sections that were single quoted with original content
	foreach( $quoted as $search => $replace )
	{
		$cmdQ = str_replace( $search, $replace, $cmdQ );
	}
	return $cmdQ;
}

function stringFromSwitches($a)
{
	$s = array();
	foreach($a as $k => $v)
	{
		$s[] = '-' . $k . ' ' . $v;
	}
	return join(' ', $s);
}

function switchesFromString($s)
{
	$a = array();
	if ($s)
	{
		$s = trim($s);
		preg_match_all('/-([a-z]+) ([^-]+)/', $s, $matches, PREG_SET_ORDER);
		foreach ($matches as $match)
		{
			$a[$match[1]] = $match[2];
		}
	}
	return $a;
	
}

?>