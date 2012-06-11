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
package com.moviemasher.preview
{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import com.moviemasher.events.*;
	import com.moviemasher.options.*;
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.control.Browser;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.utils.*;
	import flash.display.*;
	import flash.system.*;
	import flash.geom.*;
/**
* Implementation class media preview appearing in a browser 
*
* @see Browser
* @see IPreview
*/
	public class BrowserPreview extends Sprite implements IPreview
	{
		public function BrowserPreview()
		{
			// create container for elements
			__mask_mc = new Sprite();
			addChild(__mask_mc);
			__children_mc = new Sprite();
			addChild(__children_mc);
			__children_mc.mask = __mask_mc;
			_displayObjectContainer = new Sprite();
			__children_mc.addChild(_displayObjectContainer);
			useHandCursor = false;
			__label_back_mc = new Sprite();
			__children_mc.addChild(__label_back_mc);
			__label_mc = new TextField();
			__children_mc.addChild(__label_mc);
		}
		public function get backBounds():Rectangle
		{
			return __mask_mc.getBounds(this);
		}
		public function set container(previewContainer:IPreviewContainer):void
		{
			_container = previewContainer;
		}
		public function get container():IPreviewContainer
		{
			return _container;
		}
		public function get size():Size
		{
			return new Size(__mouse_mc.width, __mouse_mc.height);
		}
		private function __clipFromXML(xml:XML):IClip
		{
			var iclip:IClip = null;
		
			iclip = RunClass.Clip['fromXML'](xml);
			if (! iclip.getValue(ClipProperty.LENGTHFRAME).boolean)
			{
				iclip.setValue(new Value(RunClass.TimeUtility['fps'] * 10), ClipProperty.LENGTHFRAME);
			}
			return iclip;
		}
		public function set mediaTag(xml:XML):void
		{
			_mediaTag = xml;
		}
		public function get mediaTag():XML
		{
			return _mediaTag;
		}
		public function set clip(iclip:IClip):void
		{
			_clip = iclip;
		}
		public function get clip():IClip
		{
			if (_clip == null) _clip = __clipFromXML(_mediaTag);
			return _clip;
		}
		
		
		override public function toString():String
		{
			var s:String = '[' + super.toString();
			if (_options != null)
			{
				var icon:String = _options.getValue('icon').string;
							
				if ((icon != null) && icon.length)
				{
					s += ' ' + icon;
				}
			}
			s += ']';
			return s;

		}
		private function __createMouse():void
		{
			try
			{
				
				if (__mouse_mc == null) 
				{
					__mouse_mc = new Sprite();
					addChild(__mouse_mc);
					__mouse_mc.addEventListener(MouseEvent.MOUSE_OVER, __doRollOver);
					__mouse_mc.addEventListener(MouseEvent.MOUSE_DOWN, __doPress);
				
					__mouse_mc.useHandCursor = false;
				
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__createMouse', e);
			}
		
		}
		
		private function __doPress(event:MouseEvent):void
		{
			try
			{
				if (! RunClass.MouseUtility['dragging']) 
				{
					_container.downPreview(this, event);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__doPress', e);
			}
		}	
		private function __doRollOver(event:MouseEvent):void
		{
				
			try
			{
				if (! RunClass.MouseUtility['dragging']) 
				{
					RunClass.MovieMasher['instance'].addEventListener(MouseEvent.MOUSE_MOVE, __doMoveOver);
					__doMoveOver(event);
					//if (event != null) event.updateAfterEvent();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__doRollOver', e);
			}
		}
		private function __doMoveOver(event:MouseEvent):void
		{
			try
			{
				if ((! RunClass.MouseUtility['dragging']))
				{
					if (__mouse_mc.hitTestPoint(event.stageX, event.stageY, false))
					{
						_container.overPreview(this, event);
					}
					else
					{
						RunClass.MovieMasher['instance'].removeEventListener(MouseEvent.MOUSE_MOVE, __doMoveOver);
						_container.outPreview(this, event);
					}
					//event.updateAfterEvent();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__doMoveOver ' + event, e);
			}
		}
		
		
		protected function _resizeLabel():Number
		{
			var sel:String = (_selected ? 'sel' : '');
			var border:Number = _options.getValue(ControlProperty.BORDER).number;
			var icon_y:Number = border;
			try
			{
				var textheight:Number = _options.getValue('textheight').number;
				var textsize:Number = _options.getValue('textsize').number;
				if (textheight && textsize)
				{
					var textbackalpha:Number = _options.getValue(sel + 'textbackalpha').number;
					
					var textbackcolor:String = _options.getValue(sel + 'textbackcolor').string;
					var textcolor:String = _options.getValue(sel + 'textcolor').string;
					
					var textvalign:String = _options.getValue('textvalign').string;
					var text_width : Number = 0;
					var w:Number = _options.getValue('width').number;
					var text_y : Number;
					
					text_width = _iconWidth;				
					__label_mc.width = text_width;				
					__label_mc.height = textheight;		
					
					var tf:TextFormat = __label_mc.defaultTextFormat;
					tf.color = RunClass.DrawUtility['colorFromHex'](textcolor);
					__label_mc.defaultTextFormat = tf;
					__label_mc.text = __label_mc.text;
					
					
					switch(textvalign)
					{
						case 'below':
						
							text_y = _iconHeight + border;
							break;
						
						case 'above':
						
							text_y = border;
							icon_y += textheight;
							break;
						
						case 'bottom':
						
							text_y = _iconHeight + border - textheight;
							break;
						
						case 'middle':
						case 'center':
						
							text_y = border + ((_iconHeight - textheight) / 2);
							break;
					}
					__label_mc.x = __label_back_mc.x = border;
					__label_back_mc.y = text_y;
					__label_mc.y = text_y + _options.getValue('textoffset').number;
					
					__label_back_mc.graphics.clear();
					RunClass.DrawUtility['fill'](__label_back_mc.graphics, text_width, textheight, RunClass.DrawUtility['colorFromHex'](textbackcolor), textbackalpha);			
				}
			//	if (isNaN(text_y)) RunClass.MovieMasher['msg'](this + '._resizeLabel ' + text_y + ' ' + textvalign + ' ' + _iconHeight + ' ' + border );
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return icon_y;
		}
		
		protected function _resize() : void
		{
			try
			{
				var sel:String = (_selected ? 'sel' : '');
				var textvalign:String = _options.getValue('textvalign').string;
				var textsize:Number = _options.getValue('textsize').number;
				var w:Number = _options.getValue('width').number;
				var h:Number = _options.getValue('height').number;
				var textheight:Number = _options.getValue('textheight').number;
				var border:Number = _options.getValue(ControlProperty.BORDER).number;
				var ratio:Number = _options.getValue('ratio').number;
				_iconHeight = 0;
				_iconWidth = 0 ;
				if (w)
				{
					_iconWidth = w - (2 * border);
				}
				if (ratio)
				{
					_iconHeight = _iconWidth / ratio;
				}
				else if (h)
				{
					_iconHeight = h - (2 * border);
				}

				var icon_y:Number = _resizeLabel();
				
				var label_height : Number = 0;
				if (textheight && textsize)
				{
					switch(textvalign)
					{
						case 'above':
						case 'below':
						
							label_height += textheight;
							break;
					}
				}
				_displayObjectContainer.x = border;
				_displayObjectContainer.y = icon_y;
				
				if (! h)
				{
					h = _iconHeight + (2 * border) + label_height;
					_options.setValue(new Value(h), 'height');
				}
				_drawBack();
				__mask_mc.graphics.clear();
				RunClass.DrawUtility['setFill'](__mask_mc.graphics, 0x000000);
				RunClass.DrawUtility['drawPoints'](__mask_mc.graphics, RunClass.DrawUtility['points'](border, border, w - (2 * border), h - (2 * border), _options.getValue('curve').number));

				if (_displayObject == null)
				{
					_drawPreview();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		protected function _drawBack():void
		{
			RunClass.DrawUtility['shadowBox'](_options, this, (_selected ? 'sel' : ''));
			
			RunClass.DrawUtility['fill'](__mouse_mc.graphics, _options.getValue('width').number, _options.getValue('height').number, 0, 0);
				
		}
		public function set data(object:Object):void
		{
			var defined:Boolean = (_data != null);
			//RunClass.MovieMasher['msg'](this + '.data ' + defined);
			_data = object;
			if (! defined) _initialize();
			_optionsChanged();
		}
		public function get data():Object
		{
			return _data;
		}
		public function unload():void
		{
			if (__mouse_mc != null)
			{
				removeChild(__mouse_mc);
			}
			if (_loader != null)
			{
				
				_loader.releaseDisplay(_displayObject);
				_loader.removeEventListener(Event.COMPLETE, _displayLoaded);
				_loader = null;
			}
			if (__children_mc != null)
			{
				if (_displayObjectContainer != null)
				{
					if (_displayObject != null)
					{
						if (_displayObject is IModule)
						{
							var module:IModule = _displayObject as IModule;
							module.unload();
						}
						if (_displayObjectContainer.contains(_displayObject))
						{
							_displayObjectContainer.removeChild(_displayObject);
						}
						
						_displayObject = null;
					}
					__children_mc.removeChild(_displayObjectContainer);
					_displayObjectContainer = null;
				}
				if (__label_back_mc != null)
				{
					__children_mc.removeChild(__label_back_mc);
					__label_back_mc = null;
				}
				if (__label_mc != null)
				{
					__children_mc.removeChild(__label_mc);
					__label_mc = null;
				}
				__children_mc = null;
			}
		}
		
		public function get displayObject():DisplayObjectContainer
		{
			return this;
		}
		
		public function get options():IOptions
		{
			return _options;
		}
		public function set options(value:IOptions):void
		{
			//RunClass.MovieMasher['msg'](this + '.options');
			_options = value;
		}
		public function set selected(value:Boolean):void
		{
			if (_selected != value)
			{
				_selected = value;
				_resize();
				_displayObjectContainer.blendMode = BlendMode[_options.getValue((_selected ? 'sel' : '') + 'blend').string.toUpperCase()];
				if ((_displayObject != null) && (_displayObject is IModule))
				{
					var module:IModule = _displayObject as IModule;
					module.animating = _selected;
				}
			}
		}
		protected function _drawPreview() : Boolean 
		{
			var called_resize:Boolean = true;
			try
			{
				if (_displayObject == null)
				{
					called_resize = false;
					if (_loader == null)
					{
						var icon:String = _options.getValue('icon').string;
						if (icon.length)
						{
							_loader = RunClass.MovieMasher['assetFetcher'](icon);

							_loader.retain();
							_displayLoadURL();
							called_resize = (_displayObject != null);
							if (! called_resize) _loader.addEventListener(Event.COMPLETE, _displayLoaded);
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return called_resize;
		}
		protected function _addDisplayObject():void
		{
			try
			{
				_displayObjectContainer.addChild(_displayObject);
				_displayObjectContainer.blendMode = BlendMode[_options.getValue((_selected ? 'sel' : '') + 'blend').string.toUpperCase()];
				if (_displayObject is IModule)
				{
					var module:IModule = _displayObject as IModule;
					var display_size:Size = _displaySize();
					_displayObject.x = display_size.width / 2;
					_displayObject.y = display_size.height / 2;
				
					//	RunClass.MovieMasher['msg'](this + '._addDisplayObject ' + display_size);
					module.runningAsPreview = this;
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._addDisplayObject ' + _displayObject, e);
			}
	
		}
		protected function _displayLoadURL():void
		{
			try
			{
				if ((_loader != null) && (_loader.state != EventType.LOADING))
				{
					var icon:String = null;
					icon = _options.getValue('icon').string;
					_displayObject = _loader.displayObject(icon, '', _displaySize());
					if (_displayObject != null)
					{
						_addDisplayObject();
						_resize();
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._displayLoadURL ' + icon, e);
			}
		}
		protected function _displaySize():Size
		{
			return new Size(_iconWidth, _iconHeight);			
		}	
		
		protected function _displayLoaded(event:Event):void
		{
			try
			{
				event.target.removeEventListener(Event.COMPLETE, _displayLoaded);
				_displayLoadURL();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._displayLoaded', e);
			}
	
		}
		protected function _initialize():void
		{ 
			var iString:String = _data[MediaProperty.LABEL];
			__label_mc.visible = __label_back_mc.visible = Boolean(iString.length) && _options.getValue('textheight').boolean;
			if (__label_mc.visible) 
			{
				RunClass.FontUtility['formatField'](__label_mc, _options);
				__label_mc.text = iString;
			}
			__createMouse();
			
		}
		protected function _optionsChanged():void
		{ 
			_resize();
		}
		protected var __mouse_mc : Sprite; // background for whole clip 
		protected var _clip:IClip;
		protected var _mediaTag:XML;
		protected var _id:String;
		protected var _selected:Boolean;
		protected var _iconHeight:Number;
		protected var _iconWidth:Number;
		protected var _options:IOptions;
		protected var __mask_mc : Sprite;
		protected var __children_mc: Sprite;
		protected var __label_back_mc : Sprite;
		protected var __label_mc : TextField;
		protected var _container:IPreviewContainer;
		protected var _displayObject:DisplayObject;
		protected var _displayObjectContainer : Sprite;
		protected var _loader:IAssetFetcher;
		protected var _data:Object;
	}
}