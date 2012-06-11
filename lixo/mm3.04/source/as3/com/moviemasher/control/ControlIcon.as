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
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
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
* Abstract base class represents a simple button control
*/
	public class ControlIcon extends Control
	{
		public function ControlIcon()
		{
			_defaults.angle = '90';
			_defaults.border = '0';
			_defaults.bordercolor = '000000';
			_defaults.grad = '0';
			_ratioKey = 'icon';
		}
		override protected function _createChildren():void
		{
			try
			{
				_displayObjectLoad('icon');
				_displayObjectLoad('overicon');
				_displayObjectLoad('disicon');
				super._createChildren();
				addEventListener(MouseEvent.MOUSE_DOWN, __mouseDown);
				_createTooltip();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		override public function resize():void
		{
			
			_sizeIcons();
			super.resize();
		}
		public function select():void
		{
			_release();
		}
		override public function setValue(value:Value, property:String):Boolean
		{
			if (property == 'click')
			{
				select();
			}
			else super.setValue(value, property);
			return false;
		}
		override protected function _update():void
		{
			var mc:DisplayObject;
			mc = _displayedObjects['disicon'];
			if (mc != null) 
			{
				mc.visible = _disabled;
				mc = _displayedObjects['icon'];
				if (mc != null) 
				{
					mc.visible = ! _disabled;
				}
			}
			var tf:Boolean = ((root == null) ? false : hitTestPoint(root.mouseX, root.mouseY));
			if (_selected) tf = ! tf;
			_roll(tf);
		}
		protected function _sizeIcons():Boolean
		{
			var did_size:Boolean = false;

			var i_size:Size = null;
			if (getValue(MediaProperty.FILL).equals(FillType.STRETCH)) 
			{
				i_size = new Size(_width, _height);
			}
			if (_displayObjectSize('icon', i_size)) did_size = true;
			if (_displayObjectSize('overicon', i_size)) did_size = true;
			if (_displayObjectSize('disicon', i_size)) did_size = true;
			return did_size;
		}
		override protected function _mouseOut():void
		{			
			try
			{
				_roll(_selected);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._mouseOut (ControlIcon)', e);
			}
		}
		override protected function _mouseOver(event:MouseEvent):void
		{ 
			try
			{
				_roll(! _selected); 
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		protected function __mouseDown(event:MouseEvent)
		{
			try
			{
				if (! _disabled)
				{
					_rollTimerCancel();
					RunClass.MouseUtility['drag'](this, event, __mouseDrag, __mouseUp);
					_press(event);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		protected function _press(event:MouseEvent):void
		{}
		protected function _roll(tf : Boolean, prefix : String = ''):void
		{
			try
			{
				var overicon:DisplayObject = _displayedObjects[prefix + 'overicon'];
				var icon:DisplayObject = _displayedObjects[prefix + 'icon'];
				
				
				if (_disabled) tf = false;
				else
				{
					if ((icon != null) && (! icon.visible)) 
					{
						tf = false;
					}
				}
				
				
				if (overicon != null)
				{
					if (overicon.visible != tf)
					{
						overicon.visible = tf;			
						if (tf)
						{
							if (overicon is MovieClip)
							{
								(overicon as MovieClip).gotoAndPlay(1);
							}
						}
						else
						{
							if ((icon != null) && (icon is MovieClip))
							{
								(icon as MovieClip).gotoAndPlay(1);
							}
						}
					}
					if ((icon != null) && (icon.visible == tf))
					{
						icon.visible = ! tf;
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __mouseDrag():void
		{
			try
			{
				
				_mouseDrag();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __mouseUp():void
		{
			try
			{
				if (! hitTestPoint(RunClass.MouseUtility['x'], RunClass.MouseUtility['y']))
				{
					_mouseOut();
				}
				else _roll(! _selected);
				_release();
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
	}
}