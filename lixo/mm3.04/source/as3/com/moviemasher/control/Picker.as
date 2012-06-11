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
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.events.*;
/**
* Implimentation class represents a color picker control
*/
	public class Picker extends ControlIcon
	{
		public function Picker()
		{
			_defaults.value = '000000';
			_allowFlexibility = true;
	
		}
		override protected function _createChildren():void
		{	
			_displayObjectLoad('back');
			
			__chip_mc = new Sprite();
			addChild(__chip_mc);
			__bm_bevel_mc = new Sprite();
			addChild(__bm_bevel_mc);
			_createTooltip();
		}
		override public function getValue(property:String):Value
		{
			var value:Value;
			if (property == _property)
			{
				value = new Value(__value);
			}
			else
			{
				value = super.getValue(property);
			}
			return value;
		}
		override public function setValue(value:Value, property:String):Boolean
		{
			if (property == _property)
			{
				__indeterminateValue = value.indeterminate;
				__value = value.string;
			}
			super.setValue(value, property);
			return false;
		}
		override public function resize():void
		{
			if (! (_width && _height)) return;
			var icon_size = _height;	
			__chipSize = _height - 2;	
			var spacing:Number = getValue(ControlProperty.SPACING).number;
			__colorWidth = _width - (icon_size + 2 + spacing);
			__bm_bevel_mc.x = icon_size + spacing;
			__bevelClip(__bm_bevel_mc, 0, 0, _width - (icon_size + spacing), icon_size);
	
			
			_displayObjectSize('back', new Size(__colorWidth, icon_size - 2));
			
			__bm_mc = _displayedObjects.back as Bitmap;
			if (__bm_mc != null)
			{
				__bm_mc.x = __bm_bevel_mc.x + 1;
				__bm_mc.y = __bm_bevel_mc.y + 1;
			
			}
			
			
			__chip_mc.graphics.clear();
			super.resize();
		}
		override protected function _update():void
		{
			super._update();
			if (__chip_mc.visible = (! __indeterminateValue))
			{
				__chip_mc.graphics.clear();
				RunClass.DrawUtility['fillBox'](__chip_mc.graphics, 1, 1, __chipSize, __chipSize, RunClass.DrawUtility['colorFromHex'](__value));
				var icon_size = height;	
				__bevelClip(__chip_mc, 0, 0, icon_size, icon_size, true);
			}
		}
		private function __bevelClip(clip, x, y, w:Number = 0, h:Number = 0, concave:Boolean = false, depth:Number = 1):void
		{
			
			var up_color = (concave ? 0x000000:0xFFFFFF);
			var down_color =  (concave ? 0xFFFFFF:0x000000);
			
			RunClass.DrawUtility['fillBox'](clip.graphics, x, y, w, depth, up_color, 50);
			RunClass.DrawUtility['fillBox'](clip.graphics, x, y + depth, depth, h - depth, up_color, 50);
		
			RunClass.DrawUtility['fillBox'](clip.graphics, x + w - depth, y + depth, depth, h - depth, down_color, 50);
			RunClass.DrawUtility['fillBox'](clip.graphics, x + depth, y + h - depth, w - (depth * 2), depth, down_color, 50);
		
		}
		override protected function _press(event:MouseEvent):void
		{
			_mouseDrag();
		}
		override protected function _mouseDrag():void
		{
			try
			{
				var pixel:Number = NaN;
				var pt:Point = new Point(RunClass.MouseUtility['x'], RunClass.MouseUtility['y']);
						
				if (__bm_mc.hitTestPoint(pt.x, pt.y))
				{
					pt = __bm_mc.globalToLocal(pt);
					pixel = __bm_mc.bitmapData.getPixel(pt.x, pt.y);
				}
				else
				{
					try
					{
						var obs:Array = RunClass.MovieMasher['instance'].getObjectsUnderPoint(pt);
						if (obs.length)
						{
							var display_object:DisplayObject = obs[0];
							var bitmap_data:BitmapData;
						
							bitmap_data = new BitmapData(display_object.width, display_object.height, true, 0x00000000);
							bitmap_data.draw(display_object);
							pt = display_object.globalToLocal(pt);
							pixel = bitmap_data.getPixel(pt.x, pt.y);
							bitmap_data.dispose();
						}
						
					}
					catch(e:*)
					{
						// oh well
					}
				}
				
				if (! isNaN(pixel))
				{
					__value = RunClass.DrawUtility['hexFromColor'](pixel);
					dispatchPropertyChange(true);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		override protected function _release():void
		{
			try
			{
				dispatchPropertyChange();				
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private var __bm_bevel_mc:Sprite;
		private var __bm_mc:Bitmap;
		private var __chip_mc:Sprite;
		private var __chipSize:Number;
		private var __colorWidth:Number;
		private var __indeterminateValue:Boolean = false;
		private var __value:String;
		
	}
}