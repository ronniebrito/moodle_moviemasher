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
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import flash.events.*;
/**
* Interface for configuration manager implementation
*
* @see ConfigManager
* @see MoviemasherStage
* @see MovieMasher
*/
	public interface IConfigManager extends IEventDispatcher
	{

		function fontTag(font:String, iMash:* = null):XML;
		function getOptionXML(type:String, having_attribute:String = null):XML;
		function loadConfiguration(url_string : String, container:XML = null):Boolean;
		function loaded():Number;
		function parseConfig(parse_xml:XML, parent_xml:XML = null):void;
/**
* Searches configuration for tag.
*
* @param tag String containing a TagType
* @param value String containing attribute value to serach for
* @param attribute String containing attribute name for value
* @param xml XML to search in
* @returns XML tag or null if not found
* @see MovieMasher
*/	
		function searchTag(tag:String, value:String = null, attribute:String = CommonWords.ID, xml:XML = null):XML;
		function searchTags(tag:String, value:String = null, attribute:String = CommonWords.ID, xml:XML = null):Array;
		function source(string:String):ISource;
	}
}