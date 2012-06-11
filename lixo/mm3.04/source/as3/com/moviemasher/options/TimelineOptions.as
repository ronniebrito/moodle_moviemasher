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

package com.moviemasher.options
{
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
/**
* Implementation class for timeline preview options
*
* @see Browser
* @see IOptions
*/
	public class TimelineOptions extends PreviewOptions
	{
		public function TimelineOptions()
		{
			super();
			
			try
			{
			
				// text properties that vary depending on selected and disabled 
				
				_defaults.waveblend = 'normal';
				_multiples.sel.push('waveblend');
				
				
				// non varying text properties
				_defaults.x = '';
				_defaults.y = '';
				_defaults.xcrop = '';
				_defaults.starttrans = '';
				_defaults.endtrans = '';
				_defaults.leftcrop = '';
				_defaults.rightcrop = '';
				_defaults.widthcrop = '';
				
				_defaults.wave = '';
				_defaults.effectheight = ''; // height of effect track, if any
				_defaults.videoheight = ''; // height of video track, if any
				_defaults.audioheight = ''; // height of audio track, if any
				_defaults.spacing = ''; // distance between backgrounds
				_defaults.notrim = ''; // whether or drag preview edges
				_defaults.nodrag = ''; // whether or not to drag preview

				_defaults.trimstartframe = '';
				_defaults.startframe = '';
				_defaults.duration = '';
				_defaults.loop = '';
				_defaults.loops = '';
				
				_defaults.clip = '';
				_defaults.timeline = '';
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		
	}
}