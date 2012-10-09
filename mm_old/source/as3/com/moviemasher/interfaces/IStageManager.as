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
	import flash.display.*;
	import flash.geom.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
/**
* Interface for stage manager implementation
*
* @see StageManager
* @see MoviemasherStage
* @see MovieMasher
*/
	public interface IStageManager extends IEventDispatcher
	{
		function initialize():void;
		function getParameter(property:String):String;
		function setTooltip(tooltip:ITooltip, owner:IControl):void;
		function setCursor(bm : DisplayObject = null, offset:Point = null):void;
		function set size(s:Size):void;
		function get size():Size;
		function msg(s:*, type:* = null):void;
	}
}