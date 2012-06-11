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
	import com.moviemasher.constant.*;
	import com.moviemasher.display.*;
	import com.moviemasher.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.options.*;
	import com.moviemasher.type.*;
	import com.moviemasher.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;
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
			_labelSprite = new Sprite();
			__children_mc.addChild(_labelSprite);
			_labelField = new TextField();
			__children_mc.addChild(_labelField);
		}
		public static function animatePreviews(tf:Boolean):void
		{
			__animatePreviews = tf;
		}
		public function set animating(tf:Boolean):void
		{
			if (tf)
			{
				if (__animTimer == null)
				{
					__animTimer = new Timer(500);
					__animTimer.addEventListener(TimerEvent.TIMER, __animTimed, false, 0, true);
					__animTimer.start();
					__animTimed(null);
				}
			}
			else
			{
				if (__animTimer != null)
				{
					__animTimer.stop();
					__animTimer.removeEventListener(TimerEvent.TIMER, __animTimed);
					__animTimer = null;
				}
			}
		
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
			if (_clip == null) _clip = __clipFromXML(_mediaTag.copy());
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
					if (! w) w = _data['width'];
					var text_y : Number;
					
					text_width = w - (2 * border);
						
					_labelField.width = text_width;				
					_labelField.height = textheight;		
					
					var tf:TextFormat = _labelField.defaultTextFormat;
					tf.color = RunClass.DrawUtility['colorFromHex'](textcolor);
					_labelField.defaultTextFormat = tf;
					_labelField.text = _labelField.text;
					
					
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
					_labelField.x = _labelSprite.x = border;
					_labelSprite.y = text_y;
					_labelField.y = text_y + _options.getValue('textoffset').number;
					
					_labelSprite.graphics.clear();
					// RunClass.MovieMasher['msg'](this + '._resizeLabel w = ' + w + ' border = ' + border + ' dims = ' + text_width + 'x' + textheight);
					RunClass.DrawUtility['fill'](_labelSprite.graphics, text_width, textheight, RunClass.DrawUtility['colorFromHex'](textbackcolor), textbackalpha);			
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
				if (w)
				{
					_iconWidth = w - (2 * border);
				}
				if (h)
				{
					_iconHeight = h - (2 * border + label_height);
				}
				
				if (ratio)
				{
					if (! h) _iconHeight = _iconWidth / ratio;
					else if (! w) _iconWidth = _iconHeight / ratio;
					else
					{
						if (_iconHeight >= _iconWidth / ratio) _iconHeight = _iconWidth / ratio;
						else _iconWidth = _iconHeight / ratio;
					}
				}
				 
				
				//RunClass.MovieMasher['msg'](this + '._resize ' + w + 'x' + h + ' -> ' + _iconWidth + 'x' + _iconHeight + ' Ratio: ' + ratio);
				
				var icon_y:Number = _resizeLabel();
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
			animating = false;
			if (__mash != null) 
			{
				__mash.unload();
				__mash = null;
			}
			if (__mouse_mc != null)
			{
				if (contains(__mouse_mc)) removeChild(__mouse_mc);
			}
			if (__children_mc != null)
			{
				if (_displayObjectContainer != null)
				{
					if (_displayObject != null)
					{
						
						if (_displayObjectContainer.contains(_displayObject))
						{
							_displayObjectContainer.removeChild(_displayObject);
						}
						
						_displayObject = null;
					}
					if (__children_mc.contains(_displayObjectContainer)) __children_mc.removeChild(_displayObjectContainer);
					_displayObjectContainer = null;
				}
				if (_labelSprite != null)
				{
					__children_mc.removeChild(_labelSprite);
					_labelSprite = null;
				}
				if (_labelField != null)
				{
					__children_mc.removeChild(_labelField);
					_labelField = null;
				}
				if (contains(__children_mc)) removeChild(__children_mc);
				__children_mc.mask = null;
				__children_mc = null;
			}
			if (_loader != null)
			{
				_loader.releaseDisplay(_displayObject);
				_loader.removeEventListener(Event.COMPLETE, _displayLoaded);
				_loader = null;
			}
			if (__mask_mc != null)
			{
				if (contains(__mask_mc)) removeChild(__mask_mc);
				__mask_mc = null;
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
				if (_iconIsModule)
				{
					animating = _selected;
				}
			}
		}
		protected function _drawPreview() : Boolean 
		{
			var called_resize:Boolean = false;
			try
			{
				if (_displayObject == null)
				{
					var size:Size = _displaySize();
					if ((size.width > 0) && (size.height > 0))
					{
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
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return called_resize;
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
						_displayObjectContainer.blendMode = BlendMode[_options.getValue((_selected ? 'sel' : '') + 'blend').string.toUpperCase()];
						_iconIsModule = (_displayObject is IModule);
						if (_iconIsModule)
						{
							var display_size:Size = _displaySize();
							var mash_xml:XML = <mash />;
							mash_xml.@quantize = String(RunClass.TimeUtility['fps']);
							mash_xml.appendChild(_mediaTag);
							var clip_xml:XML = <clip />;
							var s:String;
							var a:Array;
							var img_media_xml:XML = null;
							var img_clip_xml:XML = null;
									
							s = String(_mediaTag.@type);
							clip_xml.@id = _mediaTag.@id;
							clip_xml.@composites = _mediaTag.@composites;
							clip_xml.@type = s;
							switch(s)
							{
								case ClipType.EFFECT:
									clip_xml.@track = 1;
									img_media_xml = <media />;
									img_clip_xml = <clip />;
									
									img_media_xml.@type = ClipType.IMAGE;
									img_clip_xml.@type = ClipType.IMAGE;
									s = options.getValue('preview').string;
									img_media_xml.@url = s;
									s = RunClass.MD5['hash'](s);
									img_media_xml.@id = s;
									img_clip_xml.@id = s;
									clip_xml.@length = 10;
									img_clip_xml.@length = clip_xml.@length;
									img_clip_xml.appendChild(clip_xml);
									clip_xml = img_clip_xml;
									mash_xml.appendChild(img_media_xml);
									
									break;
								case ClipType.TRANSITION:
									img_media_xml = <media />;
									img_clip_xml = <clip />;
									
									
									img_media_xml.@type = ClipType.IMAGE;
									img_clip_xml.@type = ClipType.IMAGE;
									s = options.getValue('preview').string;
									a = s.split(',');
									s = a[0];
									img_media_xml.@url = s;
									s = RunClass.MD5['hash'](s);
									img_media_xml.@id = s;
									img_clip_xml.@id = s;
									clip_xml.@length = 10;
									img_clip_xml.@length = clip_xml.@length;
									mash_xml.appendChild(img_clip_xml);
									mash_xml.appendChild(clip_xml);
									mash_xml.appendChild(img_media_xml);
									
									s = a[1];
									img_media_xml = img_media_xml.copy();
									img_clip_xml = img_clip_xml.copy();
									img_media_xml.@url = s;
									s = RunClass.MD5['hash'](s);
									img_media_xml.@id = s;
									img_clip_xml.@id = s;
									clip_xml.@length = 10;
									img_clip_xml.@length = clip_xml.@length;
									clip_xml = img_clip_xml;
									mash_xml.appendChild(img_media_xml);
									break;
							}
							mash_xml.appendChild(clip_xml);
							__mash = RunClass.Mash['fromXML'](mash_xml);
							//RunClass.MovieMasher['msg'](this + '._displayLoadURL ' + mash_xml.toXMLString());
							__mash.metrics = display_size;
							_displayObject = __mash.displayObject;
							__animFrame = PREVIEW_FRAMES / 2;
							__mashBuffer(null);
							
							_displayObject.x = display_size.width / 2;
							_displayObject.y = display_size.height / 2;
						
						}
						_displayObjectContainer.addChildAt(_displayObject, 0);

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
			_labelField.visible = _labelSprite.visible = Boolean(iString.length) && _options.getValue('textheight').boolean;
			if (_labelField.visible) 
			{
				RunClass.FontUtility['formatField'](_labelField, _options);
				_labelField.text = iString;
			}
			__createMouse();
			
		}
		protected function _optionsChanged():void
		{ 
			_resize();
		}
		private function __mashBuffer(event:Event):void
		{
			var mash_length:Number = __mash.getValue(ClipProperty.LENGTH).number;
			__mash.gotoFrame(mash_length * (__animFrame / PREVIEW_FRAMES));					
		}
		/*
		private function __animBuffered(event:Event):void
		{
			//RunClass.MovieMasher['msg'](this + '.__animBuffered removing listener');
			
			removeEventListener(EventType.BUFFER, __animBuffered);
			__animTimed(null);
		}
		*/
		private function __animTimed(event:TimerEvent):void
		{
			if ((event !=  null) && (! __animatePreviews)) return;
			var buffed:Boolean = false;	
			var now:Number;
			try
			{
				now = __mash.getValue(ClipProperty.LENGTHFRAME).number;
				now *= __animFrame / PREVIEW_FRAMES;
				buffed = __mash.buffered(now, now, true, false);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__animTimed was not able to check buffered state', e);
			}
			try
			{
				if (! buffed)
				{
					__mash.buffer(now, now, true, false);
					buffed =__mash.buffered(now, now, true, false);
					if ((! buffed) && (__animTimer == null))
					{
						//RunClass.MovieMasher['msg'](this + '.__animTimed addinglistener');
						//addEventListener(EventType.BUFFER, __animBuffered);
					}
				//	else if (! buffed) RunClass.MovieMasher['msg'](this + '.__animTimed not buffed but animTimer != null');
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__animTimed was not able to buffer', e);
			}
			try
			{
				if (buffed)
				{
					//RunClass.MovieMasher['msg'](this + '.__animTimed buffered, setting frame ' + now + ' display_size = ' + display_size);
					__mash.gotoFrame(now);
					__animFrame ++;
					if (__animFrame == PREVIEW_FRAMES) __animFrame = 0;		
				}
			
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__animTimed was not able to setFrame', e);
			}
		}
		private static const PREVIEW_FRAMES:Number = 10;
		private static var __animatePreviews:Boolean = true;
		private var __animFrame:Number;
		private var __animTimer:Timer;
		private var __mash:IMash;
		
		
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
		protected var _labelSprite : Sprite;
		protected var _labelField : TextField;
		protected var _container:IPreviewContainer;
		protected var _displayObject:DisplayObject;
		protected var _displayObjectContainer : Sprite;
		protected var _loader:IAssetFetcher;
		protected var _data:Object;
		protected var _iconIsModule:Boolean;
	}
}