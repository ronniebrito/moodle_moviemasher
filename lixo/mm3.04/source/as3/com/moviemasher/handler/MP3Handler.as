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
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.events.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	
/**
* Class handles playback of MP3 audio
*
* @see IHandler
* @see AssetFetcher
* @see AVAudio
*/

	public class MP3Handler extends Handler
	{
		public function MP3Handler(url:String)
		{
			super(url);
		}
		override protected function _load():void
		{
			// called just once
			_sound = new Sound();
			_sound.load(new URLRequest(_url.absoluteURL), new SoundLoaderContext(10, true));
			_sound.addEventListener(Event.COMPLETE, __soundComplete);
			_sound.addEventListener(ProgressEvent.PROGRESS, __soundProgress);
		}
		
		override public function destroy():void
		{ 
			super.destroy();
			if (_sound != null)
			{
				_sound.removeEventListener(Event.COMPLETE, __soundComplete);	
				_sound.removeEventListener(ProgressEvent.PROGRESS, __soundProgress);	
				_sound = null;
			}
		}
		override public function get duration():Number
		{
			return _duration * _loops;// - 1);
		}

		override public function get bytesLoaded():Number
		{
			return (((_sound == null) || (isNaN(_sound.bytesLoaded))) ? 0 : _sound.bytesLoaded);
		}
		override public function get bytesTotal():Number
		{
			return (((_sound == null) || (isNaN(_sound.bytesTotal)) || (! _sound.bytesTotal)) ? -1 : _sound.bytesTotal);
		}
		override protected function _getCurrentTime():Number
		{
			var n:Number = -1;
			if (_playing && (_soundChannel != null) )//&&  (_soundChannel.position != __lastSeeked))
			{
				//if (! isNaN(__lastSeeked)) RunClass.MovieMasher['msg'](this + '._getCurrentTime ' + __lastSeeked + ' != ' + _soundChannel.position + ' @ ' + _time);
				//__lastSeeked = NaN;//_soundChannel.position;
				n = _soundChannel.position / 1000;
				if (_time > n) _looped++;
				_time = n;
				n += _looped * _duration;
			}
			return n;
		}
				
		override protected function _volumeChanged():void
		{
			if (_soundChannel != null)
			{
				_soundChannel.soundTransform = new SoundTransform(_volume);
			}
		}
		//private var __lastSeeked:Number = NaN;
		override protected function _playingChanged():void
		{
			if (_playing)
			{
				__needsReloop = ((_loops > 1) && (_time != 0))
				var loop_count:int = (__needsReloop ? 0 : (_loops - 1) - _looped);
				//RunClass.MovieMasher['msg'](this + '._playingChanged ' + _time);
				_soundChannel = _sound.play(_time * 1000, loop_count, new SoundTransform(_volume));
				_soundChannel.addEventListener(Event.SOUND_COMPLETE, __soundChannelComplete);
			}
			else 
			{
				if (_soundChannel != null)
				{
					//__lastSeeked = _soundChannel.position;
					_soundChannel.removeEventListener(Event.SOUND_COMPLETE, __soundChannelComplete);
					_soundChannel.stop();
					_soundChannel = null;
				}
				_time = -1;
			}
		
		}
		private function __soundProgress(event:ProgressEvent):void
		{
			if ((bytesLoaded / bytesTotal) >= (_time / duration))
			{
				dispatchEvent(new Event(EventType.BUFFER));
			}
		}
		private function __soundComplete(event:Event):void
		{
			try
			{
				//_sound.removeEventListener(Event.COMPLETE, __soundComplete);
				dispatchEvent(new Event(EventType.BUFFER));
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__soundComplete caught ' + e);
			}
		}
		private function __soundChannelComplete(event:Event):void
		{
			try
			{
				if (__needsReloop && _playing)
				{
					_looped++;
					__needsReloop = false;
					playing = false;
					time = _looped * _duration;
					playing = true;
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__soundChannelComplete caught ' + e);
			}
		}
		private var __needsReloop:Boolean = false;	
		private var _sound:Sound;
		private var _soundChannel:SoundChannel;
	}
}