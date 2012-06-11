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

package com.moviemasher.interfaces
{
	
/**
* Interface for incrementor implementations
* 
* @see Ruler
* @see Increment
*/
	public interface IIncrement extends IMetrics, IValued
	{
/**
* Sets time to display for marker (write-only)
* 
* @param n Number object containing new time
*/
		function set time(n:Number):void;
/**
* Sets font to use to display marker (write-only)
* 
* @param s String object containing font id
*/
		function set font(s:String):void;
/**
* Sets text alignment to use to display marker (write-only)
* 
* @param s String object containing font id
*/
		function set textalign(s:String):void;
/**
* Sets font color to use to display marker (write-only)
* 
* @param s String object containing 6 char hex color
*/
		function set color(s:String):void;
/**
* Sets text size to display for marker (write-only)
* 
* @param n Number object containing new size
*/
		function set size(n:Number):void;
/**
* Sets vertical text offset (write-only)
* 
* @param n Number object containing new offset
*/
		function set textoffset(n:Number):void;
/**
* Sets pattern to use to display marker (write-only)
* 
* @param s String object containing bracketed properties
*/
		function set pattern(s:String):void;
	}
}