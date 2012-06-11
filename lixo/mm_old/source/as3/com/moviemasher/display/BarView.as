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
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.display.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
/**
* Class represents a BAR tag containing controls
*
* @see Control
* @see ControlView
*/
	public class BarView extends View
	{
		public function BarView(panel : PanelView)
		{
			__children = new Array();
			__panel = panel;
			_defaults = __barDefaults;
			
		}
		public function hasVisibleControl():Boolean
		{
			var should_be_visible:Boolean = true;
			var z:int = __children.length;
			if (z)
			{
				should_be_visible = false;
				var control:ControlView;
				var i:int;
				for (i = 0; i < z; i++)
				{
					control = __children[i];			
					if (control.visible)
					{
						should_be_visible = true;
						break;
					}
				}
			}
			return should_be_visible;
		}
		override public function resize():void
		{
			super.resize();
			var padding : Number = getValue(ControlProperty.PADDING).number + getValue('border').number;
			var spacing : Number = getValue(ControlProperty.SPACING).number;
			var hORw : String = (vertical ? 'width' : 'height');
			var yORx : String = (vertical ? 'x' : 'y');
			var wORh : String = (vertical ? 'height' : 'width');
			var xORy : String = (vertical ? 'y' : 'x');
			var bar_size:Size = new Size(_width - (2 * padding), _height - (2 * padding));
			var hard : Size = new Size();
			var flex : Size = new Size();
			var control:ControlView;
			var sizes:Dictionary = new Dictionary();
			var pos:Point = new Point(padding, padding);
			var now_pos:Point;
			var align : String;
			var z:int = __children.length;
			var i:int;
			var control_rect:Rectangle;
			var v_count = 0;
			for (i = 0; i < z; i++)
			{
				control = __children[i];
				
				if (control.visible)
				{
					if (control.flexible) 
					{
						flex[wORh] += control.flexible;
						sizes[control] = new Size();
						sizes[control][hORw] = control.getValue(hORw).number;
						if (! sizes[control][hORw]) sizes[control][hORw] = bar_size[hORw];
					}
					else 
					{
						sizes[control] = control.dimensionsFromBarSize(bar_size[hORw]);
						hard[wORh] += sizes[control][wORh];
					}
					if (v_count > 0) hard[wORh] += spacing;
					v_count ++;
				}
			}
			if (flex.width || flex.height)
			{
				if (flex[wORh]) flex[wORh] = (bar_size[wORh] - hard[wORh]) / flex[wORh];
				if (flex[hORw]) flex[hORw] = (bar_size[hORw] - hard[hORw]) / flex[hORw];
				for (i = 0; i < z; i++)
				{
					control = __children[i];
					if (control.visible && control.flexible) 
					{
						sizes[control][wORh] = control.flexible * flex[wORh];
					}
				}
			}
			for (i = 0; i < z; i++)
			{
				control = __children[i];
				if (control.visible)
				{
					now_pos = pos.clone();
					if (sizes[control][hORw] != bar_size[hORw])
					{
						if (sizes[control][hORw] > bar_size[hORw]) 
						{
							sizes[control][hORw] = bar_size[hORw];
						}
						else
						{
							align = control.getValue('align').string;
							switch (align)
							{
								case 'bottom' :
								case 'right' :
									now_pos[yORx] += bar_size[hORw] - sizes[control][hORw];
									break;
								case 'left':
								case 'top':
									break;
								default:
									now_pos[yORx] += Math.round((bar_size[hORw] - sizes[control][hORw]) / 2);
							}
						}
					}
					control_rect = new Rectangle(now_pos.x, now_pos.y, sizes[control].width, sizes[control].height);
					
					if (! control_rect.isEmpty())
					{
						control.control.displayObject.visible = true;
						control.setRect(control_rect);
						pos[xORy] += spacing + sizes[control][wORh];
					}
					else
					{
						control.control.displayObject.visible = false;
						break;
					}
				}
				
			}
		}
		public var dynamicWidth : Boolean = false;
		public var dynamicHeight : Boolean = false;
		public var flexible : Number = 0;
		public var vertical : Boolean = false;
		override protected function _parseTag():void
		{
			super._parseTag();
				
			dynamicWidth = ! String(_tag.@width).length;
			dynamicHeight = ! String(_tag.@height).length;

			var size_attribute:String = String(_tag.@size);
			if (size_attribute.length && isNaN(Number(size_attribute)))
			{
				flexible = size_attribute.length;
			}


			if (String(_tag.@align).length)
			{
				switch (String(_tag.@align))
				{
					case 'left' :
					case 'right' :
						vertical = true;
				}
			}
			var controls : XMLList = _tag.control;
			var z : Number;
			var i : Number;
			var control : ControlView;

			
			z = controls.length();
			if (z > 0)
			{
				for (i = 0; i < z; i++)
				{
					control = new ControlView(__panel, this);
					
					__children_mc.addChild(control);
					__children.push(control);
					control.tag = controls[i];
					if (control.isLoading)
					{
						_loadingThings++;
				
						control.addEventListener(Event.COMPLETE, _tagCompleted, false, 0, true);
					}
				}
			}
		}
		private static  var __barDefaults : Object = {align: 'top', angle: '90', color: '', curve: '0', grad: '0', padding: '0', spacing: '0', size: '0', x: '0', y: '0', alpha:'100'};
		private var __panel : PanelView;
	}
}