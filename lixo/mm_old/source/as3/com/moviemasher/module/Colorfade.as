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
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
/**
* Implementation class for colorfade image module
*
* @see IModule
* @see Clip
* @see Mash
*/
	public class Colorfade extends Module
	{
		public function Colorfade()
		{
			_defaults['forecolor'] = 'FFFFFF';
			_defaults[ModuleProperty.BACKCOLOR] = '0';
			_defaults['fade'] = Fades.IN;
		}
		
		override public function setFrame(clip_frame:Number):Boolean
		{
			var changed:Boolean = super.setFrame(clip_frame);
			if (_runningAsPreview == null)
			{
				// we didn't fill in super, so do it now
				graphics.clear();
				RunClass.DrawUtility['fillBox'](graphics, - _size.width / 2, - _size.height / 2, _size.width, _size.height, __blendedColor());
			}
			return changed;
		}
		override public function backColor():String
		{
			var s:String = null;
			if (_runningAsPreview != null)
			{
				s = RunClass.DrawUtility['hexFromColor'](__blendedColor());
			}
			return s;
		}
		private function __blendedColor():Number
		{
			var forecolor:Number = RunClass.DrawUtility['colorFromHex'](_getClipProperty('forecolor'));
			var backcolor:Number = RunClass.DrawUtility['colorFromHex'](_getClipProperty(ModuleProperty.BACKCOLOR));
			return RunClass.DrawUtility['blendColor'](_getFade(_frame) / 100, forecolor, backcolor);
			
		}
	}
}