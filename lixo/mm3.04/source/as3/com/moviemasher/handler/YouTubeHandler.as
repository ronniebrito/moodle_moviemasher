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
	// see http://code.google.com/apis/youtube/flash_api_reference.html
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;


/**
* Class handles playback of YouTube videos using their embedded player
*
* @see IHandler
* @see AssetFetcher
* @see AVVideo
*/
	public class YouTubeHandler extends FLVHandler
	{
		public function YouTubeHandler(url:String) {
			// for YouTube videos, url is "[ID].youtube"
			_metrics= new Size(320, 240);
			super(url);
		}
		override public function destroy():void {
			super.destroy();
			if (__youtubePlayer != null)
			{
				__youtubePlayer.addEventListener("onReady", __onPlayerReady);
				__youtubePlayer.addEventListener("onError", __onPlayerError);
				__youtubePlayer.addEventListener("onStateChange", __onPlayerStateChange);
				
				__youtubePlayer.destroy();
			}
			if (__loader != null)
			{
				__loader.contentLoaderInfo.removeEventListener(Event.INIT, __initLoader);
			
				__loader.unload();
			}
			__youtubePlayer = null;	
			__loader = null;
		}
		override public function get bytesLoaded():Number { 
			var n:Number = 0;
			if (__youtubePlayer != null)
			{
				if (__ready)
				{
					n = __youtubePlayer.getVideoBytesLoaded(); 
				}
			}
			return n;
		}
		override public function get bytesTotal():Number { 
			var n:Number = -1;
			if (__youtubePlayer != null)
			{
				if (__ready) 
				{
					n = __youtubePlayer.getVideoBytesTotal(); 
				}
			}
			return n;
		}
		
		override protected function _getCurrentTime():Number {
			var t:Number = -1;
			try
			{
				if (__youtubePlayer != null) 
				{
					t = _nearestFrameTime(__youtubePlayer.getCurrentTime());		
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._getCurrentTime', e);
			}
			return t;
		}
		override protected function _load():void {
			// called just once
			Security.allowDomain("*");
			__loader = new Loader();
			__loader.contentLoaderInfo.addEventListener(Event.INIT, __initLoader);
			_container = __loader;
			_container.visible = false;
			//RunClass.MovieMasher['instance'].addChild(_container);
			__loader.load(new URLRequest("http://www.youtube.com/apiplayer?version=3"));
						
		}
		override protected function _volumeChanged():void {			
			if (__youtubePlayer != null)
			{
				__youtubePlayer.setVolume(Math.round(_volume * 100));
			}	
		}
		override protected function _pause():void {
			if (__youtubePlayer != null)
			{
				__youtubePlayer.pauseVideo();
			}
		}
		override protected function _play():void 
		{
			//RunClass.MovieMasher['msg'](this + '._play __youtubePlayer' + __youtubePlayer);
			if (__youtubePlayer != null)
			{
				__youtubePlayer.playVideo();
			}
		}
		override protected function _playbackBusy():Boolean {
			var busy:Boolean = true;
			if (__youtubePlayer != null)
			{
				switch(String(__youtubePlayer.getPlayerState()))
				{
					case YouTubeHandler.ENDED: // ended
					case YouTubeHandler.PAUSED: // paused
						busy = false;
				}
			}
			return busy;
		}
		override protected function _seekToTime(seconds:Number):void {
		
			if (__youtubePlayer != null)
			{
				__youtubePlayer.seekTo(seconds, true);
			}
		}
		private function __initLoader(event:Event):void {
			__loader.content.addEventListener("onReady", __onPlayerReady);
			__loader.content.addEventListener("onError", __onPlayerError);
			__loader.content.addEventListener("onStateChange", __onPlayerStateChange);
		}
		private function __onPlayerError(event:Event):void {
			// Event.data contains the event parameter, which is the error code
		}
		private function __onPlayerReady(event:Event):void {
			// Event.data contains the event parameter, which is the Player API ID 
		
			// Once this event has been dispatched by the player, we can use
			// cueVideoById, loadVideoById, cueVideoByUrl and loadVideoByUrl
			// to load a particular YouTube video.
			__youtubePlayer = __loader.content;
			if (__youtubePlayer != null)
			{
				__youtubePlayer.loadVideoById(_url.file);
			}
        }
        private function __onPlayerStateChange(event:Event):void {
			// Event.data contains the event parameter, which is the new player state
			switch(String(Object(event).data))
			{
				case YouTubeHandler.BUFFERING:
					if (_playing && (! _dontStall))
					{
						//__seekingTo = _time;
						__ready = false;
						dispatchEvent(new Event(EventType.STALL));
					}
					break;
				case YouTubeHandler.PLAYING: // playing
					if (! _playing) _pause();
					break;
				case YouTubeHandler.PAUSED: 
					if (! __inited)
					{
						__ready = true;
						__inited = true;
						if (_time > 0)
						{
							_seekTo();
						}
						else 
						{
							_seeking = true;
							_didSeek();
						}
					}
					break;
			}
		}
		
		private var __inited:Boolean = false;
		private var __isAt:Number = -1;
		private var __loader:Loader;
		private var __youtubePlayer:Object;
		private var __ready:Boolean = false;
		private var __seekedTo:Number = -1;
		private var __seekingTo:Number = -1;
		private var __seekTimer:Timer;
		private var __startedAt:Number;
		public static const BUFFERING:String = '3';
		public static const CUED:String = '5';
		public static const ENDED:String = '0';
		public static const PAUSED:String = '2';
		public static const PLAYING:String = '1';
		public static const UNSTARTED:String = '-1';

		
	}
}