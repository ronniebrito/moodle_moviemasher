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
	import fl.data.*;
	import flash.events.*;
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
/**
* Implimentation class represents a standard Flash ComboBox component control
*/
	public class MMComboBox extends Control
	{
		public function MMComboBox()
		{ }
		override protected function _createChildren():void
		{
			_control = new ComboBox();
			addChild(_control);
			_control.addEventListener(Event.CHANGE, _controlChange, false, 0, true);
			_control.dataProvider = new DataProvider(_tag);
			//_createTooltip();
		}
		protected function _controlChange(event:Event):void
		{
			try
			{
				dispatchPropertyChange();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}

		}
		override public function getValue(property:String):Value
		{
			var value:Value;
			if (property == _property)
			{
				if (_control.selectedIndex == -1)
				{
					value = new Value(null);
				}
				else
				{
					try
					{
						value = new Value(_control.selectedItem.id);
					}
					catch(e:*)
					{
						value = new Value('');
					}
				}
			}
			else 
			{
				value = super.getValue(property);
			}
			return value;
		}
		private var __hidden:Boolean = false;
		private var __needsDispatch:Boolean = false;
		
		override public function set hidden(iBoolean:Boolean):void
		{
			__hidden = iBoolean;
			if (! __hidden)
			{
				if (__needsDispatch && getValue('force').boolean) dispatchPropertyChange();
				__needsDispatch = false;
			}
		}
		
		
		override public function setValue(value:Value, property:String):Boolean
		{
			
			if (property == _property)
			{
				var list:XMLList = _tag.children();
				if (list.length())
				{
					
					if (value.empty || value.equals('default'))
					{
						__needsDispatch = true;
						
						
						//value.string = list[0].@id;
						value = new Value(list[0].@id);
					}
					list = list.(@id == value.string);
					if (list.length())
					{
						_control.selectedIndex = list[0].childIndex();
					}
					else 
					{
						__needsDispatch = true;
						
						
						if (_control.selectedIndex == -1) _control.selectedIndex = 0;
						
					}
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
			_control.drawNow();
		}
		
		
		protected var _control:ComboBox;
		
		
	}
}