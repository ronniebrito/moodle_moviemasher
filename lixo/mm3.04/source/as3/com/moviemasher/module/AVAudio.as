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

/**
* Implementation class for audio module
*
* @see IModule
* @see IClip
*/
	public class AVAudio extends Module
	{
		public function AVAudio()
		{
		}
		override public function unload():void
		{
			if (__audioFetcher != null)
			{
				__audioFetcher.releaseAudio(_audio);
				__audioFetcher = null;
			}
			if (_audio != null)
			{
				_audio.unload();
				_audio = null;
			}
			super.unload();
		}
		override public function buffer(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):void
		{
			try
			{
				if (! (rebuffer || mute)) 
				{
					super.buffer(first, last, mute, rebuffer);
					var quantize:Number = _getQuantize();
					
					var range:Object = new Object();
					range.start = RunClass.TimeUtility['timeFromFrame'](first, quantize);
					range.end = RunClass.TimeUtility['timeFromFrame'](last, quantize);
					
					_bufferAudio(range);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		override public function buffered(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):Boolean
		{
			super.buffered(first, last, mute, rebuffer);
			var is_buffered:Boolean = (_mute || rebuffer || (first == last));
			try
			{
				if (! is_buffered)
				{
					var quantize:Number = _getQuantize();
					_startTime = RunClass.TimeUtility['timeFromFrame'](first, quantize)
					var range:Object = new Object();
					range.start = _startTime;
					range.end = RunClass.TimeUtility['timeFromFrame'](last, quantize);
					
					if (audio != null)
					{
						_audio.loops = _getClipPropertyNumber('loops') + 1;
						is_buffered = (rebuffer || _audio.buffered(range));
					}	
					else is_buffered = (__audioFetcher == null);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return is_buffered;
		}
		override public function getFrame():Number
		{
			var n:Number = -1;
			if (_playing && (_audio != null))
			{
				n = _audio.time;
				if (n != -1) 
				{
					n = RunClass.TimeUtility['frameFromTime'](n, _getQuantize(), ''); // don't round
				}
			}
			return n;
		}
		override public function setFrame(clip_frame:Number):Boolean
		{ 
			var changed:Boolean = super.setFrame(clip_frame);
			try
			{
				if ((! _playing) && (_audio != null))
				{
					//RunClass.MovieMasher['msg'](this + '.setFrame setting audio time = ' + RunClass.TimeUtility['timeFromFrame'](clip_frame, _getQuantize()));
					_audio.time = RunClass.TimeUtility['timeFromFrame'](clip_frame, _getQuantize());
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return changed;
		}
		override public function set volume(percent:Number):void
		{
			if ((! _dontAdjustVolume) && (_audio != null))
			{
				_audio.volume = percent;
			}
		}
		override public function set playing(iBoolean:Boolean):void
		{
			if (_playing != iBoolean)
			{
				_playing = iBoolean;
				if ((_audio != null))
				{
					_audio.playing = ((! _mute) && _playing);
				}
			}
		}
		public function get audio():IHandler
		{
			var url:String;
			try
			{
				if (_audio == null)
				{
					url = _getAudioURL();
					if (url.length)
					{
						var media_duration:Number = _getMediaPropertyNumber(MediaProperty.DURATION);
						if (! media_duration)
						{
							RunClass.MovieMasher['msg'](this + '.audio with no media duration ' + media.tag.toXMLString());
						}
						else
						{
							if (__audioFetcher == null)
							{
								__audioFetcher = RunClass.MovieMasher['assetFetcher'](url);
								__audioFetcher.addEventListener(Event.COMPLETE, __fetcherComplete);
								__audioFetcher.retain();
							}
							_audio = __audioFetcher.handlerObject(url);
							if (_audio != null)
							{
								_audio.addEventListener(EventType.BUFFER, _audioBuffer);
								_audio.addEventListener(EventType.STALL, _audioStall);
								_audio.duration = media_duration;
								//RunClass.MovieMasher['msg'](this + '.audio setting duration = ' + media_duration + ' ?= ' + _audio.duration);
								_audio.visual = _visual;
								_audio.time = _startTime;
							}
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.audio', e);
			}
			return _audio;
		}
		protected function _bufferAudio(time_range:Object):void
		{
			try
			{
				_startTime = time_range.start;
				if (! _mute)
				{
					if (audio != null)
					{
						_audio.buffer(time_range);
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		protected function _getAudioURL():String
		{
			var url:String = _getMediaProperty(MediaProperty.AUDIO);
			if (url == null) 
			{
				url = '';
			}
			return url;
		}
		protected function _audioBuffer(event:Event):void
		{
			try
			{
				dispatchEvent(new Event(EventType.BUFFER));
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __fetcherComplete(event:Event):void
		{
			try
			{
				__audioFetcher.removeEventListener(Event.COMPLETE, __fetcherComplete);
				dispatchEvent(new Event(EventType.BUFFER));
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		protected function _audioStall(event:Event):void
		{
			try
			{
				dispatchEvent(new Event(EventType.STALL));
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		override public function get keepsTime():Boolean
		{
			var keeps:Boolean = false;
			if (_audio != null)
			{
				keeps = _audio.keepsTime;
			}
			return keeps;
		}
		
		protected var _audio:IHandler = null;
		protected var _startTime:Number;
		protected var _visual:Boolean = false;
		private var __audioFetcher:IAssetFetcher;
		protected var _dontAdjustVolume:Boolean = false;
	}
}