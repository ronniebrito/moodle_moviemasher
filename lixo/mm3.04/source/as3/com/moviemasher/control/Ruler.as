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
	import flash.display.*;
	import flash.events.*
	import flash.geom.*
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.events.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
/**
* Implimentation class represents a time-based scrubber control
*/
	public class Ruler extends Slider
	{
		public function Ruler()
		{
			__incrementers = new Array();
			_defaults.bind = 'player.location';
			_defaults.font = 'default';
			_defaults.textsize = '9';
			_defaults.textalign = 'center';
			_defaults.pattern = '{time}';
			
			_defaults.tie = 'moviemasher.timeline,timeline.hscroll,timeline.zoom,player.length';
			_centerIcon = true;
			_allowFlexibility = true;
		}
		override protected function _createChildren():void
		{
			super._createChildren();
			_displayObjectLoad('ruleicon');
			_displayObjectLoad('ruleovericon');
			if (! getValue('incrementsymbol').empty)
			{
				_displayObjectLoad('incrementsymbol');
				_displayObjectLoad(ModuleProperty.FONT);
			}
			__iconContainer = new Sprite();
			__iconContainer.mouseChildren = false;
			parent.addChildAt(__iconContainer, 0);
		}
		override public function setValue(value:Value, property:String):Boolean
		{
					
			switch(property)
			{
				case ReservedID.TIMELINE:
					__timeline = value.object as Timeline;
					break;
				case 'length':
				case 'zoom':
				case 'hscroll':
					if (_height) 
					{
						__layoutIncrementers();
					}
					value = new Value(__location);
					property = PlayerProperty.LOCATION;
					// intentional fallthrough to PlayerProperty.LOCATION
				case PlayerProperty.LOCATION:
					__location = value.number;
					// intentional fallthrough to default
				default:
					super.setValue(value, property);
			}
			
			return false;
			
		}
		override public function resize():void
		{
			super.resize();
			setValue(new Value(__location), PlayerProperty.LOCATION);
			if (_width && _height && (__timeline != null))
			{
				var rect:Rectangle;
				var pt:Point = new Point(0, y);
				pt = localToGlobal(pt);
				
				var h : Number = pt.y;
				
				pt = new Point(0, __timeline.height + __timeline.y);
				pt = __timeline.localToGlobal(pt);
				
				//RunClass.MovieMasher['msg('h = ' + (pt.y - h) + ' '](' + pt.y + ' - ' + h + ')');
				h = pt.y - h;
				
				if (h < 0)
				{
					_width = 0;
					_height = 0;
				//	dispatchEvent(new InvalidateEvent());
				}
				else
				{
					var mc:DisplayObject;
					var size:Size = new Size(Infinity, h);
					if (h < 2880)
					{
					
						try
						{
							_displayObjectSize('ruleicon', size, __iconContainer);
							_displayObjectSize('ruleovericon', size, __iconContainer);
							
							
							__syncRuler();
							__layoutIncrementers();
						}
						catch(e:*)
						{
							RunClass.MovieMasher['msg'](this, e);
						}
					}
				}
			}
		}
		override protected function _backSize():Size
		{
			return new Size(Infinity, _height);
		}
		override protected function _percent2Value(percent : Number):Number
		{
			if (__timeline == null)
			{
				return NaN;
			}
			var value:Number = ((_width * percent) / 100);
			value += __timeline.getValue('xscroll').number;
			value = __timeline.pixels2Time(value);
			return value;
		}
		override protected function _mouseOver(event:MouseEvent):void
		{
			try
			{
				super._mouseOver(event);
				__syncRuler();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}

		}
		override protected function _mouseOut():void
		{
			try
			{
				super._mouseOut();
				__syncRuler();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}

		}
		override protected function __setSlide(percent : Number, mc : DisplayObject= null, over_mc : DisplayObject = null):void
		{
			
			var per:Number = _value2Percent(_percent2Value(percent));
		//	RunClass.MovieMasher['msg'](this + '.__setSlide ' + percent + ' -> ' + per);
					
			super.__setSlide(per, mc, over_mc);
			__syncRuler();
		}
		override protected function _update():void
		{
			super._update();
			__syncRuler();
		}
		override protected function _value2Percent(location : Number):Number
		{
			if (__timeline == null)
			{
				return 0;
			}
			var percent:Number = __timeline.time2Pixels(location);
			percent -= __timeline.getValue('xscroll').number;
			percent = (percent / _width) * 100;
		//	RunClass.MovieMasher['msg']('_value2Percent ' + location + ' -> ' + percent);
			return percent;
		}
		private function __calculateIncrementWidth():void
		{
			var url:String = getValue('incrementsymbol').string;
			if (url.length)
			{
				var loader:IAssetFetcher = RunClass.MovieMasher['assetFetcher'](url, 'swf');
				__incrementClass = loader.classObject(url, 'display');
				if (__incrementClass != null)
				{
					var object:Object = new __incrementClass();
					var increment:IIncrement = object as IIncrement;
					if (increment != null)
					{
						increment.metrics = new Size(Infinity, _height);
						__incrementWidth = increment.metrics.width;
					}
					if (! __incrementWidth)
					{
						__incrementClass = null;
					}
				
				}
			}
			else
			{
				__incrementWidth = -1;
			}
		}
		private function __layoutIncrementers():void
		{
			if (! __incrementWidth)
			{
				__calculateIncrementWidth();
			}
			if (__incrementClass != null)
			{
				var interval:Number = getValue('increment').number;
				var xscroll:Number = __timeline.getValue('xscroll').number;
				var start_time:Number = __timeline.pixels2Time(xscroll);
				var end_time:Number = start_time + __timeline.pixels2Time(_width);
				
				
				
				
				var interval_width:Number =  __timeline.time2Pixels(interval);
				var i:int;
				i = Math.max(1, Math.ceil(__incrementWidth / interval_width));
				interval *= i;
				interval_width = __timeline.time2Pixels(interval);
				
				start_time += interval - (start_time % interval);
				i = 0;
				var increment:IIncrement;
				
				var index:int = numChildren;
				if (_displayedObjects.reveal != null) index = getChildIndex(_displayedObjects.reveal) + 1;
				else if (_displayedObjects.back != null) index = getChildIndex(_displayedObjects.back) + 1;
				
				for (;start_time < end_time; start_time += interval)
				{
					if (i == __incrementers.length)
					{
						increment = new __incrementClass() as IIncrement;
						if (increment != null)
						{
							increment.metrics = new Size(Infinity, _height);
							increment.font = getValue(ModuleProperty.FONT).string;
							increment.color = getValue('textcolor').string;
							increment.size = getValue('textsize').number;
							increment.textalign = getValue('textalign').string;
							increment.pattern = getValue('pattern').string;
							increment.textoffset = getValue('textoffset').number;
							addChildAt(increment.displayObject, index);
							__incrementers.push(increment);
						}
						
					}
					else 
					{
						increment = __incrementers[i];
						setChildIndex(increment.displayObject, index);
					}
					increment.time = start_time;
					increment.displayObject.x =  __timeline.time2Pixels(start_time) - xscroll;
					i++;
				}
				var target_length:int = i;
				for (;i < __incrementers.length; i++)
				{
					increment = __incrementers[i];
					
					removeChild(increment.displayObject);
				}
				__incrementers.length = target_length;
			
			}
		}
		private function __syncRuler()
		{

			var ruleicon_mc:DisplayObject = _displayedObjects.ruleicon;
			var ruleovericon_mc:DisplayObject = _displayedObjects.ruleovericon;
			var icon_mc:DisplayObject = _displayedObjects.icon;
			var overicon_mc:DisplayObject = _displayedObjects.overicon;

			if (ruleicon_mc != null)
			{
				ruleicon_mc.visible = icon_mc.visible;
				if (ruleicon_mc.visible)
				{
					ruleicon_mc.x = icon_mc.x + Math.ceil((icon_mc.width - ruleicon_mc.width) / 2);
				}
			}
			if (ruleovericon_mc != null)
			{
				ruleovericon_mc.visible = overicon_mc.visible;
				ruleovericon_mc.x = overicon_mc.x + Math.ceil((overicon_mc.width - ruleovericon_mc.width) / 2);
			}
		}
		private var __iconContainer:DisplayObjectContainer;
		private var __timeline:Timeline;
		private var __incrementClass:Class;
		private var __incrementWidth:Number = 0;
		private var __incrementers:Array;
		private var __location:Number = 0;
	}
}