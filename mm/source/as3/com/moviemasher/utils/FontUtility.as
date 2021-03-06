﻿/*
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

package com.moviemasher.utils
{
	import flash.text.*;
	import flash.display.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	
/**
* Static class provides functions helpful for working with Text and Fonts
*
* @see Text
* @see Field
* @see Caption
* @see Title
*/
	public class FontUtility
	{
		public static function formatField(field:TextField, item:IValued, size : Size = null, iMash:* = null):void
		{
			if (field != null)
			{
				var value:Value;
				var i_font:Font = null;
				
				var tf:TextFormat = new TextFormat();
				var font_id:String = item.getValue('font').string;
				var option_tag:XML = RunClass.MovieMasher['fontTag'](font_id, iMash);
				var textsize:Number = item.getValue('textsize').number;
				var textalign:String = item.getValue('textalign').string;
				var color:String = item.getValue('forecolor').string;
				if (! color.length) color = item.getValue('textcolor').string;
				if (color.length) tf.color = RunClass.DrawUtility['colorFromHex'](color);
	
				field.embedFonts = true;
				field.selectable = false;
				field.multiline = item.getValue('multiline').boolean;
				
				value = item.getValue('wordwrap');
				field.wordWrap = (value.string.length ? value.boolean : true);
				
				if (option_tag != null)
				{
					if (String(option_tag.@antialias) == 'advanced')
					{
						field.antiAliasType = AntiAliasType.ADVANCED;
					}
					var loader:IAssetFetcher = RunClass.MovieMasher['assetFetcher'](option_tag.@url, 'swf');
					if (loader != null)
					{
						i_font = loader.fontObject(option_tag.@url);
					}
				}
				if (i_font != null) tf.font = i_font.fontName;
				tf.kerning = true;
				if (textsize)
				{
					if ((size != null) && (size.height))
					{
						textsize = Math.round((size.height * textsize) / 100);
					}
					tf.size = textsize;
				}
				if (textalign.length)
				{
					tf.align = TextFormatAlign[textalign.toUpperCase()];
				}
				field.defaultTextFormat = tf;
			}
		}
	}
}


