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
	import fl.video.*;
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;

/**
* Class handles playback of FLV files
*
* @see IHandler
* @see AssetFetcher
* @see AVVideo
*/
	public class FLVHandler extends Handler
	{	
		public function FLVHandler(url:String) {
			_seekable = true;
			super(url); // will call _load()
		}
		override public function destroy():void {
			super.destroy();
			if (__videoPlayer != null)
			{
				__videoPlayer.removeEventListener(VideoEvent.READY, __videoPlayerReady);
				__videoPlayer.removeEventListener(VideoEvent.STATE_CHANGE, __videoPlayerStateChange);
				if (_container && _container.contains(__videoPlayer))
				{
					_container.removeChild(__videoPlayer);
				}
				try
				{
					__videoPlayer.stop();
				}
				catch(e:*)
				{
				
				}
			}
			__videoPlayer = null;	
			_container = null;
		}
		override public function unload():void 
		{
			if (_container.parent) _container.parent.removeChild(_container);
			super.unload();
		}
		override public function get displayObject():DisplayObjectContainer { 
			_container.visible = true;
			return _container; 
		}
		override public function get bytesLoaded():Number { return ((__videoPlayer == null) ? 0 : __videoPlayer.bytesLoaded); }
		override public function get bytesTotal():Number { return ((__videoPlayer == null) ? -1 : __videoPlayer.bytesTotal); }
		override public function set bufferTime(iNumber:Number):void {
			if (_bufferTime != iNumber)
			{
				_bufferTime = iNumber;
				if (__videoPlayer != null) __videoPlayer.bufferTime = _bufferTime;
				
			}
		}
		override protected function _getCurrentTime():Number
		{
			return _nearestFrameTime(__videoPlayer.playheadTime);
		}
		override protected function _load():void {
			
			_seeking = true;
			
			
			__videoPlayer = new VideoPlayer();
			__videoPlayer.scaleMode = VideoScaleMode.NO_SCALE;
			//__videoPlayer.autoPlay = false;
			__videoPlayer.addEventListener(VideoEvent.READY, __videoPlayerReady);
			__videoPlayer.addEventListener(VideoEvent.STATE_CHANGE, __videoPlayerStateChange);
			// this never gets called because we do our seeking when the video is paused
			//__videoPlayer.addEventListener(VideoEvent.SEEKED, __videoPlayerSeeked);
				
			_container = new Sprite();
			_container.visible = false;
			_container.addChild(__videoPlayer);
			__videoPlayer.load(_url.absoluteURL);
		}
		override protected function _playbackBusy():Boolean {
			var busy:Boolean = true;
			switch(__videoPlayer.state)
			{
				case VideoState.PAUSED:
				case VideoState.STOPPED:
					busy = false;
			}
			return busy;
		}
		override protected function _playingChanged():void 
		{
			//RunClass.MovieMasher['msg'](this + '._playingChanged ' + _playing);

			if (_playing) 
			{
				_volumeChanged(); 
				_dontStall = true; // stops us from sending BUFFER when we get buffering state change
				_play();
				_dontStall = false;
			}
			else
			{
				// make sure buffered returns false, so we get a buffer message before playing again
				_bufferedTime = -1;
				_pause();
			}
		}
		
		override protected function _seekToTime(seconds:Number):void {
			__videoPlayer.seek(seconds);
		}
		override protected function _volumeChanged():void {
			__videoPlayer.soundTransform = new SoundTransform(_volume);
			
		}
		protected function _play():void
		{
			__videoPlayer.play();
				
		}
		protected function _pause():void
		{
			__videoPlayer.pause();
		}
		
		private function __dimensionsTimed(event:TimerEvent):void {
			if (__videoPlayer.width && __videoPlayer.height)
			{
				_metrics = new Size(__videoPlayer.width, __videoPlayer.height);
				
				// VideoPlayer seems to center within container?
				__videoPlayer.y = __videoPlayer.x = 0;
			
						
				if (__dimensionsTimer != null)
				{
					__dimensionsTimer.removeEventListener(TimerEvent.TIMER, __dimensionsTimed);
					__dimensionsTimer.stop();
					__dimensionsTimer = null;
					
				}
				if (_time > 0)
				{
					_seeking = false;
					_seekTo();
				}
				else 
				{
					_seeking = true;
					_didSeek();
				}
			}
				
		}
		private function __videoPlayerReady(event:VideoEvent):void {
			
			try
			{
				__dimensionsTimed(null);
				if (_metrics == null)
				{
					__dimensionsTimer = new Timer(1000);
					__dimensionsTimer.addEventListener(TimerEvent.TIMER, __dimensionsTimed);
					__dimensionsTimer.start();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __videoPlayerStateChange(event:VideoEvent):void {
			/*
			VideoState.DISCONNECTED
			VideoState.STOPPED
			VideoState.PLAYING
			VideoState.PAUSED
			VideoState.BUFFERING
			VideoState.LOADING
			VideoState.CONNECTION_ERROR
			VideoState.REWINDING
			VideoState.SEEKING
			*/
			switch (event.state)
			{
				case VideoState.BUFFERING:
					if (_playing && (! _dontStall))
					{
						dispatchEvent(new Event(EventType.STALL));
					}
					break;
				case VideoState.STOPPED:
				case VideoState.PAUSED:
					if (_seeking && _metrics)
					{
						_didSeek();
					}
					break;
			}
		}
		
		protected var _dontStall:Boolean = false;
		private var __dimensionsTimer:Timer;
		private var __videoPlayer:VideoPlayer;
		private var __needsNCManager:NCManager;
		protected var _container:DisplayObjectContainer;
		
	}
}