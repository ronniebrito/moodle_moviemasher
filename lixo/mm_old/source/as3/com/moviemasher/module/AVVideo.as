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
package com.moviemasher.module
{
	
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;

/**
* Implementation class for video supported by FLVPlayback
*
* @see IModule
* @see IClip
*/
	public class AVVideo extends AVImage
	{
		public function AVVideo()
		{
			_visual = true;
		}
		override public function unbuffer(first:Number = -1, last:Number = -1):void
		{
			// do nothing here since we can't partially unload media
		}
		override public function buffer(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):void
		{
			try
			{
				if (! rebuffer) 
				{
					var quantize:Number = _getQuantize();
					var range:Object = new Object();
					range.start = RunClass.TimeUtility['timeFromFrame'](first, quantize);
					range.end = RunClass.TimeUtility['timeFromFrame'](last, quantize);
					_bufferAudio(range);
				}
			}
			catch (e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		override public function buffered(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):Boolean
		{
			_mute = false;			
			var is_buffered:Boolean = false;
			try
			{
				if (_audio != null)
				{
					var quantize:Number = _getQuantize();
					var range:Object = new Object();
					_startTime = RunClass.TimeUtility['timeFromFrame'](first, quantize)
					range.start = _startTime;
					range.end = RunClass.TimeUtility['timeFromFrame'](last, quantize);
					
					is_buffered = (rebuffer || _audio.buffered(range));
					
					if ((__displayObject == null) && is_buffered)
					{
						__createVideo();
					}					
				}	
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}				
			return is_buffered;
		}
		override protected function _getImageURL():String
		{
			var s:String = '';
			s = _getMediaProperty(MediaProperty.ICON);
			if (s == null) s = '';
			return s;
		}
		override protected function _getAudioURL():String
		{
			return _getMediaProperty(MediaProperty.URL);
		}
		private function __createVideo():void
		{
			try
			{
				var displayobject:DisplayObjectContainer = _audio.displayObject;
					
				if (displayobject != null)
				{
					_size = _audio.metrics;
					if (_size != null)
					{
						
						var url:String = _getMediaProperty(MediaProperty.AUDIO);
						if (_mute || ((url != null) && (! url.length) || (url == '0')))
						{
							// mute the audio
							volume = 0;
							_dontAdjustVolume = true;
						}
						_removeDisplay();
						__displayObject = displayobject;
						__displayObject.width = _size.width;
						__displayObject.height = _size.height;
						__displayObjectContainer.scaleX = __displayObjectContainer.scaleY = 1;
						__displayObjectContainer.addChildAt(__displayObject,0);
						_sizeDisplay();
					}
				}
			}
			catch (e:*)
			{
				RunClass.MovieMasher['msg'](this, e)
			}
		}
	}
}		

