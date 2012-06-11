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
	import com.moviemasher.events.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;

/**
* Implimentation class represents a simple text control
*/
	public class Text extends Icon
	{
		public function Text()
		{
			_currentValues = new Object();
			_defaults.textsize = '12';
			_defaults.textalign = 'left';
			_defaults.textvalign = '';
			_defaults.font = 'default';
			_defaults.textcolor = '000000';
			_defaults.multiline = '0';
			_defaults.wrap = '1';
			//_defaults.autosize = 'left';
			
			_allowFlexibility = true;
		}
		override public function initialize() : void 
		{
			super.initialize();
			RunClass.FontUtility['formatField'](_textField, this);
			_textField.wordWrap = _textField.multiline = getValue('wrap').boolean;
			
		}
		override public function resize():void
		{
			super.resize();
			_textField.width = _width;
			_textField.height = _height;
			var x_pos:Number = 0;
			var y_pos:Number = 0;
			if (_textField.textHeight)
			{
				switch (getValue('textvalign').string)
				{
					case 'top':
						break;
					case 'bottom':
						y_pos = _height - (_textField.textHeight);
						break;
					default:
						y_pos = Math.round((_height - (_textField.textHeight + 4)) / 2);
				}
			}
			_textField.x = x_pos;
			_textField.y = y_pos;
		}
		override public function setValue(value:Value, property:String):Boolean
		{
			if (value.undefined)
			{
				value.string = '';
			}
			_currentValues[property] = value.string;
			if (_defaults[property] == null)
			{
				super.setValue(value, property);
			}
			return false;
		}
		override protected function _createChildren():void
		{
			super._createChildren();
			_textField = new TextField();
			addChild(_textField);
			_textField.text = '';
			var align:String = getValue('autosize').string;
			if (align.length) _textField.autoSize = TextFieldAutoSize[align.toUpperCase()];
			_displayObjectLoad(ModuleProperty.FONT);
		}
		override protected function _mouseOver(event:MouseEvent):void
		{ 
			try
			{
				
				var color:String = getValue('overforecolor').string;
				//
				
				if (color.length)
				{
					var tf:TextFormat = _textField.defaultTextFormat;
					tf.color = RunClass.DrawUtility['colorFromHex'](color);
					_textField.defaultTextFormat = tf;
					var s:String = '';
					if (getValue('html').boolean)
					{
						s = _textField.htmlText;
						_textField.htmlText = '';
						_textField.htmlText = s;
					}
					else
					{
						s = _textField.text;
						_textField.text = '';
						_textField.text = s;
					}
				}
				super._mouseOver(event);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + ' _mouseover', e);
			}
		}
		override protected function _mouseOut():void
		{
			try
			{
				var color:String = getValue('overforecolor').string;
				
				if (color.length)
				{
					color = getValue('forecolor').string;
					var tf:TextFormat = _textField.defaultTextFormat;
					tf.color = RunClass.DrawUtility['colorFromHex'](color);
					_textField.defaultTextFormat = tf;
					var s:String = '';
					if (getValue('html').boolean)
					{
						s = _textField.htmlText;
						_textField.htmlText = '';
						_textField.htmlText = s;
					}
					else
					{
						s = _textField.text;
						_textField.text = '';
						_textField.text = s;
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._mouseOut (Text)', e);
			}
			super._mouseOut();
		}
		override protected function _sizeIcons():Boolean
		{
			var did_size:Boolean = super._sizeIcons();
			if (did_size)
			{
				// I have background graphics which may now be above the text field
				
				if ((_textField != null) && contains(_textField) && (getChildIndex(_textField) < (numChildren - 1)))
				{
					removeChild(_textField);
					addChild(_textField);
				}
			}
			return did_size;
		}
		override protected function _update():void
		{
			super._update();
			var pattern:String = getValue('pattern').string;
			if (pattern.length)
			{
				pattern = RunClass.ParseUtility['brackets'](pattern, _currentValues);
			}
			else if (_currentValues[_property] != null)
			{
				pattern = _currentValues[_property];
			}
			else pattern = getValue('text').string;
			if (getValue('html').boolean)
			{
				_textField.htmlText = pattern;
			}
			else
			{
				_textField.text = pattern;
			}
			
		}
		protected var _currentValues : Object;
		protected var _textField : TextField;
	}
}