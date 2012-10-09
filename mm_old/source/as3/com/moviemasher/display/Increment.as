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
	import flash.display.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import flash.text.*;
	import com.moviemasher.utils.*;


/**
* Base class represents time marker for {@link Ruler} control
*
* @see Ruler
* @see IIncrement
*/
	public class Increment extends MovieClip implements IIncrement
	{
		public function Increment()
		{
		}
		
		public function set time(n:Number):void
		{
			
			_text = RunClass.ParseUtility['brackets'](_pattern, {time: RunClass.StringUtility['timeString'](n, 10)});
			if (_textField != null)
			{
				
				__setText();
			}
		}
		public function set font(s:String):void
		{
			_font = s;
		}
		public function set pattern(s:String):void
		{
			_pattern = s;
		}
		public function set color(s:String):void
		{
			_fontColor = s;
		}
		
		public function set size(n:Number):void
		{
			_fontSize = n;
		}
		public function set textalign(s:String):void
		{
			_textalign = s;
		}
		
		public function set textoffset(n:Number):void
		{
			_textoffset = n;
		}
		public function set metrics(iMetrics:Size):void
		{
			_metrics = iMetrics;
			
			height = _metrics.height;
			scaleX = scaleY;
			_metrics.width = width;
		}
		public function get metrics():Size
		{
			return _metrics;
		}
		public function get displayObject():DisplayObjectContainer
		{
			if (_textField == null)
			{
				_textField = new TextField();
				_textField.y = -2;
				
				addChild(_textField);
				RunClass.FontUtility['formatField'](_textField, this);
				_textField.autoSize = TextFieldAutoSize.LEFT;//[_textalign.toUpperCase()];
				__setText();
			}
			return this;
		}
		private function __setText():void
		{
			_textField.text = _text;
			var x_pos:Number = 0;
			switch(_textalign)
			{
				case 'left':
					x_pos = - (_textField.textWidth + 4);
					break;
				case 'right':
					x_pos = 0;//-Math.round(_metrics.width / 2);
					break;
				default:
					x_pos = - Math.round(_textField.textWidth / 2);
					
			}
			_textField.x = x_pos;
			_textField.y = _textoffset;
				
		}
		protected var _text:String = '';
		protected var _metrics:Size;
		protected var _textField:TextField;
		protected var _font:String = 'default';
		protected var _fontColor:String = '000000';
		protected var _textalign:String = 'center';
		protected var _fontSize:Number = 12;
		protected var _pattern:String = '{time}';
		protected var _textoffset:Number = 0;
		public function getValue(property:String):Value
		{
			var value:Value;
			switch (property)
			{
				case ModuleProperty.FONT:
					value = new Value(_font);
					break;
				case 'textcolor':
					value = new Value(_fontColor);
					break;
				case 'textalign':
					value = new Value('left');
					break;
				case 'textsize':
					value = new Value(_fontSize);
					break;
				default:
					value = new Value('');
			}
			return value;
		}
	
	}
}