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
	import flash.events.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	
/**
* Interface for all controls
* 
* @see Control
* @see ControlView
*/
	public interface IControl extends IMetrics, IPropertied
	{
/**
* Prepare control for initial connecting
*/
		function initialize():void;
/**
* Prepare control for initial display
*/
		function finalize():void;
/**
* Boolean indicating whether control is still loading assets (read-only)
*/
		function get isLoading():Boolean;
/**
* Float specifying aspect ratio of control graphic
*/
		function get ratio():Number;
		function set disabled(iBoolean:Boolean):void;
		function set selected(iBoolean:Boolean):void;
		function set property(iProperty:String):void;
		function set hidden(iBoolean:Boolean):void;
		function dispatchPropertyChange(is_ing : Boolean = false):void;
		function updateTooltip(tooltip:ITooltip):Boolean;
	}
}