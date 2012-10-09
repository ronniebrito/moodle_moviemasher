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
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.type.*;	
	import com.moviemasher.utils.*;
	import flash.display.*;
	import flash.text.*;
/**
* Implementation class for caption title effect module
*
* @see IModule
* @see Clip
* @see Mash
*/

	public class Caption extends Title
	{
		public function Caption()
		{
			_defaults.backalpha = '50';
			_defaults.multiline = '1';
			_defaults.padding = '4';
			_defaults.textsize = '12';
			_defaults.wordwrap = '1';
			_back_mc = new Sprite();
			addChildAt(_back_mc, 0);
			_textField.wordWrap = true;
		}
		override public function get backColor():String
		{
			return null;
		}
		override protected function _setText(clip_frame:Number):void
		{
			_time = clip_frame;
			var padding:Number = Math.round((_getClipPropertyNumber(ModuleProperty.PADDING) * _size.height)/100);
			super._setText(clip_frame);
			_textField.width = _size.width - (padding * 2);
		}
		override protected function _setTextSize(clip_frame:Number):void
		{
			try
			{
				
				var padding:Number = Math.round((_getClipPropertyNumber(ModuleProperty.PADDING) * _size.height)/100);
				_backHeight = _textField.textHeight + padding;
				_backWidth = _size.width;
				_backSize();
				_back_mc.x = - Math.round(_backWidth / 2);
				_back_mc.y = Math.round(_size.height / 2) - _backHeight;
				_textField.x = _back_mc.x + padding;
				_textField.y = _back_mc.y;
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		protected function _backSize():void
		{
			try
			{
				var per:Number = _getFade(_time) / 100;
				_textField.alpha = per;
				_back_mc.graphics.clear();
				var backcolor:String = _getClipProperty(ModuleProperty.BACKCOLOR);
				
				if ((backcolor != null) && backcolor.length)
				{
					var backalpha:Number = _getClipPropertyNumber('backalpha');
					if (backalpha)
					{
						backalpha *= per;
						//RunClass.MovieMasher['msg'](this + '._backSize ' + backcolor + ' ' + backalpha + ' ' +  _backWidth + ' ' + _backHeight);
						RunClass.DrawUtility['fill'](_back_mc.graphics, _backWidth, _backHeight, RunClass.DrawUtility['colorFromHex'](backcolor), backalpha);
					}
				}
				//else RunClass.MovieMasher['msg'](this + '._backSize ' + backcolor);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		protected var _back_mc:Sprite;
		protected var _backHeight:Number;
		protected var _backWidth:Number;
		protected var _time:Number;
	}
}