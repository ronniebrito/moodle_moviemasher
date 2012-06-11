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
	import com.moviemasher.events.*;
	import com.moviemasher.source.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.options.*;
	import com.moviemasher.preview.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;

/**
* Implimentation class represents a media browsing control
*/

	public class Browser extends ControlPanel
	{
		public function Browser()
		{
			__sourceProxy = new SourceProxy();
			_defaultPreviewClass = BrowserPreview;
			_defaultOptionsClass = PreviewOptions;
		
			
			_defaults.previewwidth = '160';
			_defaults.previewheight = '';
			_defaults.id = 'browser';
			//_defaults.tie = 'player.mash';
			_defaults.source = '';
			
			
		
		}
		override public function resize():void
		{
			super.resize();
				try
			{
			
				if (! _width) return;
				if (! _previewHeight)
				{
					
					if (_mash != null) 
					{
						__calcPreviewHeight();
					}
					else _previewHeight = getValue('previewheight').number;
				}
				if (_previewHeight)
				{
					var previewwidth:Number = getValue('previewwidth').number;
					var spacing:Number = getValue(ControlProperty.SPACING).number;
					var padding:Number = getValue(ControlProperty.PADDING).number;
					
					var innerwidth:Number = (_width - (2 * padding));
					_columns = Math.floor(innerwidth / previewwidth);
					if (((_columns * previewwidth) + ((_columns - 1) * spacing)) > innerwidth) _columns --;
					
					try
					{
						if (! __vScrollReset())
						{
							_drawClips();
						}
					}
					catch(e:*)
					{
						RunClass.MovieMasher['msg'](this, e);
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		override public function dragAccept(drag:DragData):void
		{ 
			var pt:Point = _clickSprite.globalToLocal(drag.rootPoint);
			var info:Object = __dragInfo(pt);
			if (info.index == -1) info.index = _sourceLength;
			if (_source == null) _source = new Source();
			var items:Array = _source.items.concat();
			if (drag.source == this)
			{
				var pos:int = items.indexOf(drag.items[0]);
				if (pos == info.index) return;
				if (pos < info.index) info.index--;
				
				items.splice(pos, 1);
			}
			items.splice(info.index, 0, drag.items[0]);
			_source.items = items;
			dispatchPropertyChange();
		}
		override public function dragOver(drag:DragData):Boolean
		{
			var z:uint = drag.items.length;
			if (z != 1) return false;
			
			var ok:Boolean = (drag.source == this);
			var clip:IClip;
			if (! ok)
			{
			
				ok = (drag.items[0] is IClip);
				if (ok)
				{
					clip = (drag.items[0] as IClip);
					
				
					ok = Boolean(_tag.drop.(attribute(CommonWords.TYPE) == clip.getValue(CommonWords.TYPE).string).length());
					
					if (ok)
					{
						z = _source.items.length;
						for (var i:int = 0; i < z; i++)
						{
							if (_source.items[i].getValue(CommonWords.ID).string == drag.items[0].getValue(CommonWords.ID).string)
							{
								return false;
							}
						}
					}
				}
				
			}
			if (ok)
			{
				var pt:Point = _clickSprite.globalToLocal(drag.rootPoint);
				var info:Object = __dragInfo(pt);
				var previewwidth:Number = getValue('previewwidth').number;
				var autoscroll:Number = getValue('autoscroll').number;
				var spacing:Number = getValue(ControlProperty.SPACING).number;
				var padding:Number = getValue(ControlProperty.PADDING).number;
				if (pt.y < autoscroll)
				{
					__doScroll(-1, false);
				}
				else if (pt.y > (_height - autoscroll))
				{
					__doScroll(1, false);
				}
				if (info.index == -1)
				{
					_dragHilite.width = _width;
					_dragHilite.height = _height;
					_dragHilite.x = 0;
					_dragHilite.y = 0;				
				}
				else
				{
					_dragHilite.width = spacing;
					_dragHilite.height = _previewHeight;
					_dragHilite.x = padding + (info.column * (previewwidth + spacing) - spacing);
					_dragHilite.y = padding + (info.row * (_previewHeight + spacing)) - _scroll.y;
				}
				
			}
			
			return ok;
		}
		override protected function _createChildren():void
		{
			super._createChildren();
			if (_tag.drop.length())
			{
				RunClass.DragUtility['addTarget'](this);
				source = new Source();
			}
			_createTooltip();
		}
		override public function initialize():void
		{
			super.initialize();
			if (! _source)
			{
				var value:Value = getValue('source');
				if (! value.empty) setValue(value, 'source');
			}
		}
		override public function getValue(property:String):Value
		{
			var value:Value;
			switch (property)
			{
				case 'parameters':
					value = new Value(__sourceProxy);
					break;
				case 'selection':
					value = new Value(_selection);
					break;
				case _property:
					value = new Value(_source.items);
					break;
				default: value = super.getValue(property);
			}
			return value;
		}
		override public function setValue(value:Value, property:String):Boolean
		{		
			try
			{
				var dispatch:Boolean = true;
				
				switch(property)
				{
					case 'refresh':
						__sourceChange(null);
						break;
					case ClipType.MASH:
						mash = value.object as IMash;
						break;
					case 'source':
						
						source = null;
						source = RunClass.MovieMasher['source'](value.string);
						super.setValue(value, property);
						
						break;
					default: 
						if (_property == property)
						{
							dispatch = false;
							_source.items = (value.indeterminate ? new Array() : value.array);
						}
						else 
						{
							super.setValue(value, property);
						}
				}
				if (dispatch)
				{
					dispatchEvent(new ChangeEvent(value, property));
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return false;
		}
		override public function updateTooltip(tooltip:ITooltip):Boolean
		{
			var dont_delete:Boolean = false;
			var tip:String;
			try
			{
				tip = getValue('tooltip').string;
				dont_delete = Boolean(tip.length);
				if (dont_delete && (tip.indexOf('{') != -1))
				{
					var pt:Point = globalToLocal(tooltip.point);
					var info:Object = __dragInfo(pt);
					if (info.off) tip = '';
					else
					{
						var xmlOrClip:* = _source.getItemAt(info.index);
						if (xmlOrClip == null) tip = '';
						else tip = RunClass.ParseUtility['brackets'](tip, xmlOrClip);
					}
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
		public function get source():ISource
		{
			return _source;
		}
		public function set source(iSource:ISource):void
		{
			if (_source != iSource)
			{
				if (_source != null)
				{
					_source.removeEventListener(Event.CHANGE, __sourceChange);
					_deleteClips();
					_visibleClips = new Dictionary();
					
				}
				_source = iSource;
				__sourceProxy.source = null;
				__sourceProxy.setValue(new Value(''), 'terms');
				__sourceProxy.source = _source;
				
				if (_source != null)
				{
					_source.addEventListener(Event.CHANGE, __sourceChange);
					__sourceChange(null);
				}
				
				
				
			}
			
		}
		protected function set mash(iMash:IMash):void
		{
			_mash = iMash;
			resize();
		}
		private function __createPreview(media_tag:XML):IPreview
		{			
			var preview:IPreview = null;
			try
			{
				var media_type:String = String(media_tag.@type);
				var media_id:String = String(media_tag.@id);
				var media_icon:String = String(media_tag.@icon);
				var media_label:String = String(media_tag.@label);
				
				if (media_type.length && media_id.length)
				{
					var options:IOptions = _itemOptions(media_type);
					
					// TODO: remove these
					options.setValue(new Value(media_id), CommonWords.ID);
					
					
					if (media_icon.length)
					{
						options.setValue(new Value(media_icon), 'icon');
					}
					
					if (! media_label.length)
					{
						media_label = media_id;
					}
					options.setValue(new Value(media_label), 'label');
					preview = _instanceFromOptions(options, media_tag);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}

			return preview;
			
		}
		override protected function _drawClips(force:Boolean = false):void
		{
			try
			{
									
				var new_clips:Dictionary = new Dictionary();
				if ((_source != null) && (_columns > 0))
				{
					var padding:Number = getValue(ControlProperty.PADDING).number;
					var border:Number = getValue('border').number;
					var spacing:Number = getValue(ControlProperty.SPACING).number;
					var x_pos:Number = padding;
					var y_pos:Number = padding - _scroll.y;
					var previewwidth:Number = getValue('previewwidth').number;
					
					var index:Number = 0;
					var rowvisible:Boolean;
					var rows:Number = Math.ceil(_sourceLength / _columns);
					var first_item:Number;
					var ipreview:IPreview;
					var result:*;
					var key:*;
					
						for (var row:Number = 0; row < rows; row++)
						{
							rowvisible = ( ! ( ((y_pos + _previewHeight) < 0) || (y_pos > _height) ) );
							if (rowvisible) 
							{
								for (var i:Number = 0; (i < _columns) && (index < _sourceLength); i++)
								{
									result = _source.getItemAt(index);
									
									if (result != null)
									{
										key = ((result is XML) ? result.toXMLString() : result);
										
										ipreview = _visibleClips[key];
										if (ipreview == null)
										{
											ipreview = ((result is XML) ? __drawMedia(result) : __drawClip(result));
										}
										
											
										delete _visibleClips[key];
										
										new_clips[key] = ipreview;
										ipreview.displayObject.x = x_pos;
										ipreview.displayObject.y = y_pos;
										x_pos += previewwidth + spacing;
										index++;
									}
								}
							}
							else
							{
								index += _columns;
							}
							y_pos += _previewHeight + spacing;
							x_pos = padding;
						}
				}
				_deleteClips();
				_visibleClips = new_clips;
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._drawClips', e);
			}
		}
		override protected function _itemOptions(type:String):IOptions
		{
			var options:IOptions = super._itemOptions(type);
			options.setValue(getValue('previewwidth'), 'width');
			options.setValue(getValue('previewheight'), 'height');
			return options;
		}
		override public function downPreview(preview:IPreview, event:MouseEvent):void
		{
			try
			{
				if (getValue('nodrag').boolean) return;
							
				var media_tag:XML;
				var is_clip:Boolean;
				var media_item:*;
				var clip:IClip;
				for (var t:* in _visibleClips)
				{
					if (_visibleClips[t] == preview)
					{
						is_clip = (t is IClip);
						if (is_clip)
						{
							clip = (t as IClip);
							media_item = clip.media;
							media_tag = media_item.tag;
						}
						else media_tag = new XML(t);
						break;
					}
				}
			
					
				if (media_tag != null)
				{
					var id:String = String(media_tag.@id);
					if (id.length)
					{
						if (clip == null)
						{
							media_item = RunClass.Media['fromXML'](media_tag);
							if (media_item != null)
							{
								clip = RunClass.Clip['fromMedia'](media_item, null, _mash);
								// unset mash (we set above so composited items might be found)
								clip.setValue(new Value(), ClipProperty.MASH);
							}
						}
						if (clip != null)
						{
							var drag_data:DragData = new DragData();
							drag_data.items.push(clip);
							drag_data.clickPoint = new Point(event.localX, event.localY);
							drag_data.source = this;
							drag_data.callback = __finishedDrag;
							drag_data.previewCallback = __dragPreview;
							drag_data.local = Boolean(_tag.drop.length());
							RunClass.DragUtility['begin'](event, drag_data);
						
							_changeCursor('drag');
							
							if (! is_clip) 
							{
								_selection.items = [media_item];
							
								_updateSelection();
							}
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __dragPreview(drag_data:Object):DisplayObjectContainer
		{
			var sprite:Sprite = new Sprite();
			try
			{
				var iclip:IClip = drag_data.items[0];
				sprite.alpha = .7;				
				var ipreview:IPreview = __createPreview(iclip.media.tag);
				ipreview.selected = true;
				sprite.addChild(ipreview.displayObject);
				ipreview.displayObject.x = - drag_data.clickPoint.x;
				ipreview.displayObject.y = - drag_data.clickPoint.y;
				_changeCursor('drag');
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return sprite;
		}		
		private function __finishedDrag(drag:DragData):void
		{
			_removePreviews(drag.display);
			
			if (_tag.drop.length())
			{
				if (drag.dragged)
				{
					
					var pt:Point = _clickSprite.globalToLocal(drag.rootPoint);
					var rect:Rectangle = new Rectangle(0,0,_width, _height);
					if (! rect.containsPoint(pt))
					{
						var existing:Array = _source.items;
						var new_items:Array = new Array();
						var z:uint = existing.length;
						var removing_items:Array = drag.items;
						for (var i:uint = 0; i < z; i++)
						{
							if (removing_items.indexOf(existing[i]) == -1)
							{
								new_items.push(existing[i]);
							}
						}
						_source.items = new_items;
						dispatchPropertyChange();
					}
				}
				else
				{
					var id:String = super.getValue('selection').string;
					if (id.length)
					{
						var ob:Object = RunClass.MovieMasher['getByID'](id);
						ob.items = drag.items;
					}
				}
			}
		}
		private function __drawMedia(xml:XML):IPreview
		{
			var ipreview:IPreview;
			try
			{
				
				var xml_str:String = xml.toXMLString();
										
				if (_visibleClips[xml_str] == null)
				{
					ipreview = __createPreview(xml);
					if (ipreview != null) 
					{
						_clipsSprite.addChild(ipreview.displayObject);
					}
				}
				else 
				{
					ipreview = _visibleClips[xml_str];
					delete _visibleClips[xml_str];
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			
			return ipreview;
		}
		private function __drawClip(clip:IClip):IPreview
		{
			var ipreview:IPreview;
			try
			{
				if (_visibleClips[clip] == null)
				{
					ipreview = __createPreview(clip.media.tag);
					if (ipreview != null) 
					{
						_clipsSprite.addChild(ipreview.displayObject);
					}
				}
				else 
				{
					ipreview = _visibleClips[clip];
					delete _visibleClips[clip];
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return ipreview;
		}
		protected function __vScrollReset():Boolean
		{
			var tf:Boolean;
			try
			{
				if (_columns > 0)
				{
					var spacing:Number = getValue(ControlProperty.SPACING).number;
					var padding:Number = getValue(ControlProperty.PADDING).number;
					
					var rows:Number = Math.ceil(_sourceLength / _columns);
					var contentheight:Number = padding * 2;
					
					contentheight += (rows * _previewHeight) + ((rows - 1) * spacing);
					tf = _setScrollDimension('height', contentheight);		
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return tf;
		}
		private function __calcPreviewHeight():void
		{
			try
			{
				var options:IOptions = _itemOptions(ClipType.VIDEO);
				_previewHeight = options.metrics.height;
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __dragInfo(pt:Point):Object
		{
			var ob:Object = new Object();
			ob.index = -1;
			
			if (_sourceLength)
			{
				var spacing:Number = getValue(ControlProperty.SPACING).number;
				var padding:Number = getValue(ControlProperty.PADDING).number;
				ob.column = Math.floor((pt.x - padding )/(getValue('previewwidth').number + spacing));
				ob.row = Math.floor(((pt.y + _scroll.y) - padding)/(_previewHeight + spacing));
				ob.off = (ob.column >= _columns);
				if (ob.off)
				{
					
					ob.column = 0;
					ob.row++;
				}
				ob.index = (ob.row * _columns) + ob.column;
				if (ob.index >= _sourceLength)
				{
					ob.index = -1;
				}
			}
			return ob;
		}
		private function __sourceChange(event:Event):void
		{
			try
			{
				_selection.removeItems();
				
				_sourceLength = _source.getValue('length').number;
				if (! __vScrollReset())
				{
					_drawClips();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		protected var _columns:Number;
		protected var _previewHeight:Number = 0;
		protected var _source:ISource;
		protected var _sourceLength:uint = 0;
		private var __sourceProxy:SourceProxy;
	}
	
}
