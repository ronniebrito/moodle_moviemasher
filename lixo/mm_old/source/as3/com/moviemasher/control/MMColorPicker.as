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
	import fl.controls.*;
	
	import flash.display.*;
	import fl.events.*;
	
	import flash.events.*;
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
/**
* Implimentation class represents a standard Flash ColorPicker component control
*/
	public class MMColorPicker extends Control
	{
		public function MMColorPicker()
		{ }
		override protected function _createChildren():void
		{
			_control = new ColorPicker();
			addChild(_control);
			_control.addEventListener(ColorPickerEvent.CHANGE, _controlChange, false, 0, true);
			//_createTooltip();
		}
		protected function _controlChange(event:ColorPickerEvent):void
		{
			dispatchPropertyChange();
		}
		override public function getValue(property:String):Value
		{
			var value:Value;
			if (property == _property)
			{
				value = new Value(_control.hexValue);
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
				if (! value.empty)
				{
					_control.selectedColor = RunClass.DrawUtility['colorFromHex'](value.string);
				}
			}
			else 
			{
				super.setValue(value, property);
			}
			return false;
		}
		override public function resize():void
		{
			_control.setSize(_width, _height);
		}
		protected var _control:ColorPicker;
	}
}