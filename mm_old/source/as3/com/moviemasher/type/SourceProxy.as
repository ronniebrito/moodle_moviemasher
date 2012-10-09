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


package com.moviemasher.type
{
	import flash.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.events.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	
/**
* Class passes events from an ISource implementation to a browser control
* @see ISource
* @see Browser
*/
	public class SourceProxy extends Propertied
	{
		public function SourceProxy()
		{ }
		override public function setValue(value:Value, property:String):Boolean
		{
			var tf:Boolean = super.setValue(value, property);
			if (__source) __source.setValue(value, property);
			dispatchEvent(new Event('change'));
			dispatchEvent(new ChangeEvent(value, property));
			return tf;
		}
		public function set source(iSource:ISource):void
		{
			__source = iSource;
			if (__source != null)
			{
				for (var k:String in _attributes)
				{
					__source.setValue(getValue(k), k);
				}
			}
		}
		private var __source:ISource;
	}
}