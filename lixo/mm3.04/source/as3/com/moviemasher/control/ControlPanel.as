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
	import com.moviemasher.core.*;
	import com.moviemasher.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.utils.*;
	import com.moviemasher.options.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
/** Abstract base class represents control containing a view
* 
* @see Browser
* @see Timeline
*/
	public class ControlPanel extends Control implements IDrop, IPreviewContainer
	{
		public function ControlPanel()
		{
			_defaults.deselectable = '1';
			_defaults.hialpha = '50';
			_defaults.hscrollunit = '10';
			_defaults.vscrollunit = '10';
			_defaults.autoscroll = '20';
			_defaults.hscrollpadding = '0';
			
			_defaults.hisize = '4';
			_viewSize = new Size();
			__cursors = new Object();
			
			_visibleClips = new Dictionary();
			_scroll = new Rectangle(-1, -1, -1, -1);
			
			_selection = new Selection();
			_selection.addEventListener(Event.CHANGE, _selectionDidChange);
			_allowFlexibility = true;
			
		}
		override public function initialize():void
		{
			super.initialize();
			_configCursor('hover');
			_configCursor('drag');
			var preview_tags:XMLList = _tag.preview;
			var preview_tag:XML;
			var url:String;
			var urls:Array = new Array();
			var loader:IAssetFetcher;
			var url_split:Array;
			for each (preview_tag in preview_tags)
			{
				url = preview_tag.@symbol;
				if (url.length) urls.push(url);
				url = preview_tag.@preview;
				if (url.length)
				{
					url_split = url.split(',');
				
					if (url_split.length > 0) urls.push(url_split[0]);
					if (url_split.length > 1) urls.push(url_split[1]);
				}
			}
			for each (url in urls)
			{
				loader = RunClass.MovieMasher['assetFetcher'](url);
			}
		}
		public function downPreview(preview:IPreview, event:MouseEvent):void
		{
		
		}
		public function outPreview(preview:IPreview, event:MouseEvent):void
		{
			_changeCursor();
			__hoverPreview = null;
			_updateSelection();
		}
		public function overPreview(preview:IPreview, event:MouseEvent):void
		{
			_changeCursor('hover');
			__hoverPreview = preview;
			_updateSelection();
		}
/*
		override public function changeEvent(event:ChangeEvent):void
		{
			try
			{
				setValue(event.value, event.property);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.changeEvent ' + event.property, e);
			}
		}
		*/
		override public function resize():void
		{
			try
			{
			
				if (_width && _height)
				{
					_viewSize = new Size(_width, _height);
					//super.resize();
					
					var offset:Number = getValue('iconwidth').number;
					_clickSprite.graphics.clear();
					RunClass.DrawUtility['fillBox'](_clickSprite.graphics, offset, 0, _width - offset, _height, 0, 0);
		
					__maskSprite.graphics.clear();
					RunClass.DrawUtility['fillBox'](__maskSprite.graphics,offset, 0, _width - offset, _height, 0, 0);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.ControlPanel.resize ' + _clickSprite + ' ' + __maskSprite, e);
			}
		}
		override public function getValue(property:String):Value
		{
			var n:Number = NaN;
			switch (property)
			{
				case 'viewwidth':
					n = _width;
					break;
				case 'viewheight':
					n = _height;
					break;
				case 'itemwidth':
					n = (_scroll.width - (_scroll.x + getValue('hscrollpadding').number));
					break;
				case 'itemheight':
					n = (_scroll.height - (_scroll.y + getValue('vscrollpadding').number));
					break;
				case 'xscroll':
					n = _scroll.x;
					break;
				case 'yscroll' :
					n = _scroll.y;
					break;
				case 'vscroll' :
					if (_viewSize.height && (_viewSize.height < _scroll.height))
					{
						n = (_scroll.y * 100) / (_scroll.height - _viewSize.height);
					}
					break;
				case 'hscroll' :
					if (_viewSize.width && (_viewSize.width < _scroll.width))
					{
						n = (_scroll.x  * 100) / (_scroll.width - _viewSize.width);
					}
					else 
					{
						n = 0;
					}
					break;
				case 'vscrollsize' :
					if (_viewSize.height && (_viewSize.height < _scroll.height))
					{
						n = (_viewSize.height * 100) / _scroll.height;
					}
					else 
					{
						n = 0;
					}
					break;
				case 'hscrollsize' :
					if (_viewSize.width && (_viewSize.width < _scroll.width))
					{
						n = (_viewSize.width * 100) / _scroll.width;
					}
					else 
					{
						n = 0;
					}
					break;
				
			}
			var value:Value = (isNaN(n) ? super.getValue(property) : new Value(n));
			
			return value;
		}
		override public function setValue(value:Value, property:String):Boolean
		{
			try
			{
				switch (property)
				{
					case 'vscrollunit' :
					case 'hscrollunit' :
						__doScroll(value.number, (property.substr(0, 1) == 'h'));
						break;
					case 'vscroll' :
					case 'hscroll' :
						var xORy:String = ((property == 'hscroll') ? 'x' : 'y');
						var wORh:String = ((property == 'hscroll') ? 'width' : 'height');
						
						
						_setScrollPosition(xORy, Math.round((value.number * (_scroll[wORh] - _viewSize[wORh])) / 100));
						break;
					default:
						super.setValue(value, property);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.setValue ' + property + ' ' + value.string, e);
			}
			
			return false;
		
		}
		public function dragAccept(drag:DragData):void
		{ }
		public function dragHilite(tf:Boolean):void
		{ 
			_dragHilite.visible = tf;
			
		}
		public function dragOver(drag:DragData):Boolean
		{return true;}
		public function overPoint(root_pt:Point):Boolean
		{
			var over_point:Boolean = false;
			if (! _hidden)
			{
				var pt:Point = globalToLocal(root_pt);
							
				if ((pt.x >0) && (pt.y > 0) && (pt.x < _width) && (pt.y < _height))
				{
					over_point = true;
				}
			}
			return over_point;
		}
		public function doPress(event:MouseEvent):void
		{
			try
			{
				if (getValue('deselectable').boolean)
				{
					_selection.removeItems();
					_drawClips();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}

		}
		final protected function _changeCursor(type:String = ''):void
		{
			if (type.length)
			{
				var cursor_config:CursorConfig = __cursors[type];
				if ((cursor_config != null) && (cursor_config.displayObject != null))
				{
					RunClass.MovieMasher['setCursor'](cursor_config.displayObject, cursor_config);
				}
			}
			else
			{
				RunClass.MovieMasher['setCursor']();
			}
		}
		final protected function _configCursor(cursor_name : String)
		{
			var cursor:String = getValue(cursor_name + 'icon').string;
			if (cursor.length)
			{
				var c:Array = cursor.split(';');
				var s:String = c[0];
				var n:Number;
				if (s.length)
				{
					var loader:IAssetFetcher = RunClass.MovieMasher['assetFetcher'](s);
					
					var display:DisplayObject = loader.displayObject(s);
					if (display != null)
					{
						var cursor_config:CursorConfig = new CursorConfig(display);
						if (c.length > 1)
						{
							s = c[1];
							n = Number(s);
							if (! isNaN(n))
							{
								cursor_config.x = n;
							}
						}
						if (c.length > 2)
						{
							s = c[2];
							n = Number(s);
							if (! isNaN(n))
							{
								cursor_config.y = n;
							}
						}
						__cursors[cursor_name] = cursor_config;
					}
					
				}
			}
		}
		override protected function _createChildren():void
		{
			// BACK (for deselection)
			_clickSprite = new Sprite();
			addChild(_clickSprite);
			_clickSprite.addEventListener(MouseEvent.MOUSE_DOWN, doPress);


			_clickSprite.useHandCursor = false;

			// CLIPS CONTAINER

			__itemsSprite = new Sprite();
			addChild(__itemsSprite);


			_clipsSprite = new Sprite();
			__itemsSprite.addChild(_clipsSprite);


			_dragHilite =  new Sprite();
			_clipsSprite.addChild(_dragHilite);
			
			RunClass.DrawUtility['fill'](_dragHilite.graphics, 1, 1, RunClass.DrawUtility['colorFromHex'](getValue('hicolor').string), getValue('hialpha').number);

			_dragHilite.visible = false;
			


			__maskSprite = new Sprite();
			
			__itemsSprite.addChild(__maskSprite);


			_clipsSprite.mask = __maskSprite;
			
			
			var list:XMLList;
			var tag:XML = null;
			var font_tag:XML = null;
			var url:String;
			list = _tag.preview;
			if (list.length())
			{
				for each (tag in list)
				{
					url = String(tag.@font);
					if (url.length)
					{
						font_tag = RunClass.MovieMasher['fontTag'](url);
						if (font_tag != null)
						{
							_displayObjectLoad(font_tag.@url, true);
						}
					}
					url = String(tag.@symbol);
					if (url.length)
					{
						_displayObjectLoad(url, true);
					}
				}
			}
		}		
		protected function _drawClips(force : Boolean = false):void
		{}
		protected function _previewData(clip:IClip):Object
		{
			var object:Object = new Object();
			if (clip != null) 
			{
				object[MediaProperty.LABEL] = clip.getValue(MediaProperty.LABEL).string;
			}
			return object;
		}
		protected function _instanceFromOptions(options:IOptions, xml:XML, clip:IClip = null):IPreview
		{
			var ipreview:IPreview = null;
			try
			{
				var preview_class:Class = null;
				var object:Object = _previewData(clip);
				if (object[MediaProperty.LABEL] == null)
				{
					object[MediaProperty.LABEL] = xml.@[MediaProperty.LABEL];
				}
				var symbol:String = options.getValue('symbol').string;
				if (symbol.length)
				{
					var loader:IAssetFetcher = RunClass.MovieMasher['assetFetcher'](symbol, 'swf');
					preview_class = loader.classObject(symbol, 'preview');
				}
				if (preview_class == null)
				{
					preview_class = _defaultPreviewClass;
				}
				ipreview = new preview_class();
				
				ipreview.mediaTag = xml;
				ipreview.container = this;
				
				if (clip != null) ipreview.clip = clip;
				
				ipreview.options = options;
				ipreview.data = object; // this should always be called last
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._instanceFromOptions ' + ipreview, e);
			}
			return ipreview;
			
		}
		final protected function _setScrollDimension(wORh:String, pixels:Number):Boolean
		{
			var did_draw:Boolean = false;
				
			if (_resizing || (_scroll[wORh] != pixels))
			{
				_scroll[wORh] = pixels;
				var hORv:String = ((wORh == 'width') ? 'h' : 'v');
				var xORy:String = ((wORh == 'width') ? 'x' : 'y');
				
				dispatchEvent(new ChangeEvent(getValue(hORv + 'scrollsize'), hORv + 'scrollsize'));
				var scroll:Number = 0;
				if (pixels > _viewSize[wORh])
				{
					scroll = _scroll[xORy];
					scroll = Math.min(pixels - _viewSize[wORh], scroll);
					scroll = Math.max(0, scroll);
				}
				
				did_draw = _setScrollPosition(xORy, scroll, true);
				if (! did_draw)
				{
					_drawClips();
					did_draw = true;
				}
			}
			return did_draw;
		}
		final protected function _setScrollPosition(xORy:String, pixels:Number, redraw:Boolean = false):Boolean
		{
			var did_draw:Boolean = false;
			if (redraw || (_scroll[xORy] != pixels))
			{
				_scroll[xORy] = pixels;
				var hORv:String = ((xORy == 'x') ? 'h' : 'v');
				dispatchEvent(new ChangeEvent(getValue(hORv + 'scroll'), hORv + 'scroll'));
				_drawClips(true);
				did_draw = true;
				_updateSelection();
			}
			return did_draw;
		}
		protected function __doScroll(dir:Number, horizontal:Boolean):Number
		{
		
			var did_scroll:Number = 0;
			try
			{
			var wORh = (horizontal ? 'width' : 'height');
			var xORy = (horizontal ? 'x' : 'y');
			if (_scroll[wORh])
			{
				var cur_pos = _scroll[xORy];
				var new_pos = cur_pos + (dir * getValue((horizontal?'h':'v') + 'scrollunit').number);
				if (new_pos > (_scroll[wORh] - _viewSize[wORh]))
				{
					new_pos = _scroll[wORh] - _viewSize[wORh];
				}
				else if (new_pos < 0)
				{
					new_pos = 0;
				}
				if (new_pos != cur_pos)
				{
					did_scroll = _scrollTo(horizontal,new_pos);
				}
			}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return did_scroll;
		}
		protected function _scrollTo(horizontal : Boolean, position : Number):Number
		{
			var scrolled = 0;
			var xORy:String = (horizontal ? 'x' : 'y');
			if (! isNaN(position))
			{
				position = Math.max(0, position);
				scrolled = position - _scroll[xORy];
				_setScrollPosition(xORy, position);
			}
			return scrolled;
		}
		protected function _isSelected(preview:IPreview):Boolean
		{
			if (__hoverPreview != null) return (preview == __hoverPreview);
			return (_selection.indexOfKey(preview.options.getValue(CommonWords.ID)) != -1);
		}
		protected function _updateSelection():void
		{
			try
			{
				for (var k:* in _visibleClips)
				{
					if (_visibleClips[k])
					{
						_visibleClips[k].selected = _isSelected(_visibleClips[k]);
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		
		}
		protected function _itemOptions(type:String):IOptions
		{
			var options:IOptions = new _defaultOptionsClass();
			var list:XMLList = _tag.preview;
			var previews:XMLList;
			var option_xml:XML;
			var z:int;
			if (list.length())
			{
				previews = list.(@type == '*');
				if (previews.length())
				{
					options.tag = previews[0].copy();
				}
				previews = list.(@type == type);
				
				if (previews.length())
				{
					options.tag = previews[0].copy();
				}
			}
			options.setValue(new Value(type), CommonWords.TYPE);
			
			if (_mash != null)
			{
				options.setValue(_mash.getValue('ratio'), 'ratio');
			}
			return options;
		}
		/*protected function _configurePreview(preview:IPreview):void
		{
			var type:String = preview.getValue(CommonWords.TYPE).string;
			var list:XMLList = _tag.preview;
			var previews:XMLList;
			var option_xml:XML;
			var z:int;
			if (list.length())
			{
				previews = list.(@type == '*');
				if (previews.length())
				{
					preview.tag = previews[0].copy();
				}
				previews = list.(@type == type);
				
				if (previews.length())
				{
					preview.tag = previews[0].copy();
				}
			}
			if (_mash != null)
			{
				preview.setValue(_mash.getValue('ratio'), 'ratio');
			}
		}
		*/
		protected function _deleteClips():void
		{
			try
			{
				for (var k:* in _visibleClips)
				{
					if (_visibleClips[k] != null)
					{
						_visibleClips[k].unload();
						if (_visibleClips[k].parent != null)
						{
							_visibleClips[k].parent.removeChild(_visibleClips[k]);
						}
					}
				}
				_visibleClips = new Dictionary();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}

		}
		protected function _removePreviews(container:DisplayObjectContainer):void
		{
			if (container != null)
			{
				// called by subclasses from __finishedDrag to remove dragged previews
				var z:int = container.numChildren;
				var preview:IPreview;
				var child:DisplayObject;
				for (var i:int = z - 1; i > -1; i--)
				{
					child = container.getChildAt(i);
					if (child is IPreview) 
					{
						preview = (child as IPreview);
						container.removeChildAt(i);
						preview.unload();
					}
				}
			}
		}
		protected function _selectionDidChange(event:Event):void
		{
			_updateSelection();
		}
		protected var _clickSprite : Sprite;
		protected var _clipsSprite : Sprite;
		protected var _defaultOptionsClass:Class;
		protected var _defaultPreviewClass:Class;
		protected var _dragHilite : Sprite;// drag insert line
		protected var _mash:IMash;
		protected var _scroll:Rectangle;
		protected var _selection:Selection;
		protected var _viewSize : Size;
		protected var _visibleClips : Dictionary;
		private var __itemsSprite : Sprite;
		private var __cursors : Object;
		private var __maskSprite : Sprite;
		private var __hoverPreview:IPreview;
	}
	
}


