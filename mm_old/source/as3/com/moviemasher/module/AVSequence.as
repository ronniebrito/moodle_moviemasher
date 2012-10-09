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
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;

/**
* Implementation class for image sequence based video module
*
* @see IModule
* @see IClip
*/
	public class AVSequence extends AVAudio
	{
		public function AVSequence()
		{
			__displayObjects = new Object();
			__displayObjectContainer = new Sprite();
			_requestedObjects = new Object();
			__loaders = new Dictionary();
			addChild(__displayObjectContainer);
		}
		override public function buffer(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):void
		{
			//RunClass.MovieMasher['msg'](this + '.buffer ' + first + '->' + last);
			super.buffer(first, last, mute, rebuffer);
			try
			{
				var url:String;
				var safe_key:String;
				var loader:IAssetFetcher;
				var attempted:Dictionary = new Dictionary();
				
				var urls:Array = __urlsForFrames(first, last);
				for each (url in urls)
				{
					safe_key = url.replace(/[^\w]/g, '_');
				
					if (__displayObjects[safe_key] == null)
					{
						if (_requestedObjects[safe_key] == null)
						{
							loader = RunClass.MovieMasher['assetFetcher'](url);
							if (loader != null)
							{
								//RunClass.MovieMasher['msg'](this + '.buffer requesting ' + url);
								_requestedObjects[safe_key] = loader;
								loader.retain();
								__loaders[loader] = url;
								loader.addEventListener(Event.COMPLETE, __graphicLoaded, false, 0, true);
							}
						}
						if ((_requestedObjects[safe_key] != null) && (attempted[safe_key] == null))
						{
							attempted[safe_key] = true;
							loader = _requestedObjects[safe_key];
							__displayObjects[safe_key] = loader.displayObject(url);	
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.buffer ' + first + '->' + last + ' ' + rebuffer, e);
			}
		}
		override public function buffered(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):Boolean
		{
			//RunClass.MovieMasher['msg'](this + '.buffered ' + first + '->' + last);
			var is_buffered:Boolean = super.buffered(first, last, mute, rebuffer);
			try
			{
				if (is_buffered)
				{
					var url:String;
					var safe_key:String;
				
					var urls:Array = __urlsForFrames(first, last);
					for each (url in urls)
					{
						safe_key = url.replace(/[^\w]/g, '_');
					
						if (__displayObjects[safe_key] == null)
						{
							is_buffered = false;
							//RunClass.MovieMasher['msg'](this + '.buffered ' + first + '->' + last + ' waiting for ' + url);
							break;
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.buffered', e);
			}
			return is_buffered;
		}
		override public function unload():void
		{
			__unbuffer(_requestedObjects);
			super.unload();
		}
		override public function unbuffer(first:Number = -1, last:Number = -1):void
		{
			//RunClass.MovieMasher['msg'](this + '.unbuffer ' + first + '->' + last);
			try
			{
				var keys:Object = new Object();
				var loader:IAssetFetcher;
				var url:String;
				var safe_key:String;
				if (first != -1) 
				{
					var urls:Array = __urlsForFrames(first, last);
					for each (url in urls)
					{
						safe_key = url.replace(/[^\w]/g, '_');
						keys[safe_key] = true;
					}
				}
				var delete_keys:Object = new Object();
				
				for (safe_key in _requestedObjects)
				{
					if (keys[safe_key] == null)
					{
						delete_keys[safe_key] = true;
						//RunClass.MovieMasher['msg'](this + '.unbuffer ' + safe_key + ' (frame ' + first + '->' + last + ')');
					}
				}
				__unbuffer(delete_keys);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.unbuffer', e);
			}
			super.unbuffer(first, last);
		}
		override public function setFrame(clip_frame:Number):void
		{
			//RunClass.MovieMasher['msg'](this + '.setFrame ' + clip_frame);
		
			if (clip_frame >= 0)
			{
				super.setFrame(clip_frame);
				
				var url:String;
				var display_object:DisplayObject = null;
				var safe_key:String;
				var play_frames:Array;

				try
				{
					play_frames = __urlsForFrames(clip_frame, clip_frame);
					if (play_frames.length)
					{
						url = play_frames[0];
						
						//url = __urlFromTime(clip_frame);
						if ((url != null) && url.length)
						{
							safe_key = url.replace(/[^\w]/g, '_');
							display_object = __displayObjects[safe_key];
						}
						else RunClass.MovieMasher['msg'](this + '.setFrame AVSequence no url in ' + play_frames);
						if (__displayObject != display_object)
						{
							if ((__displayObject != null) && __displayObjectContainer.contains(__displayObject))
							{
								__displayObjectContainer.removeChild(__displayObject);
							}
							__displayObject = display_object;
							if (__displayObject != null)
							{
								__displayObjectContainer.addChildAt(__displayObject, 0);
							}
							//else RunClass.MovieMasher['msg'](this + '.setFrame AVSequence no display object for ' + url);
						}
						//else RunClass.MovieMasher['msg'](this + '.setFrame AVSequence no change in display object');
						if (__displayObject == null) 
						{
							dispatchEvent(new Event(EventType.STALL));
						}
						else __sizeDisplay();
					}
					//else  RunClass.MovieMasher['msg'](this + '.setFrame AVSequence no urls for frame ' + clip_frame);
				}
				catch(e:*)
				{
					RunClass.MovieMasher['msg'](this + '.setFrame AVSequence', e);
				}
			}
			//else RunClass.MovieMasher['msg'](this + '.setFrame AVSequence negative frame ' + clip_frame);
		}	
		override public function get displayObject():DisplayObjectContainer
		{
			return this;
		}
	
		protected var __displayObjects:Object;
		protected var _requestedObjects:Object;
		private function __graphicLoaded(event:Event):void
		{
			if (__graphicTimer == null)
			{
				__graphicTimer = new Timer(10);
				__graphicTimer.addEventListener(TimerEvent.TIMER, __graphicTimed);
				__graphicTimer.start();
				
				__loadingURLs = new Array();
			}
		
			__loadingURLs.push(event.target);
			__graphicTimed(event);
		}
		private function __graphicTimed(event:Event):void
		{
			try
			{
				if (__loadingURLs.length)
				{
					var i,z:int;
					var url:String;
					z = __loadingURLs.length;
					var loader:IAssetFetcher;
					var display:DisplayObject;
					
					for (i = 0; i < z; i++)
					{
						loader = __loadingURLs[i];
						if (loader.state == EventType.LOADED)
						{
							url = __loaders[loader];
							if (url != null)
							{
								display = loader.displayObject(url);		
								if ((display != null) && display.width && display.height)
								{
									var safe_key:String = url.replace(/[^\w]/g, '_');
									__displayObjects[safe_key] = display;		
									loader.removeEventListener(Event.COMPLETE, __graphicLoaded);
									__loadingURLs.splice(i, 1);
									//RunClass.MovieMasher['msg'](this + '.__graphicTimed created displayObject ' + url);
									break;
								}
							}
							else 
							{
								//RunClass.MovieMasher['msg'](this + '.__graphicTimed no URL for ' + loader);
							}
						}
					}
				}
				if (! __loadingURLs.length)
				{
					if (__graphicTimer != null)
					{
						__graphicTimer.removeEventListener(TimerEvent.TIMER, __graphicTimed);
						__graphicTimer.stop();
						__graphicTimer = null;
					}
					__loadingURLs = null;
					//RunClass.MovieMasher['msg'](this + '.__graphicTimed AVSequence BUFFER');
					dispatchEvent(new Event(EventType.BUFFER));
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__graphicTimed', e);
			}
		}
		private function __unbuffer(delete_keys:Object):void
		{
			var safe_key:String;
			var loader:IAssetFetcher;
					
			for (safe_key in delete_keys)
			{
				if (_requestedObjects[safe_key] != null) 
				{
					loader = _requestedObjects[safe_key];
					loader.releaseDisplay(__displayObjects[safe_key]);
					delete __loaders[__loaders[loader]];
					delete __loaders[loader];
					delete _requestedObjects[safe_key];
				}
				if (__displayObjects[safe_key] != null)
				{
					delete(__displayObjects[safe_key]);
				}	
			}
		}
		private function __sizeDisplay():void
		{
			if ((__displayObject != null) && (_size != null))
			{
				var fill:String = _getClipProperty(MediaProperty.FILL);
				var w:Number = __displayObject.width;
				var h:Number = __displayObject.height;
				var multiplier:Number;
				switch (fill)
				{
					case FillType.STRETCH:
						w = _size.width;
						h = _size.height;
						break;
					case FillType.SCALE:
					case FillType.CROP:
						multiplier = Math[(fill == FillType.SCALE) ? 'min' : 'max'](_size.width / w, _size.height / h);
						w = w * multiplier;
						h = h * multiplier;
						break;	
				}
				__displayObjectContainer.width = w;
				__displayObjectContainer.height = h;
				__displayObjectContainer.x = - Math.round(w / 2);
				__displayObjectContainer.y = - Math.round(h / 2);
				
			}
		}
		private function __urlFromTime(frame:Number):String
		{
			var url:String = '';
			if (! isNaN(frame))
			{
				var n:Number;
				var s:String;
				var m:IValued = media;
				var zeropadding : Number = m.getValue('zeropadding').number;
				var media_duration:Number = _getMediaPropertyNumber(MediaProperty.DURATION);
				var media_fps:Number = _getMediaPropertyNumber(MediaProperty.FPS);
				n = Math.min(frame, Math.floor(media_duration * media_fps));
				
				n *= m.getValue('increment').number;
				n += m.getValue('begin').number;
				s = String(Math.round(n));
				if (zeropadding) 
				{
					s = RunClass.StringUtility['strPad'](s, zeropadding, '0');
				}
				url = m.getValue(MediaProperty.URL).string;
				url += m.getValue('pattern').string;
				url = RunClass.StringUtility['replace'](url, '%', s);
			}
			//if (! url.length) RunClass.MovieMasher['msg'](this + '.__urlFromTime no url for frame ' + frame);
			return url;
		}
		private var __firstPlayFrame:Number = -1;
		private var __lastPlayFrame:Number = -1;
		private var __lastPlayFrames:Array;
		private var __lastURLs:Array;
		private var __firstURL:Number = -1;
		private var __lastURL:Number = -1;
		
		private function __playFrames(first:Number, last:Number):Array
		{
			
			if ((__firstPlayFrame == first) && (__lastPlayFrame == last)) return __lastPlayFrames;
			var array:Array = new Array();
			var m:IValued = media;
			
			try
			{
				if (m.getValue(CommonWords.TYPE).equals(ClipType.IMAGE)) array.push(0);
				else
				{
					var added:Object = new Object();
					var quantize:Number = _getQuantize();
					var fps:Number = m.getValue(MediaProperty.FPS).number;
					first = RunClass.TimeUtility['convertFrame'](first, quantize, 0, ''); 
					last = RunClass.TimeUtility['convertFrame'](last, quantize, 0, ''); 
					var local_frame:Number;
					var key:String;
					var now:Number;
					var max_frame:int = Math.floor(fps * m.getValue(MediaProperty.DURATION).number) - 1;
				
					
					
					for (now = first; now <= last; now ++)
					{
						local_frame = RunClass.TimeUtility['convertFrame'](now, 0, fps);
						if ((local_frame > max_frame) || (local_frame < 0)) continue;
						key = '_' + local_frame;
						if (added[key] == null)
						{
							added[key] = true;
							array.push(local_frame);
						}
					}
				
					
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__playFrames', e);
			}
			if (array.length) 
			{
				__lastPlayFrames = array;
				__firstPlayFrame = first;
				__lastPlayFrame = last;
			}
			return array;
		}
		
		private function __urlsForFrames(first:Number, last:Number):Array
		{
			//RunClass.MovieMasher['msg'](this + '.__urlsForFrames ' + first + '->' + last);
			if ((__firstURL == first) && (__lastURL == last)) return __lastURLs;
			var array:Array = new Array();
			try
			{
				var url:String;
				var now:Number = 0;
				var added:Dictionary = new Dictionary();
				var play_frames:Array = __playFrames(first, last);
				
				var frame:Number;
				for each (frame in play_frames)
				{
					url = __urlFromTime(frame);
					
					if (url.length && (added[url] == null)) 
					{
						added[url] = true;
						array.push(url);
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__urlsForFrames', e);
			}
			if (array.length) 
			{
				__lastURLs = array;
				__firstURL = first;
				__lastURL = last;
			}
			return array;
		
		}
		private var __displayObject:DisplayObject;
		private var __displayObjectContainer:Sprite;
		private var __graphicTimer:Timer;
		private var __loaders:Dictionary;
		private var __loadingURLs:Array;
		private var __unbufferTimer:Timer;
	}
}