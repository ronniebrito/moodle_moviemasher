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
	import com.moviemasher.events.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
/**
* Interface for most objects that configure themselves with an XML tag.
*/
	public interface IPropertied extends IValued
	{		
/**
* Sets a property's value
* 
* @param value {@link Value} object containing new value
* @param property String object containing property name
*/
		function setValue(value:Value, property:String):Boolean;
/**		
* Get object configuration tag.
* @returns XML object, potentially with child tags.
*/
		function get tag():XML;
/**		
* Set object configuration tag.
* @param xml XML tag, with attributes and optionally child tags.
*/
		function set tag(xml:XML):void;
/** Listen for {@link ChangeEvent} from broadcaster for a particular property.
* @param property String name of attribute to listen for changes to.
* @param broadcaster IEventDispatcher object that will broadcast changes.
*/
		function addEventBroadcaster(property:String, broadcaster:IEventDispatcher):void;
/** Handle a {@link ChangeEvent} from broadcaster.
* @param event ChangeEvent to handle. Will typically call setValue method with event info.
*/
		function changeEvent(event:ChangeEvent):void;

	}
}