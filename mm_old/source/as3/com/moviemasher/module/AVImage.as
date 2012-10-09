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
* Implementation class for image modules
*
* @see IModule
* @see IClip
*/
	public class AVImage extends AVAudio
	{
		public function AVImage()
		{
			__displayObjectContainer = new Sprite();
			addChild(__displayObjectContainer);
		}
		override public function buffer(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):void
		{
			try
			{
				super.buffer(first, last, mute, rebuffer);
				if (__displayObject == null)
				{
					__requestDisplay();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			
		}
		
		override public function buffered(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):Boolean
		{
			var is_buffered:Boolean = super.buffered(first, last, mute, rebuffer);
			if (__displayObject == null) is_buffered = false;
			return is_buffered;
		}
		override public function unbuffer(first:Number = -1, last:Number = -1):void
		{ 
			//super.unbuffer(first, last);
		}
		override public function unload():void
		{
			 _removeDisplay();
			super.unload();
		}
		
		public function get fetcher():IAssetFetcher
		{
			return _imageLoader;
		}
		override public function setFrame(clip_frame:Number):void
		{
			super.setFrame(clip_frame);
			try
			{
				if (__displayObject != null)
				{
					if (! __displayObjectContainer.contains(__displayObject))
					{
						__displayObjectContainer.addChild(__displayObject);
					}
					_sizeDisplay();
				}
				else
				{
					dispatchEvent(new Event(EventType.STALL));
				}
					
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			
		}
		override public function get displayObject():DisplayObjectContainer
		{
			return this;
		}
		protected function _removeDisplay():void
		{
			try
			{
				if (__displayObject != null)
				{
					
					if (_imageLoader != null)
					{
						_imageLoader.releaseDisplay(__displayObject);
						_imageLoader = null;
					}
						
					if (__displayObjectContainer.contains(__displayObject))
					{
						__displayObjectContainer.removeChild(__displayObject);
					}
					__displayObject = null;
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}

		}
		protected function __requestDisplay():void
		{
			var url:String;
			try
			{
				if (_imageLoader == null)
				{
					url = _getImageURL();
					if ((url != null) && url.length)
					{
						_imageLoader = RunClass.MovieMasher['assetFetcher'](url);
						
						_imageLoader.retain();
						_imageLoader.addEventListener(Event.COMPLETE, __graphicLoaded, false, 0, true);
						if (_imageLoader.state == EventType.LOADED)
						{
							__graphicLoaded(null);
						
						}
						
					}
				}
			}
			catch(e:*)
			{	
			}
		}
		protected function _getImageURL():String
		{
			RunClass.MovieMasher['msg'](this,  _getClipProperty('url'));
			return _getClipProperty('url');
		}
		protected function __graphicLoaded(event:Event):void
		{
			try
			{
				if (_imageLoader != null) 
				{
					__displayObject = _imageLoader.displayObject(_getImageURL());
					if (__displayObject != null)
					{
						_imageLoader.removeEventListener(Event.COMPLETE, __graphicLoaded);
						dispatchEvent(new Event(EventType.BUFFER));
						
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		
		}
		protected function _sizeDisplay():void
		{
			try
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
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		protected var __displayObject:DisplayObject;
		protected var __displayObjectContainer:Sprite;
		protected var _imageLoader:IAssetFetcher;
	}
}