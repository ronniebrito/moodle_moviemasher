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
	import flash.events.*;	
	import flash.text.*;
	import flash.display.*;
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.events.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
/**
* Implimentation class represents an editable text field control
*/
	public class Field extends Text
	{
		public function Field()
		{
			_defaults.maxchars = '0';
			_defaults.textvalign = 'top';
			_defaults.restrict = '';
		}
		override public function set hidden(iBoolean:Boolean):void
		{
			if (iBoolean)
			{
				_textField.removeEventListener(Event.CHANGE, __fieldChange);
			}
			else
			{
				_textField.addEventListener(Event.CHANGE, __fieldChange);
			}
		}
		override public function initialize():void
		{
			super.initialize();
			
			_textField.selectable = true;
			_textField.type = TextFieldType.INPUT;
			var restrict:String = getValue('restrict').string;
			if (restrict.length)
			{
				_textField.restrict = restrict;
			}
			if (getValue('password').boolean) _textField.displayAsPassword = true;
			_textField.maxChars = getValue('maxchars').number;
		}
		override public function getValue(property:String):Value
		{
			var value:Value;
			
			if (property == _property) 
			{
				value = new Value(_textField.text);
			}
			else
			{
				value = super.getValue(property);
			}
			return value;
		}
		// overridden so a click doesn't do anything
		override protected function _release() : void
		{}
		override public function setValue(value:Value, property:String):Boolean
		{
			if (property == _property)
			{
				if ((! _iChanged) && (_textField.text != value.string))
				{
					_textField.text = value.string;
				}
				_iChanged = false;
				
			}
			super.setValue(value, property);
			return false;
		}
		override public function resize():void
		{
			_textField.height = _height;
			super.resize();
		}
		protected function __fieldChange(event:Event):void
		{
			try
			{
				_iChanged = true;
				dispatchPropertyChange();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		protected var _iChanged:Boolean;
	}
}