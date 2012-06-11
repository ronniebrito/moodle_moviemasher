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
	import com.moviemasher.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import ru.etcs.media.*;
	//import ru.etcs.events.WaveSoundEvent;

/**
* Class handles playback of WAV audio
*
* @see IHandler
* @see AssetFetcher
* @see AVAudio
*/
	public class WAVHandler extends Handler
	{
		public function WAVHandler(url:String)
		{
			super(url);
		}
		override protected function _load():void
		{
			// called just once
			_sound = new WaveSound(new URLRequest(_url.absoluteURL));
			_sound.addEventListener(Event.COMPLETE, __soundComplete, false, 0, true);
		}
		override public function unload():void
		{ 
			_sound = null;
			super.unload();
		}
		override protected function _getCurrentTime():Number
		{
			var n:Number = -1;
			if (_playing && (_soundChannel != null))
			{
				n = _soundChannel.position / 1000;
				n += _looped * _duration;
			}
			return n;
		}
		override public function get bytesLoaded():Number
		{
			return _sound.bytesLoaded;
		}
		override public function get bytesTotal():Number
		{
			return _sound.bytesTotal;
		}
		override protected function _timeChanged():void
		{
			if (_playing)
			{
				_playing = false;
				playing = true;
			}
		}
		override protected function _volumeChanged():void
		{
			if (_soundChannel != null)
			{
				//playing = ! (_volume == 0);
				var st:SoundTransform = _soundChannel.soundTransform;
				st.volume = _volume;
				_soundChannel.soundTransform = st;
			}
		}
		private function __soundComplete(event:Event):void
		{
			try
			{
				_sound.removeEventListener(Event.COMPLETE, __soundComplete);
				dispatchEvent(new Event(EventType.BUFFER));
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __soundChannelComplete(event:Event):void
		{
			try
			{
				_looped++;
				if (__needsReloop)
				{
					__needsReloop = false;
					time = _looped * _duration;
				}
				else
				{
					if (_looped >= _loops)
					{
						_looped = 0;
						playing = false;
					}
				} 
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		override protected function _playingChanged():void
		{
			if (_playing)
			{
				__needsReloop = ((_loops > 1) && (_time != 0))
				_soundChannel = _sound.play(_time * 1000, (__needsReloop ? 0 : (_loops - 1) - _looped), new SoundTransform(_volume));
				_soundChannel.addEventListener(Event.SOUND_COMPLETE, __soundChannelComplete, false, 0, true);
			}
			else 
			{
				if (_soundChannel != null)
				{
					_soundChannel.removeEventListener(Event.SOUND_COMPLETE, __soundChannelComplete);
					_soundChannel.stop();
				}
				time = 0;
			}
			
		}
		private var __needsReloop:Boolean = false;
		protected var _sound:WaveSound;
		protected var _soundChannel:SoundChannel;
	}
}