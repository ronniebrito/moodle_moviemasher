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
//	import flash.events.*;
	import flash.net.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
/**
* Interface for playback handlers
*
* @see Handler
* @see AssetFetcher
*/
	public interface IHandler  extends IDisplay
	{
		function get metrics():Size;
		
		function buffer(range:Object):void;
		function buffered(range:Object):Boolean;
		function unload():void;
		function destroy():void;
		function get bytesLoaded():Number;
		function get bytesTotal():Number;
		function get duration():Number;
		function set duration(iNumber:Number):void;
		function get active():Boolean;
		function set active(iBoolean:Boolean):void;
		function set visual(iBoolean:Boolean):void;
		function set bufferTime(iNumber:Number):void;
		function set loops(iNumber:Number):void;
		function get playing():Boolean;
		function set playing(iBoolean:Boolean):void;
		function get time():Number;
		function set time(iNumber:Number):void;
		function set volume(iNumber:Number):void;
		function get volume():Number;
		function get keepsTime():Boolean;
		

	}
}