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
	import flash.display.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.events.*;
/** 
* Implementation class displays a button that can be tied to action properties
*/ 
	public class Icon extends ControlIcon
	{
		public function Icon()
		{ }
		
		override public function finalize():void
		{
			_selected = super.getValue('preselected').boolean;
			if (_selected)
			{
				_release();
				_update();
			}
		}
		
		override public function getValue(property:String):Value
		{
			var value:Value;
			
			if (property == _property) 
			{
				value = super.getValue('value');
			}
			else
			{
				value = super.getValue(property);
			}
			return value;
		}
		override protected function _release() : void
		{
			try
			{
				if (! _disabled) 
				{
					dispatchPropertyChange();
					var trigger:String = getValue(CGIProperty.TRIGGER).string;
					if (trigger.length)// setting a value for a control
					{
						RunClass.MovieMasher['evaluate'](trigger);
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
	}
}
