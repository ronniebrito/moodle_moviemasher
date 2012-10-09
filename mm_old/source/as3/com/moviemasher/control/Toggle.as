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
* Implementation class represents a simple on/off button control
*/
	public class Toggle extends Icon
	{
		public function Toggle()
		{
			
		}
		override protected function _createChildren():void
		{
			try
			{
				_displayObjectLoad('toggleicon');
				_displayObjectLoad('toggleovericon');
				_displayObjectLoad('toggledisicon');
				super._createChildren();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		override protected function _roll(tf : Boolean, prefix : String = ''):void
		{
			if ((! prefix.length) && getValue(_property).boolean) prefix = 'toggle';
			super._roll(tf, prefix);
			
		}
		override protected function _update():void
		{
			var toggled:Boolean = getValue(_property).boolean;
			
			var toggle:String = (toggled ? 'toggle' : '');
			var untoggle:String = (toggled ? '' : 'toggle');
			
			
			var mc:DisplayObject;
			
			// hide all the other icons
			mc = _displayedObjects[untoggle + 'icon'];
			if (mc != null) mc.visible = false;
			mc = _displayedObjects[untoggle + 'overicon'];
			if (mc != null) mc.visible = false;
			mc = _displayedObjects[untoggle + 'disicon'];
			if (mc != null) mc.visible = false;
			
			
			// find the disabled icon
			mc = _displayedObjects[toggle + 'disicon'];
			if (mc != null)
			{
				mc.visible = _disabled;
				mc = _displayedObjects[toggle + 'icon'];
				if (mc != null) 
				{
					mc.visible = ! _disabled;
				}
			}
			var tf:Boolean = ((root == null) ? false : hitTestPoint(root.mouseX, root.mouseY));
			if (_selected) tf = ! tf;
			_roll(tf);
		}
		
		override protected function _sizeIcons():Boolean
		{
			var did_size:Boolean = false;

			var i_size:Size = null;
			if (getValue(MediaProperty.FILL).equals(FillType.STRETCH)) 
			{
				i_size = new Size(_width, _height);
			}
			if (_displayObjectSize('toggleicon', i_size)) did_size = true;
			if (_displayObjectSize('toggleovericon', i_size)) did_size = true;
			if (_displayObjectSize('toggledisicon', i_size)) did_size = true;
			did_size = (super._sizeIcons() || did_size);
			return did_size;
		}
		override protected function _release() : void
		{ 
			try
			{
				if (! _disabled) 
				{
					setValue(new Value((getValue(_property).boolean ? 0 : 1)), 'value');
					dispatchPropertyChange();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._release', e);
			}
		
		}
	}
}