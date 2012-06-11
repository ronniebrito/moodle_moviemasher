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

package com.moviemasher.display
{
	import flash.geom.*;
	import flash.display.*;
	import flash.events.*;
	import com.moviemasher.utils.DrawUtility;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.options.*;
	
/**
* Abstract base class represents visual containers with controls
*
* @see Control
* @see BarView
* @see ControlView
* @see PanelView
*/
	public class View extends PropertiedSprite
	{
		public function View()
		{
			// create container for children
			__children_mc = new Sprite();
			addChild(__children_mc);

			
		}
		public function setRect(rect : Rectangle):void
		{
			
			x = rect.x;
			y = rect.y;
			if (__invalidated || __dontCache || (! ((_width == rect.width) && (_height == rect.height))))
			{
				__invalidated = false;
				_width = rect.width;
				_height = rect.height;
				if (visible) resize();
			}
			
		}
		public function callControls(method:String):void
		{
			var z:int = __children.length;
			for (var i:int = 0; i < z; i++)
			{
				__children[i].callControls(method);
			}
		}
				
		protected function _resizeView():void
		{
			try
			{
			
				var mode:String = getValue('mode').string;
				if (mode.length)
				{
					blendMode = BlendMode[mode.toUpperCase()];
				}
				var options:BoxOptions = new BoxOptions();
				for (var k:String in _defaults)
				{
					options.setValue(new Value(_defaults[k]), k);
				}
				options.tag = _tag;
				options.setValue(new Value(_width), 'width');
				options.setValue(new Value(_height), 'height');
				
				RunClass.DrawUtility['shadowBox'](options, this);
				var border:Number = getValue('border').number;
				var padding:Number =  getValue(ControlProperty.PADDING).number;
				var url:String = getValue('background').string;
				if (url.length)
				{
					if (__background != null)
					{
						__background.mask = null;
						removeChild(__background);
						removeChild(__background_mask_mc);
						__background_mask_mc = null;
					}
					var loader:IAssetFetcher = RunClass.MovieMasher['assetFetcher'](url);
					
					__background = loader.displayObject(url, '', new Size(_width - (2 * border), _height - (2 * border)));
					if (__background != null)
					{
						
						addChildAt(__background, 0);
						__background.y = __background.x = border;
						// MASK
						// create a mask for container in container
						__background_mask_mc = new Sprite();
						addChild(__background_mask_mc);
						__background.mask = __background_mask_mc;
				
						__background_mask_mc.graphics.clear();
						RunClass.DrawUtility['setFill'](__background_mask_mc.graphics, 0x000000);
						RunClass.DrawUtility['drawPoints'](__background_mask_mc.graphics, RunClass.DrawUtility['points'](border, border, _width - (2 * border), _height - (2 * border), getValue('curve').number));
	
					}
				}		
				if (! getValue('dontmask').boolean)
				{
					
					// MASK
					__children_mask_mc.graphics.clear();
					RunClass.DrawUtility['setFill'](__children_mask_mc.graphics, 0x000000);
					RunClass.DrawUtility['drawPoints'](__children_mask_mc.graphics, RunClass.DrawUtility['points']((padding + border), (padding + border), _width - (2 * (padding + border)), _height - (2 * (padding + border)), getValue('curve').number));
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._resizeView', e);
			}
		}
		public function resize():void
		{
			_resizeView();
		}
		private var __invalidated:Boolean = true;
		public function invalidate():void
		{
			__invalidated = true;
		}
		public function get isLoading():Boolean
		{
			return Boolean(_loadingThings);
		}
		protected function _tagCompleted(event:Event)
		{
			try
			{
				event.target.removeEventListener(Event.COMPLETE, _tagCompleted);
				__backCompleted(event);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._tagCompleted', e);
			}
		}
		protected function __backCompleted(event:Event)
		{
			try
			{
				//event.target.removeEventListener(Event.COMPLETE, __backCompleted);
				_loadingThings--;
				
				if (! _loadingThings) 
				{
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__backCompleted', e);
			}
		}
		override protected function _parseTag():void
		{
			__dontCache = getValue('dontcache').boolean;
			var url:String = getValue('background').string;
			if (url.length)
			{
				var loader:IAssetFetcher = RunClass.MovieMasher['assetFetcher'](url);
				
				if (loader.state == EventType.LOADING)
				{
					_loadingThings++;
				
					loader.addEventListener(Event.COMPLETE, __backCompleted, false, 0, true);
				}
			}
			if (! getValue('dontmask').boolean)
			{
				// create a mask for container of children
				__children_mask_mc = new Sprite();
				__children_mc.addChild(__children_mask_mc);
				__children_mc.mask = __children_mask_mc;
			}
		}
		private var __dontCache:Boolean = false;
		protected var __background:DisplayObject;
		protected var _loadingThings:Number = 0;
		protected var _width:Number = 0;
		protected var _height:Number = 0;
		protected var __children:Array;
		protected var __children_mc : Sprite;// mask for above
		protected var __children_mask_mc : Sprite;// mask for above
		protected var __background_mask_mc : Sprite;// mask for above

	}
}