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
package com.moviemasher.handler
{
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	import flash.display.*;
	import flash.utils.*;
	
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;

/**
* Abstract base class for audio/visual playback
*
* @see IHandler
* @see AssetFetcher
* @see AVAudio
*/
	public class Handler extends EventDispatcher implements IHandler
	{
		public function Handler(url:String)
		{ 
			_url = new RunClass.URL(url);
			if (_seekable)
			{
				__seekTimer = new Timer(10);
				__seekTimer.addEventListener(TimerEvent.TIMER, __seekTimed);
		
			}
			_load();
		}
		
		public function buffer(range:Object):void
		{
			try
			{
				if (! _playing)
				{
						
					bufferTime = range.end - range.start;
					if (time != range.start)
					{
						_time = __loopedTime(range.start);
						if (_seekable) _seekTo();
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		public function buffered(range:Object):Boolean
		{
			// default behavior bases buffered state on bytesLoaded/bytesTotal
			var is_buffered:Boolean = true;
			try
			{
			
				if (! _playing) 
				{
					is_buffered = ! _seeking;
					if (is_buffered)
					{
						is_buffered = (bytesLoaded / bytesTotal) >= Math.min(1, (__loopedTime(range.end) / duration));
							
						if (is_buffered && _seekable)
						{
							is_buffered = ! _playbackBusy();
							if (is_buffered)
							{
								is_buffered = ((_bufferedTime == range.start) || (time == range.start));
							}
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.buffered ', e);
			}
			
			return is_buffered;
		}

		protected function _seekToTime(seconds:Number):void
		{
		
		}
		
		protected function _seekTo():void
		{
			if ((! _seeking) && (_metrics != null))
			{
				_seeking = true;
				__seekTimer.start();
				_seekToTime(_time);
			}
		}
		protected function _didSeek():void
		{
				
			if (_seeking)
			{
				_bufferedTime = _time;
				_time = __loopedTime(time);
				_seeking = false;
				dispatchEvent(new Event(EventType.BUFFER));
			}
		}
		override public function toString():String
		{
			var s:String = '[' + super.toString();
			s += ' ' + _url.file;
			s += ']';
			return s;
		}
		public function unload():void
		{ 
			playing = false;
			_active = false;
		}
		public function get metrics():Size
		{ return _metrics; }
		public function get displayObject():DisplayObjectContainer
		{ return null; }
		
		public function set bufferTime(iNumber:Number):void
		{
			if (_bufferTime != iNumber)
			{
				_bufferTime = iNumber;
			}
		}
		public function set playing(iBoolean:Boolean):void
		{	
			if (_playing != iBoolean)
			{
				_playing = iBoolean;
				_playingChanged();
			}
		}
		public function set visual(iBoolean:Boolean):void
		{
			_visual = iBoolean;
		}
		
		public function get playing():Boolean
		{
			return _playing;
		}
		public function get active():Boolean
		{
			return _active;
		}
		public function set active(iBoolean:Boolean):void
		{
			_active = iBoolean;
		}
		
		public function set time(iNumber:Number):void
		{
			try
			{
				if (! _playing)
				{
					iNumber = __loopedTime(iNumber);
					if (_time != iNumber)
					{
						_time = iNumber;
						_timeChanged();
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		
		private function __loopedTime(n:Number):Number
		{
			_looped = Math.floor(n / _duration);
			if (_looped)
			{
				n = n % _duration;
			}
			return n;
		}
		public function set loops(iNumber:Number):void
		{
			_loops = Math.max(1, iNumber);
		}
		public function set volume(iNumber:Number):void
		{
			if (isNaN(iNumber))
			{
			}
			else if (_volume != iNumber)
			{
				_volume = iNumber;
				_volumeChanged();
			}
		}
		final public function get time():Number
		{
			return _getCurrentTime();
		}
		public function set duration(iNumber:Number):void
		{
			//RunClass.MovieMasher['msg'](this + '.duration ' + iNumber);
			_duration = iNumber;
		}
		public function get duration():Number
		{
			return _duration;
		}
		public function get volume():Number
		{
			return _volume;
		}
		public function get bytesLoaded():Number
		{ return 0; }
		public function get bytesTotal():Number
		{ return -1; }
		protected function _load():void
		{
			// called just once
		}
		protected function _getCurrentTime():Number
		{
			return -1;
		}
		protected function _playingChanged():void
		{ }
		protected function _timeChanged():void
		{ }
		protected function _volumeChanged():void
		{ }
		
		protected function _nearestFrameTime(n:Number):Number
		{
			var frame_seconds:Number = 1.0 / RunClass.TimeUtility['fps'];
				
			return frame_seconds * Math.round(n / frame_seconds);
		}
		public function get keepsTime():Boolean
		{
			return true;
		}
		public function destroy():void
		{
			unload();
			if (__seekTimer != null)
			{
				__seekTimer.removeEventListener(TimerEvent.TIMER, __seekTimed);
				__seekTimer = null;
			}
		}
		
		protected function _playbackBusy():Boolean
		{
			return false;
		}

		private function __seekTimed(event:TimerEvent):void
		{
			if (! _playbackBusy())
			{
				__seekTimer.stop()
				_didSeek();
			}
		}
		private var __seekTimer:Timer;
		protected var _active:Boolean = true;
		protected var _bufferedTime:Number = 0;
		protected var _bufferTime:Number = 0;
		protected var _duration:Number = 0;
		protected var _looped:Number = 0;
		protected var _loops:Number = 1;
		protected var _metrics:Size;
		protected var _playing:Boolean = false;
		protected var _seekable:Boolean = false;
		protected var _seeking:Boolean = false;
		protected var _time:Number = -1;
		protected var _url:Object;
		protected var _visual:Boolean = false;
		protected var _volume:Number = 1;
		
	}
}