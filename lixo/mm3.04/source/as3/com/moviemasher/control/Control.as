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
package com.moviemasher.control
{
	import com.moviemasher.display.*;
	import com.moviemasher.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;

/**
* Abstract base class for all controls
*/
	public class Control extends PropertiedSprite implements IControl
	{
		public function Control()
		{
			__loaders = new Dictionary();
			_defaults = new Object();
			_displayedObjects = new Object();
		}
		protected function _createChildren():void
		{ }
		public function dispatchPropertyChange(is_ing : Boolean = false):void
		{
			try
			{
				var change_event:ChangeEvent = new ChangeEvent(getValue(_property), _property);
				change_event.done = ! is_ing;
				dispatchEvent(change_event);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}

		}
		public function initialize():void
		{
			
			if ((! flexible) && _ratioKey.length)
			{
				var path:String = getValue(_ratioKey).string;
				if (path.length)
				{
					var loader:IAssetFetcher = RunClass.MovieMasher['assetFetcher'](path) as IAssetFetcher;
					var display_object:DisplayObject = loader.displayObject(path);
					
					if (display_object != null)
					{
						__ratio = display_object.width / display_object.height;
					}
				}
			}
		}		
		public function finalize():void
		{
			
		}
		public function resize():void
		{ _update(); }
		override public function setValue(value:Value, property:String):Boolean
		{
			super.setValue(value, property);
			_update();
			return false;
		}
		public function updateTooltip(tooltip:ITooltip):Boolean
		{
			var dont_delete:Boolean = false;
			var tip:String;
			try
			{
				tip = getValue('tooltip').string;
				dont_delete = Boolean(tip.length);
				if (dont_delete)
				{
					tip = RunClass.ParseUtility['brackets'](tip);
					dont_delete = Boolean(tip.length);
				}
				if (dont_delete) tooltip.text = tip;
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}		
			return dont_delete;
		}
		override public function get height():Number
		{
			return _height;
		}
		override public function get width():Number
		{
			return _width;
		}
		public function set disabled(iBoolean:Boolean):void
		{			
			//if (getValue('id').equals('downloader')) RunClass.MovieMasher['msg']('disabled = ' + iBoolean);
			_disabled = iBoolean;
			_update();
		}
		public function get displayObject():DisplayObjectContainer
		{
			return this;
		}
		public function get flexible():Number
		{

			var n:Number = 0;
			var value:Value = getValue(getValue('vertical').boolean ? 'height' : 'width');
			if (! value.empty)
			{
				if (value.NaN)
				{
					n = value.string.length;
				}
			}
			return n;
		}
		public function set hidden(iBoolean:Boolean):void
		{
			_hidden = iBoolean;
			// no need to set visibility since ControlView does it
		}
		public function get isLoading():Boolean
		{
			return Boolean(_loadingThings);
		}
		public function set metrics(iMetrics:Size):void
		{
			_width = iMetrics.width;
			_height = iMetrics.height;
			_resizing = true;
			resize();
			_resizing = false;
		}
		public function get metrics():Size
		{
			return new Size(_width, _height);
		}
		public function set property(iProperty:String):void
		{
			_property = iProperty;
		}
		public function get ratio():Number
		{
			return __ratio;
		}
		public function set selected(iBoolean:Boolean):void
		{
			_selected = iBoolean;
			_update();
		}
		override final protected function _parseTag():void
		{
			
			if (_allowFlexibility)
			{
				var wORh:String = (getValue('vertical').boolean ? 'height' : 'width');
				if (! getValue(wORh).string.length)
				{
					_defaults[wORh] = '*';
				}
			}
			try
			{
				_createChildren();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}		

		}
		protected function _createTooltip() : void
		{
			addEventListener(MouseEvent.MOUSE_OVER, __mouseOver);
			useHandCursor = false;
			
			if (! getValue('tooltip').empty)
			{
				var url:String;
				url = getValue('tooltipsymbol').string;
				if (! url.length)
				{
					url = RunClass.MovieMasher['getOption']('tooltip', 'symbol');
				}
				if (url.length)
				{
					_displayObjectLoad(url, true);
					url = RunClass.MovieMasher['getOption']('tooltip', ModuleProperty.FONT);
					if (url.length)
					{	
						var font_tag:XML = RunClass.MovieMasher['fontTag'](url);
						if (font_tag != null)
						{
							_displayObjectLoad(font_tag.@url, true);
						}
					}
				}
			}
		}
		protected function _displayObjectLoad(property:String, is_url:Boolean = false):Boolean
		{
			var is_loading:Boolean = false;
			var url:String = property;
			if (! is_url)
			{ 
				url = getValue(property).string;
				if (property == ModuleProperty.FONT)
				{
					var font_tag:XML = RunClass.MovieMasher['fontTag'](url);
					if (font_tag != null)
					{
						url = font_tag.@url;
					}
				}
			}
			if (url.length)
			{
				var loader:IAssetFetcher = RunClass.MovieMasher['assetFetcher'](url) as IAssetFetcher;
				if (loader.state == EventType.LOADING)
				{
					if (__loaders[loader] == null)
					{
						__loaders[loader] = true;
						loader.addEventListener(Event.COMPLETE, __didLoad, false, 0, true);
						_loadingThings++;
				
						is_loading = true;
					}
				}
				
			}
			return is_loading;
		}
		protected function _displayObjectSize(property:String, size:Size = null, container:DisplayObjectContainer = null):DisplayObject
		{
			var display_object:DisplayObject = null;
			
			var url:String = getValue(property).string;
			if (url.length)
			{
				if (container == null)
				{
					container = this;
				}
				var vertical:Boolean = getValue('vertical').boolean;
				if (size == null)
				{
					size = new Size();
				}
				else
				{
					size = size.copy() as Size;
				}
			
				if ((! size.width) && vertical)
				{
					size.width = getValue('width').number;
					if (! size.width) 
					{
						size.width = _width;
					}
				}
				if ((! size.height) && (! vertical))
				{
					size.height = getValue('height').number;
					if (! size.height) 
					{
						size.height = _height;
					}
				}
				
				var loader:IAssetFetcher = RunClass.MovieMasher['assetFetcher'](url) as IAssetFetcher;
			
				display_object = loader.displayObject(url, '', size);
				if (display_object != null)
				{
					if (_displayedObjects[property] != display_object)
					{
						if (_displayedObjects[property] != null)
						{
							container.removeChild(_displayedObjects[property]);
						}
						_displayedObjects[property] = display_object;
						container.addChild(display_object);
					}
				}
			}
			
			
			return display_object;
		}
		protected function _mouseDrag():void
		{ }
		protected function _mouseHover(event:MouseEvent):void
		{ }
		protected function _mouseOut():void
		{}	
		protected function _mouseOver(event:MouseEvent):void
		{}
		protected function _release() : void
		{ }
		protected function _update() : void
		{}
		protected var _allowFlexibility:Boolean = false;
		protected var _disabled : Boolean = false;
		protected var _displayedObjects:Object;
		protected var _height:Number = 0;
		protected var _loadingThings:uint = 0;
		protected var _property:String = '';
		protected var _ratioKey:String = '';
		protected var _resizing : Boolean = false;
		protected var _selected : Boolean = false;
		protected var _value:String = '';
		protected var _width:Number = 0;
		protected var _hidden:Boolean;
		private function __didLoad(event:Event):void
		{
			try
			{
				_loadingThings--;
				
				if (! _loadingThings)
				{
					__loaders = null;
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __mouseHover(event:MouseEvent) : void
		{
			try
			{		
				_mouseHover(event);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __mouseOut(event:MouseEvent) : void
		{
			try
			{
				removeEventListener(MouseEvent.MOUSE_MOVE, __mouseHover);
				removeEventListener(MouseEvent.MOUSE_OUT, __mouseOut);
				_rollTimerCancel();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			try
			{
				_mouseOut();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __mouseOver(event:MouseEvent) : void
		{
			try
			{
				if ( ! (RunClass.MouseUtility['dragging'] || _disabled))
				{
					addEventListener(MouseEvent.MOUSE_MOVE, __mouseHover);
					addEventListener(MouseEvent.MOUSE_OUT, __mouseOut);
					__rollTooltip(event);
					_mouseOver(event);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		protected function _rollTimerCancel():void
		{
			try
			{
				if (__rollTimer != null)
				{
					__rollTimer.stop();
					__rollTimer.removeEventListener(TimerEvent.TIMER, __rollTimed);
					__rollTimer = null;
				}
				RunClass.MovieMasher['setTooltip']();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			
		}
		private function __rollTimed(event:TimerEvent):void
		{
			try
			{
				_rollTimerCancel();
				if (hitTestPoint(root.mouseX, root.mouseY))
				{
					var i_tooltip:ITooltip = _displayedObjects.tooltipsymbol;
					var c:Class;
					
					if (i_tooltip == null)
					{
						var url:String;
						url = getValue('tooltipsymbol').string;
						if (! url.length)
						{
							url = RunClass.MovieMasher['getOption']('tooltip', 'symbol');
						}
						if (url.length)
						{
							var loader:IAssetFetcher = RunClass.MovieMasher['assetFetcher'](url, 'swf');
							c = loader.classObject(url);
							if (c != null)
							{
								i_tooltip = new c();
								if (i_tooltip != null)
								{
									_displayedObjects.tooltipsymbol = i_tooltip;
									i_tooltip.tag = RunClass.MovieMasher['getOptionXML']('tooltip', 'symbol');
									//i_tooltip.text = getValue('tooltip').string;
								}
							}
						}
					}
					if (i_tooltip != null)
					{
						RunClass.MovieMasher['setTooltip'](i_tooltip, this);
						i_tooltip.displayObject.addEventListener(Event.REMOVED, __tooltipRemoved);
					}
					
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
	
		private function __rollTooltip(event:MouseEvent) : void
		{
			try
			{
				if (! getValue('tooltip').empty)
				{
					if ((__lastTooled != null) && (((new Date().getTime()) - __lastTooled.getTime()) < 1000))
					{
						__rollTimed(null);
					}
					else if (__rollTimer == null)
					{
						__rollTimer = new Timer(1000, 1);
						__rollTimer.addEventListener(TimerEvent.TIMER, __rollTimed);
						__rollTimer.start();
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		
		}
		private function __tooltipRemoved(event:Event):void
		{
			try
			{
				event.target.removeEventListener(Event.REMOVED, __tooltipRemoved);
				__lastTooled = new Date();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private var __rollTimer:Timer;
		private static var __lastTooled:Date;
		private var __loaders:Dictionary;
		private var __ratio:Number = 0;
	}
}