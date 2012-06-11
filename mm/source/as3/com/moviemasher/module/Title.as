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
package com.moviemasher.module
{
	import flash.text.*;
	import flash.events.*;
	import flash.display.*;
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.events.*;
/**
* Implementation base class for displaying text within mash
*
* @see IModule
* @see Clip
* @see Mash
*/
	public class Title extends Module implements IValued // so we can use formatField
	{
		public function Title()
		{
			_defaults.textalign = 'center';
			_defaults.textsize = '48';
			_defaults.forecolor = 'FFFFFF';
			_defaults.backcolor = '0';
			_defaults.text = '';
			_defaults.copy = '';
			_defaults.longtext = 'Title';
			_defaults.font = 'default';
			_textField = new TextField();
			_textField.autoSize = TextFieldAutoSize.LEFT;
			addChild(_textField);
		}
		
		public function getValue(property:String):Value
		{
			return new Value(_getClipProperty(property));
		}
		override public function get backColor():String
		{
			return _getClipProperty(ModuleProperty.BACKCOLOR);
		}
		override public function buffered(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):Boolean
		{
			var is_buffered:Boolean = true;
			var loader:IAssetFetcher = __fontLoader(_getClipProperty(ModuleProperty.FONT));
			if (loader != null)
			{
				is_buffered = (loader.state == EventType.LOADED);	
			}
			return is_buffered;
		}
		override public function get displayObject():DisplayObjectContainer
		{
			return this;
		}
		private function __fontLoader(font:String):IAssetFetcher
		{
					
			var loader:IAssetFetcher;
			if ((font != null) && font.length)
			{
				loader = __fontLoaders[font];
				if (loader == null)
				{
					var url:String = '';
					__fontLoaders[font] = false; // so we only try once

					var font_tag:XML;
					var imash:* = null;
					if ((font != null) && font.length)
					{
						imash = _getClipPropertyObject(ClipProperty.MASH);
						
						font_tag = RunClass.MovieMasher['fontTag'](font, imash);
						if (font_tag != null)
						{
							url = String(font_tag.@url);
						}
					}
			
			
					if (url.length)
					{
						loader = RunClass.MovieMasher['assetFetcher'](url, 'swf');
						if (loader != null)
						{
							__fontLoaders[font] = loader;
							loader.addEventListener(Event.COMPLETE, _fontComplete);
						}
					}
				}
			}
			return loader;
		}
	
		protected function _fontComplete(event:Event):void
		{
			try
			{
				event.target.removeEventListener(Event.COMPLETE, _fontComplete);
				var font:String = _getClipProperty(ModuleProperty.FONT);
				if ((font != null) && font.length)
				{
					if (__fontLoaders[font] == event.target)
					{
						dispatchEvent(new Event(EventType.BUFFER));
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		override public function setFrame(clip_frame:Number):void
		{
			super.setFrame(clip_frame);
			_setTime(clip_frame);
		}
		protected function _formatField():void
		{
			try
			{
				RunClass.FontUtility['formatField'](_textField, this, _size, _getClipPropertyObject(ClipProperty.MASH));
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._formatField', e);
			}
		}
		protected function _setTime(clip_frame:Number):void
		{
			try
			{
				_formatField();
				_setText(clip_frame);
				_setTextSize(clip_frame);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._setTime', e);
			}

		}
		protected function _setText(clip_frame:Number):void
		{
			try
			{
				_textField.width = _size.width;
				var s:String = _getText(clip_frame);
				var tf:TextFormat = _textField.defaultTextFormat;
				_textField.htmlText = s;
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._setText', e);
			}

		}
		protected function _getText(clip_frame:Number):String
		{
			var text:String = _getClipProperty('text');
			var delimiter:String;
			var was_text:Boolean = Boolean(text.length);
			if (! text.length)
			{
				text = _getClipProperty('longtext');
			}
			if (text.length) 
			{
				delimiter =  _getMediaProperty('delimiter');
				if ((delimiter != null) && delimiter.length)
				{
					var index:Number = text.indexOf(delimiter);
					
					if (index != -1)
					{
						text = text.substr(0, index);
					}
				}
			}
			return text;
		}
		protected function _setTextSize(clip_frame:Number):void
		{
			try
			{
				_textField.x = - Math.round(_textField.width / 2);
				_textField.y = - Math.round(_textField.height / 2);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._setTextSize', e);
			}

		}
		protected var _textField:TextField;
		private static var __fontLoaders:Object = new Object();
	}
}