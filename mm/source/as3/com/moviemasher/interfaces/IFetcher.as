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
/**
* Base Interface for fetching of all server side resources.
* One of the sub interfaces must be used in order to do more than load or monitor the fetch.
*
* @see ILoadManager
*/
	public interface IFetcher extends IEventDispatcher
	{
/** Retrieves the amount of data that has been fetched or -1 if fetching has not begun.
* @returns Number of bytes currently fetched.
*/
		function get bytesLoaded():Number;
/** Retrieves the total amount of data or -1 if fetching has not begun or the total is not yet known.
* @returns Number of bytes total.
*/
		function get bytesTotal():Number;
/** Retrieves a parsed version of url suitable for use as an Object property name.
* @returns String that is a unique identifier for url.
*/
		function get key():String;
/** Retrieves the current fetch state of server side resource.
* @returns String equal to either {@link EventType.LOADING} or {@link EventType.LOADED}.
*/
		function get state():String;
/** Sets the location of the server side resource.
* @param string String optionally containing location, # or @ symbol, class name or frame label
*/
		function set url(string:String):void;
	}
}