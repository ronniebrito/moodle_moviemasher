<?php
/* 
Functions in this file are used to manage a cache of asset files, associated meta data and
derived media. Certain functions require that FFMPEG be installed. 
*/
include_once('MovieMasher/lib/floatlibs.php');
include_once('MovieMasher/lib/shellutils.php');
include_once('MovieMasher/lib/fileutils.php');
include_once('MovieMasher/lib/urlutils.php');

function cache_url($abs_url, $dir_path)
{
	$result = FALSE;
	$dir_path = trim($dir_path);
	$abs_url = trim($abs_url);
	if ($dir_path)
	{
		
		$dir_path = end_with_slash($dir_path);
		$file_path = url_file_path($abs_url, $dir_path);
		if ($file_path)
		{
			if (file_exists($file_path)) $result = $file_path;
			else
			{
				$mime = http_get_file($abs_url, $file_path);
				if ($mime) 
				{
					$head_path = meta_file_path('http', $file_path);
					
					if (file_exists($head_path)) 
					{
						// try to delete meta files for each http header
						$head = get_file_info('http', $file_path);
						if ($head) 
						{
							$headers = http_info_from_string(NULL, $head);
							if ($headers) 
							{
								foreach($headers as $k => $v)
								{
									$info_path = meta_file_path($k, $file_path);
									if ($info_path && file_exists($info_path))
									{
										@unlink($info_path);
									}
								}
							}
						}
					}
					if (set_file_info($file_path, 'http', $mime) && set_file_info($file_path, 'url', $abs_url))
					{
						$result = $file_path;
					}
				}
			}
			if ($result) if (! set_file_info($result, 'cached', gmdate("Y-m-d H:i:s"))) $result = FALSE;
			
		}
		
	}
	return $result;
}

function cache_sequence($url, $fps, $clip_fps, $start, $duration, $dir_path, $options = array())
{
	// TODO: support $speed != 1 
	$result = FALSE;
	$url = end_with_slash($url);
	$cache_path = url_file_path($url, $dir_path);
	
	if (empty($options['zeropadding'])) $options['zeropadding'] = 0;
	if (empty($options['duration'])) $options['duration'] = str_repeat('9', max(1, $options['zeropadding'])) / $clip_fps;
	if (empty($options['zeropadding'])) $options['zeropadding'] = strlen(floor($options['duration'] * $clip_fps));
	
	if (empty($options['pattern'])) $options['pattern'] = '%.jpg';
	if (! isset($options['begin'])) $options['begin'] = 1;
	if (empty($options['increment'])) $options['increment'] = 1;
	if (empty($options['dimensions'])) $options['dimensions'] = get_file_info('dimensions', $cache_path);
	 
	
	$one = floatval(1);
	$clip_frame_seconds = $one / $clip_fps;
	$frame_seconds = $one / $fps;
	if ($duration == -1) $duration = $options['duration'];
	$stop = $start + $duration;
	
	$stop = min($stop, $options['duration']); 
	$frames = array();
	for ($i = $start; ! floatgtre($i, $stop); $i += $clip_frame_seconds)
	{
		$frame = floor($i * $clip_fps);
		$frame_key = 'frame' . $frame;
		if (! isset($frames[$frame_key])) 
		{
			$frames[$frame_key] = $frame;
		}
	}
	if ($frames)
	{
		$highest_frame = 0;
		$build_dir = $cache_path;
		if ($options['dimensions'])
		{
			$build_dir = frame_file_path($cache_path, $options['dimensions'], $clip_fps);
		}
		asort($frames);
		$frames = array_values($frames);
		$z = sizeof($frames);
		$highest_frame = $frames[$z - 1];
		$err = FALSE;
		for ($i = 0; $i < $z; $i++)
		{
			
			$frame = $frames[$i];
			$frame *= $options['increment'];
			$frame += $options['begin'];
			
			$s = (string) $frame;
			if ($options['zeropadding']) $s = str_pad($s, $options['zeropadding'], '0', STR_PAD_LEFT);
			$file_name = str_replace('%', $s, $options['pattern']);
			$file_url = $url . $file_name;
			
			$file_path = $build_dir . $file_name;
			$download = TRUE;
			if ($build_dir != $cache_path)
			{
				if (file_exists($file_path) && filesize($file_path))
				{
					$download = FALSE;
				}
			}
			if ($download)
			{
				$mime = http_get_file($file_url, $file_path);
				if (! $mime) $err = 'Could not download: ' . $file_url . ' ' . $file_path;
				else
				{
					if ($build_dir == $cache_path)
					{
						$data = @getimagesize($file_path);
						if ($data && $data[0] && $data[1])
						{
							$options['dimensions'] = $data[0] . 'x' . $data[1];
							set_file_info($cache_path, 'dimensions', $options['dimensions']);
							set_file_info($cache_path, 'duration', $options['duration']);
							set_file_info($cache_path, 'Content-Type', 'video/sequence');
							
							
							$build_dir = frame_file_path($cache_path, $options['dimensions'], $clip_fps);
							if (! safe_path($build_dir)) $err = 'Could not get safe path: ' . $build_dir;
							elseif (! @rename($file_path, $build_dir . $file_name)) $err = 'Could not rename: ' . $file_path . ' ' . $build_dir . $file_name;
							//elseif (! @copy($build_dir . $file_name, $build_dir . $zero_file_name)) $err = 'Could not create zero frame: ' . $build_dir . $zero_file_name;
							else $file_path = $build_dir . $file_name;
						}
						else $err = 'Could not get image size: ' . $file_path;
					}
				}
			}
			if ($err) break;
			
			$frames[$i] = $file_path;
		}
		if (! $err) 
		{
			for ($i = 1; $i < $highest_frame; $i++)
			{
				$s = (string) $i;
				if ($options['zeropadding']) $s = str_pad($s, $options['zeropadding'], '0', STR_PAD_LEFT);
			}
			// ffmpeg needs at least one file starting with zero, having zeropadding digits
			$options['files'] = $frames;
			$result = $options;
		}
	}
	return $result;
}

function cache_url_wav($vid_url, $dir_path, $switches = array(), $ffmpeg = '')
{
	$result = FALSE;
	$vid_file_path = cache_url($vid_url, $dir_path);
	if ($vid_file_path)
	{
		$result = cache_file_wav($vid_file_path, $switches, $ffmpeg);
	}
	return $result;
}

function cache_file_wav($vid_file_path, $switches = array(), $ffmpeg = '')
{
	$result = FALSE;
	
	if ($vid_file_path)
	{
		$wav_file_path = wave_file_path($vid_file_path);
		if ($wav_file_path) 
		{
			if (safe_path($wav_file_path))
			{
				$cmd = '';
				$cmd .= $ffmpeg;
				$cmd .= ' -i ' . $vid_file_path;
				if ($switches) $cmd .= ' ' . stringFromSwitches($switches);
				$cmd .= ' -ac 2 -ar 44100';
				$cmd .= ' -y';
				$cmd .= ' ' . $wav_file_path;
				$result = array('path' => '', 'command' => $cmd, 'result' => '');
			
				$response = shell_command($cmd);
				if ($response && file_exists($wav_file_path)) 
				{
					$result['result'] = $response;
					$result['path'] = $wav_file_path;
				}
			}
		}
	
	}
	return $result;

}

function cache_url_frames($vid_url, $fps, $start = 0, $duration = -1, $dir_path, $options = array(), $switches = array(), $ffmpeg = '')
{
	$result = FALSE;
	$ext = file_extension($vid_url);
	if ($ext)
	{
		$vid_file_path = cache_url($vid_url, $dir_path);
		if ($vid_file_path) 
		{
			$result = cache_file_frames($vid_file_path, $fps, $start, $duration, $options, $switches, $ffmpeg);
		}
	}
	return $result;
}

function cache_file_frames($vid_file_path, $fps, $start = 0, $duration = -1, $options = array(), $switches = array(), $ffmpeg = '')
{
	$result = FALSE;
	
	if ($vid_file_path && $fps && $duration && file_exists($vid_file_path))
	{
		$media_dimensions = get_file_info('dimensions', $vid_file_path, $ffmpeg);
		// target frame size, if different from video
		if (empty($options['dimensions'])) $options['dimensions'] = $media_dimensions;
	
		
		// video duration, for convenience
		if (empty($options['duration'])) $options['duration'] = get_file_info('duration', $vid_file_path, $ffmpeg);
		
		$dimensions = scale_even($options['dimensions']);
		$size = explode('x', $dimensions);
		if (empty($options['dimensions_dir'])) $options['dimensions_dir'] = $dimensions;
		$build_dir = frame_file_path($vid_file_path, $options['dimensions_dir'], $fps);
		
		
		$media_duration = $options['duration'];
		
		if ($build_dir && $media_duration && $media_dimensions && safe_path($build_dir)) 
		{
			
			$orig_size = explode('x', $media_dimensions);
			if ($duration == -1) 
			{
				$duration = $media_duration;
				if ($duration && $start) $duration -= $start;
			}
			$fps = floatval($fps);
			$start = floatval($start);
			$start_frame = ceil($fps * $start);
			
			$duration = floatval($duration);
			$media_duration = floatval($media_duration);
			
			$media_frames = floor($media_duration * $fps);
			
			$digits = strlen($media_frames);
			
			$frames = 2 + ceil($fps * $duration);
			$files = array();
			$need_files = FALSE;
			$stop_frame = $start_frame + $frames;
		//	print 'cacheVideoFileFrames: ' . $start_frame . ' to ' . $stop_frame . "\n";
			for ($i = $start_frame; $i <= $stop_frame; $i++)
			{
				$seq_file = $build_dir . str_pad(1 + $i, $digits, '0', STR_PAD_LEFT) . '.jpg';
				$files[] = $seq_file;
				if ((! $need_files) && (! file_exists($seq_file)))
				{
					$need_files = TRUE;
				}
			}
			$result = array();
			$result['files'] = $files;
		
			$err = FALSE;
					
			if ($need_files)
			{
				$cmd = '';
				$cmd .= $ffmpeg;
				
				if ($start) 
				{
					$cmd .= ' -ss ' . $start;
				}
				$cmd .= ' -s ' . $orig_size[0] . 'x' . $orig_size[1];
				$cmd .= ' -i ' . $vid_file_path;
				$cmd .= ' -s ' . join('x', scale_proud($orig_size, $size));
				
				if ($switches) $cmd .= ' ' . stringFromSwitches($switches);
				
				if (empty($switches['b']) && (! empty($options['bitrate']))) $cmd .= ' -b ' . $options['bitrate'] . 'K';
				$cmd .= ' -an -r ' . $fps . ' -vframes ' . $frames . ' ' . $build_dir . 'build%d.jpg';
				
				$result['command'] = $cmd;
				
				//print $cmd;
				$response = shell_command($cmd);
				$result['result'] = $response;
				
				if ($response) 
				{
					$last_file = '';
					for ($i = 0; $i <= $frames; $i++)
					{
						$frame_file = $build_dir . 'build' . (1 + $i) . '.jpg';
						if (! file_exists($frame_file))
						{
							// ffmpeg doesn't always write every last frame
							if ($last_file)
							{
								// so we copy the last one repeatedly
								if (! @copy($last_file, $frame_file)) $err = TRUE;
							}
							else $err = TRUE;
						}
						if (! $err)
						{
							$seq_file = $files[$i];
							$last_file = $seq_file;
							if (! @rename($frame_file, $seq_file)) $err = TRUE;
						}
						if ($err) break;
					}
				}
			}
			/*
			if (! $err)
			{
				$result['duration'] = $frames / $fps;
				$result['orig_dimensions'] = join('x', $orig_size);
				$result['orig_extension'] = file_extension($vid_file_path);
				$result['dimensions'] = join('x', $size);
				$result['type'] = 'video';
				$result['zeropadding'] = $digits;
				$result['fps'] = $fps;
				$result['orig_fps'] = get_file_info('fps', $vid_file_path, $ffmpeg);
				$result['pattern'] = '%.jpg';
				$result['icon'] = str_pad(1 + $start_frame + floor($frames / 2), $digits, '0', STR_PAD_LEFT) . '.jpg';
			}
			*/
			if ($err) $result['files'] = '';
		}
	}
	return $result;
}

function dimensions_lt($d1, $d2)
{
	$result = FALSE;
	$d1_a = explode('x', $d1);
	$d2_a = explode('x', $d2);
	if ((sizeof($d1_a) > 1) && (sizeof($d2_a) > 1))
	{
		$result = (($d1_a[0] < $d2_a[0]) || ($d1_a[1] < $d2_a[1]));
	}
	return $result;
}

function ffmpeg_info_from_string($type, $ffmpeg_output)
{
	$result = FALSE;
	$matches = array();
	switch ($type)
	{
		case 'audio':
			preg_match('/Audio: ([^,]+),/', $ffmpeg_output, $matches);
			$result = ((sizeof($matches) > 1) ? 1 : 0);
			break;
		case 'dimensions':
			preg_match('/, ([\d]+)x([\d]+)/', $ffmpeg_output, $matches);
			if (sizeof($matches) > 2) $result = $matches[1] . 'x' . $matches[2];
			break;
		case 'duration':
			preg_match('/Duration: ([\d]+):([\d]+):([\d\.]+),/', $ffmpeg_output, $matches);
			if (sizeof($matches) > 3) $result = (60 * 60 * $matches[1]) + (60 * $matches[2]) + ($matches[3]);	
			break;
		case 'fps':
			preg_match('/ ([\d\.]+) fps/', $ffmpeg_output, $matches);
			if (sizeof($matches) <= 1)
			{
				$matches = array();
				preg_match('/ ([\d\.]+) tb/', $ffmpeg_output, $matches);
			}
			if (sizeof($matches) > 1) $result = round($matches[1]);	
			break;
	}
	return $result;
}

function flush_cache_files($dir, $gigs = 0)
{
	$result = FALSE;
	if (file_exists($dir))
	{
		$kbs = $gigs * 1024 * 1024;
		$ds = directory_size_kb($dir);
		if ($ds > $kbs)
		{
			$result = flush_cache_kb($dir, $ds - $kbs);
		}
	}
	return $result;
}

function flush_cache_kb($dir, $kbs_to_flush)
{
	$cmd = '';
	$cmd .= 'du --max-depth 1 ' . $dir;
	$result = shell_command($cmd);
	if ($result)
	{
		$directories = array();
		$times = array();
		$lines = explode("\n", $result);
		foreach($lines as $line)
		{
			if (! $line) continue;
			
			$bits = explode("\t", $line);
			if ((sizeof($bits) < 2) || (! $bits[1])) continue;
			if ($bits[1] == $dir) continue;
			
			$dir = end_with_slash($bits[1]);
			
			$cached = get_file_info('cached', $dir);
			if ($cached)
			{
				$time = strtotime($cached);
				if ($time)
				{
					$times[] = $time;
					$directories[] = $bits;
				}
			}
		}
		if ($directories)
		{
			array_multisort($times, $directories);
			$z = sizeof($times);
			for ($i = 0; $i < $z; $i++)
			{
				$cmd = 'rm -R ' . $directories[$i][1];
				$result = shell_command($cmd);
				if (! $result) 
				{
					$kbs_to_flush -= $directories[$i][0];
					if ($kbs_to_flush <= 0) break;
				}
			}
		}
	}
	return ($kbs_to_flush <= 0);
}

function frame_file_path($file_path, $dimensions, $fps)
{
	$file_path = media_file_path($file_path);
	return $file_path . $dimensions . 'x' . $fps . DIRECTORY_SEPARATOR;
}

function get_file_info($type, $file_path, $ffmpeg = '')
{
	$result = FALSE;
	if ($file_path)
	{
		$info_file = meta_file_path($type, $file_path);
		$result = @file_get_contents($info_file);
		
		if (! $result)
		{
			if (file_exists($file_path)) // make sure we actually have the file
			{
				$check = array();
				
				switch($type)
				{
					case 'type':// do nothing if file doesn't already exist
					case 'http':
					case 'ffmpeg':
						break;
						
					case 'Server': // HTTP header data
					case 'ETag':
					case 'Date':
					case 'Last-Modified':
					case 'Content-Length':
					case 'Content-Type':
						$check['http'] = TRUE;
						break;
					case 'dimensions':
						if (get_file_type($file_path) == 'image')
						{
							// we can get dimensions of images with php
							$check['php'] = TRUE;
							break;
						}
					case 'duration':
						/* for when we can get duration of audio from php
						if (get_file_type($file_path) == 'audio')
						{
							$check['php'] = TRUE;
							break;
						}
						*/
					case 'fps': // only from FFMPEG
					case 'audio':
						$check['ffmpeg'] = TRUE;
						break;
					default:
						// something other than http info needed
						
						switch (get_file_type($file_path))
						{
							case 'image':
							case 'video';
							case 'audio';
								break;
							default: // couldn't get media type or type unrecognizable
								$check['http'] = TRUE;
							
						}
					
				}
				if (! empty($check['php']))
				{
					// for now just images supported
					$data = @getimagesize($file_path);
					if ($data && $data[0] && $data[1])
					{
						$result = $data[0] . 'x' . $data[1];
					}
				}
				if (! empty($check['ffmpeg']))
				{
					$data = get_file_info('ffmpeg', $file_path);
					if (! $data)
					{
						if ($ffmpeg)
						{
							$cmd = $ffmpeg;
							$cmd .= ' -i ' . $file_path;
							$data = shell_command($cmd);
							set_file_info($file_path, 'ffmpeg', $data);
						}
						
					}
					if ($data) $result = ffmpeg_info_from_string($type, $data);
					
				}
				if (! empty($check['http']))
				{
					$data = get_file_info('http', $file_path);
					if ($data)
					{
						$data = http_info_from_string($type, $data);
						if ($data) $result = $data;
					}
				}
				// try to cache the data for next time
				set_file_info($file_path, $type, $result);
						
			}
		}
	}
	return $result;
}

function set_file_info($path, $key, $data = '')
{
	$result = FALSE;
	if ($key && $path)
	{
		$a = array();
		if (is_array($key)) $a = $key;
		else $a[$key] = $data;
		foreach($a as $k => $v)
		{
			if ($v)
			{
				$info_file_path = meta_file_path($k, $path);
				$result = ($info_file_path && safe_path($info_file_path) && @file_put_contents($info_file_path, $v));
			}
			if (! $result) break;
			@chmod($info_file_path, 0777);
		}
	}
	return $result;
}

function get_file_type($path)
{
	$result = FALSE;
	if ($path)
	{
		$result = get_file_info('type', $path);
		if (! $result)
		{
			$mime = get_file_info('Content-Type', $path);
			if ($mime)
			{
				$result = array_shift(explode('/',  $mime));
				if ($result) set_file_info($path, 'type', $result);
			}
		}
	}
	return $result;
}

function get_url_info($type, $url, $dir_path, $ffmpeg = '')
{
	$result = FALSE;
	$file_path = cache_url($url, $dir_path);
	if ($file_path)
	{
		$result = get_file_info($type, $file_path, $ffmpeg);
	}
	return $result;
}

function http_info_from_string($type, $header)
{
	$result = FALSE;
	if ($header)
	{
		$retVal = array();
		$fields = explode("\r\n", preg_replace('/\x0D\x0A[\x09\x20]+/', ' ', $header));
		foreach( $fields as $field ) {
			if( preg_match('/([^:]+): (.+)/m', $field, $match) ) {
				$match[1] = preg_replace('/(?<=^|[\x09\x20\x2D])./e', 'strtoupper("\0")', strtolower(trim($match[1])));
				if( isset($retVal[$match[1]]) ) 
				{
					$retVal[$match[1]] = array($retVal[$match[1]], $match[2]);
				} 
				else  $retVal[$match[1]] = trim($match[2]);
			}
		}
		if (! is_null($type))
		{
			if (! empty($retVal[$type])) $result = $retVal[$type];
		}
		else $result = $retVal;
	}
	return $result;
}

function media_file_path($file_path)
{
	$dir_name = 'media';
	$file_path = dir_path($file_path);
	return $file_path . $dir_name . DIRECTORY_SEPARATOR;
}

function meta_file_path($type, $file_path)
{
	$dir_name = 'meta';
	$file_path = dir_path($file_path);
	return $file_path . $dir_name . DIRECTORY_SEPARATOR . $type . '.txt';
}

function scale_even($dimensions)
{
	$result = FALSE;
	if ($dimensions)
	{
		$size = explode('x', $dimensions);
		if (sizeof($size) > 1)
		{
			$result = (round(round($size[0]) / 2) * 2) . 'x' . (round(round($size[1]) / 2) * 2);
		}
	}
	return $result;
}

function scale_proud($orig_dims, $targ_dims)
{
	$result = FALSE;
	if ($orig_dims && $targ_dims)
	{
		$wants_array = TRUE;
		if (! is_array($orig_dims)) 
		{
			$wants_array = FALSE;
			$orig_dims = explode('x', $orig_dims);
		}
		if (! is_array($targ_dims))
		{
			$wants_array = FALSE;
			$targ_dims = explode('x', $targ_dims);
		}
		if ( (sizeof($orig_dims) > 1) && (sizeof($targ_dims) > 1) )
		{
			if ( ($orig_dims[0] < $targ_dims[0]) || ($orig_dims[1] < $targ_dims[1]) )
			{
				$result = $orig_dims; // no scaling up
			}
			else
			{
				
				$per = max($targ_dims[0] / $orig_dims[0], $targ_dims[1] / $orig_dims[1]);
				$orig_dims[0] = round(($orig_dims[0] * $per) / 2) * 2;
				$orig_dims[1] = round(($orig_dims[1] * $per) / 2) * 2;
				$result = $orig_dims;
			}
		}
		if ($result && (! $wants_array)) $result = join('x', $result);
	}
	return $result;
}

function scale_switches($orig_dims, $dims, $fill) // stretch, crop, scale, none
{
	$target_w = floatval($dims[0]);
	$target_h = floatval($dims[1]);
	$vf = '';
	
	$scale = 'scale=' . $target_w . ':' . $target_h;
	if ($fill && ($fill != 'stretch'))
	{
		$orig_even_w = floatval($orig_dims[0]);
		$orig_dims1 = floatval($orig_dims[1]);
		
		$extra0 = $orig_even_w % 2;
		$extra1 = $orig_dims1 % 2;
		
		$orig_even_w -= $extra0;
		$orig_dims1 -= $extra1;
		
		$ratio_w = $target_w / $orig_even_w;
		$ratio_h = $target_h / $orig_dims1;
		
		if (! floatcmp($ratio_w, $ratio_h))
		{
			$multiplier = (($fill == 'scale') ? floatmin($ratio_w, $ratio_h): floatmax($ratio_w, $ratio_h));
			$scaled_w = round($target_w / $multiplier);
			$scaled_h = round($target_h / $multiplier);
			
			if (! floatcmp($orig_even_w, $scaled_w))
			{
				if (floatgtr($orig_even_w, $scaled_w))
				{
					//$a['cropleft'] = $a['cropright'] = floor((($orig_even_w - $scaled_w) / 2));
					$vf .= 'crop=' . floor((($orig_even_w - $scaled_w) / 2)) . ':0:' . $scaled_w . ':' . $scaled_h;
					
				}
				else 
				{
					/*$pad_x = $pad_width = floor(($scaled_w -$orig_even_w) / 2);
					$pad_x -= $extra0;
					$dims[0] -= 2 * $pad_width;
					$dims[0] += $extra0;
					$dims[1] += $extra1;
				*/
					$vf .= 'pad=' . $scaled_w . ':' . $scaled_h . ':' . (floor(($scaled_w -$orig_even_w) / 2) - $extra0) . ':0';
					
					
				}
			}
			if (! floatcmp($orig_dims1, $scaled_h))
			{
				if (floatgtr($orig_dims1, $scaled_h))
				{					
					$vf .= 'crop=0:' . floor(((($orig_dims1 - $scaled_h)) / 2)) . ':' . $scaled_w . ':' . $scaled_h;
				}
				else
				{
				/*
					$pad_y = $pad_height = floor(($scaled_h - $orig_dims1) / 2);
					$pad_y -= $extra1;
					$dims[1] -= 2 * $pad_height;
					$dims[1] += $extra1;
					$dims[0] += $extra0;
					*/
					$vf .= 'pad=' . $scaled_w . ':' . $scaled_h . ':0:' . (floor(($scaled_h - $orig_dims1) / 2) - $extra1);
					
					
				}
			}
		}
		//$a['s'] = $dims[0] . 'x' . $dims[1];
	}
	if ($vf) $vf .= ',';
	$vf .= $scale;
	$a = array();
	$a['vf'] = $vf;
	return $a;
}

function url_file_path($url, $dir_path = '')
{
	$result = FALSE;
	if ($url)
	{
		$result = end_with_slash($dir_path) . md5($url) . '/';
		$extension = file_extension($url);
		if ($extension)
		{
			$result .= 'media.' . $extension;
		}
	}
	return $result;
}

function wave_file_path($file_path)
{
	$file_path = media_file_path($file_path);
	return $file_path . 'media.wav';
}

?>