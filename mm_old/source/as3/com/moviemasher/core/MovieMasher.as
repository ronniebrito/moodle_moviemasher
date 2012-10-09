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

package com.moviemasher.core
{
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import flash.display.*;
	import flash.events.*;
	import flash.external.*;
	import flash.geom.*;
/**
* Singleton class represents the main application, facilitating the loading and interpretting of
* resources. Most static methods are proxies for one of three low level managers responsible for 
* configuration parsing, stage event handling and resource loading. Other static methods provide 
* a global addressing space similar to a DOM and a facility for interacting and manipulating objects within it. 
* 
* @see MoviemasherStage
* @see IConfigManager
* @see IStageManager
* @see ILoadManager
* @see RunClass

*/
	public class MovieMasher extends Sprite
	{
				
		public function MovieMasher()
		{ 
			instance = this; 
		}
/**
* Retrieves fetcher for asset url, creating a new one if needed. Successive calls to this method with the
* same url will return the same fetcher, as long as it hasn't yet been purged. In the case of SWF assets  
* only one fetcher is created per file, even if the appended frame labels or class names differ.
* @param url String containing location of asset. May be appended by the # symbol and a frame
* label to reference graphics on the main timeline of an SWF file, or by the @ symbol and a class
* name to reference a class within the file. In many cases, a class name needn't
* be fully qualified if under the com.moviemasher package hierarchy (eg. com.moviemasher.font.*). 
* @param format String containing file extension override. Useful for forcing a particular {@link IHandler} 
* to be used when playing back audio or video assets (eg. 'flv' forces video handling of
* any file playable by Flash, regardless of extension). If empty, the
* file extension of the location portion of the url parameter will be used. 
* @returns {@link IAssetFetcher} associated with url.
*/
		public static function assetFetcher(url:String, format:String = ''):IAssetFetcher
		{ 
			return __loadManager.assetFetcher(url, format); 
		}
/** Retrieves fetcher for data url, which may have already been retrieved. Successive calls to 
* this method with the same url will return
* the same fetcher until its {@link IDataFetcher.data} or {@link IDataFetcher.xml} method is 
* successfully called, even if the postData differs. 
* @param url String location of data to retrieve.
* @param postData * pointer to a String, XML or URLVariables object to include in request or null. Will be ignored if 
* this call returns a previously returned fetcher.

* @returns IDataFetcher associated with url.
*/
		public static function dataFetcher(url:String, postData:*=null):IDataFetcher
		{
			return __loadManager.dataFetcher(url, postData);
		}
/** Causes expressions to be parsed and interpreted within the global object space, returning the result. 
* @param expressions * pointer to an Array of String expressions or a String of expressions delimited by commas. 
* Each expression is generally in the form of OBJECTNAME.PROPERTY=VALUE to set a value and just OBJECTNAME.PROPERTY
* to return one. If an expression starts with '&lt;' then it's assumed to contain mash XML which is loaded into the 
* {@link Player} control. 
* @param values Object to search for values in. If the VALUE portion of a setting expression is also
* a key in values then it will be replaced by the corresponding value before setting the property.
* @returns String result of setting the property or its value.
*/
		public static function evaluate(expressions:*, values:Object = null):String
		{
			var results:Array = new Array();
			
			var a:Array;
			var expression:String;
			if (expressions is Array)
			{
				a = expressions;
			}
			else
			{
				expression = expressions;
				if (expression.substr(0, 1) == '<')
				{
					a = [expression];
				}
				else a = expression.split(getOption('parse', 'evaluate_delimiter'));
			}
			var i, z:int;
			z = a.length;
			var equal_bits:Array;
			var value:String;
			var bits:Array;
			var property:String;
			
			for (i = 0; i < z; i++)
			{
				expression = a[i];
				if (expression.substr(0, 1) == '<')
				{
					results.push(__evaluateProperty('player', 'source', expression));
				}
				else
				{
					
					equal_bits = expression.split('=');
					expression = equal_bits[0];
					value = null;
					bits = expression.split('.');
					property = bits.pop();
					expression = bits.join('.');
					if (equal_bits.length > 1) 
					{
						value = equal_bits[1];
						if (value.length) value = RunClass.ParseUtility['brackets'](value);
					}
					else if (values != null)
					{
						if (values[property] != null) value = values[property];
						else if (values[CGIProperty.VALUE] != null) value = values[CGIProperty.VALUE];
					}
					
					results.push(__evaluateProperty(expression, property, value));
				}
			}
			
			return results.join(',');
			
		}
/** Retrieves the option tag with type equal to 'font' and having a particular id attribute.
* @param font String to search for in id attribute values.
* @param mash * pointer to an XML or IMash object to search for tags in if not found in main configuration or null.
* @returns XML option tag matching specifications or null if none found.
*/
		public static function fontTag(font:String, mash:* = null):XML
		{ 
			return __configManager.fontTag(font, mash); 
		}
/** Retrieves an object by id from the global object space previously set by the setByID method.
* @param id String previously sent to setByID method. If equal to 'parent' the DisplayObjectContainer
* just above MovieMasherStage will be returned. 
* @returns Object corresponding to id or null if not found. 
*/
		public static function getByID(id:String):Object
		{
			var ob:Object = null;
			var a:Array = id.split('.');
			var z:uint = a.length;
			if (z > 0)
			{
				ob = objects[a[0]];
				if (ob == null)
				{
					ob = getOption(ReservedID.MOVIEMASHER, id);
					if (! ob.length) 
					{
						if (a[0] == 'parent')
						{
							ob = instance.parent.parent.parent;
						}
						else ob = null;
					}
				}
				for (var i:uint = 1; (ob != null) && (i < z); i++)
				{
					ob = ob.getValue(a[i]).object;
				}
			}
			return ob;
		}
/** Retrieves the value of an attribute for the first option tag in configuration having a certain type attribute.
* @param type String to search for in type attribute values.
* @param attribute String name of value to return.
* @returns String value of attribute or empty string if not found.
*/
		public static function getOption(type:String, attribute:String):String
		{
			
			var x:XML = getOptionXML(type, attribute);
			
			return x.@[attribute];
			
		}
/** Coerces string return by getOption method to Number.
* @param type String to search for in type attribute values.
* @param attribute String name of value to return.
* @returns Number value for attribute or zero if not found or NaN.
*/
		public static function getOptionNumber(type:String, attribute:String):Number
		{
			var n:Number = 0;
			var s:String = getOption(type, attribute);
			if (s.length) 
			{
				n = Number(s);
				if (isNaN(n)) n = 0;
			}
			return n;
		}
/** Retrieves option tag from configuration having a certain type attribute, creating if needed.
* @param type String to search for in type attribute values.
* @param attribute String to make sure has a value in tag before returning or null to return first tag.
* @returns XML object matching specifications.
*/
		public static function getOptionXML(type:String, attribute:String = null):XML
		{
			return __configManager.getOptionXML(type, attribute);
		}
/** Retrieves a value from the loaderInfo.parameters of the root SWF.
* @param property String name of parameter to retrieve. The special value of 'appletbase' returns 
* the base URL to the moviemasher/com/moviemasher directory. 
* @returns String value of parameter or empty string if not found.
*/
		public static function getParameter(property:String):String
		{ 
			return __stageManager.getParameter(property); 
		}
/** Fetch and parse XML for configuration, putting any unparsed tags into container.
* @param url String location to request.
* @param container XML to place unparsed tags into. If null, unparsed tags will be ignored. 
* @returns Boolean
*/
		public static function loadConfiguration(url:String, container:XML = null):Boolean
		{ 
			return __configManager.loadConfiguration(url, container); 
		}
/** Adds a string message to the debugging output that may be visible behind the applet. During rendering 
* this method will cause a Exception to be raised if type equals {@link EventType.ERROR} or is an 
* object descending from the Error class.
* @param s * pointer to anything coercible to a String.
* @param type * pointer to a String representing the message type or an Error object.
*/
		public static function msg(s:*, type:* = null):void
		{ 
			if (__stageManager != null)
			{
				__stageManager.msg(s, type); 
			}
		}
/** Interpret xml as configuration, placing any unparsed tags into parent.
* @param xml XML to parse as configuration.
* @param parent XML object to place unparsed tags into or null to ignore them.
*/
		public static function parseConfig(xml:XML, parent:XML = null):void
		{
			__configManager.parseConfig(xml, parent);
			__configManagerLoading(new Event(EventType.LOADING));
		}
/** Retrieve a source object corresponding to a url or id, creating if needed. 
* @param string String containing url or id for source.
* @returns ISource 
*/
		public static function source(string:String):ISource
		{
			return __configManager.source(string);
		}
/**
* Searches XML for the first tag having an attribute matching a value. If tag equals {@link TagType.SOURCE}
* and name equals {@link CommonWords.ID} and the tag is not found, it will be created and returned.
* @param tag String containing the {@link TagType} of the tag to search for.
* @param value String containing the value to search for. 
* @param name String containing the attribute that value must match in order for tag to be included.
* @param xml XML to search or null to search through main configuration.
* @returns XML object matching search criteria or null if it wasn't found.
*/
		public static function searchTag(tag:String, value:String = null, name:String = CommonWords.ID, search:XML = null):XML
		{
			return __configManager.searchTag(tag, value, name, search);
		}
/**
* Searches XML for tags having an attribute matching a value. 
* @param tag String containing the {@link TagType} of the tag to search for.
* @param value String containing the value to search for. 
* @param name String containing the attribute that value must match in order for tag to be included.
* @param xml XML to search or null to search through main configuration.
* @returns Array of XML objects matching search criteria or an empty Array if none were found.
*/
		public static function searchTags(tag:String, value:String = null, name:String = CommonWords.ID, xml:XML = null):Array
		{ 
			return __configManager.searchTags(tag, value, name, xml); 
		}
/** Places object into the global object space so it's retrievable by id later using the getByID method.
* @param id String suitable for use as an object key. Should not be one of the {@link ReservedID} constants.
* @param object Object to retrieve later.
*/
		public static function setByID(id:String, object:Object):void
		{
			objects[id] = object;
		}
/** Install a mouse tracking cursor or remove one previously installed, adjusting visibility of true cursor.
* @param display DisplayObject to use as cursor or null to remove any previously installed one. 
* @param offset Point indicating how far from current mouse position to place display.
*/
		public static function setCursor(display:DisplayObject = null, offset:Point = null):void
		{
			__stageManager.setCursor(display, offset);
		}
/** Install a mouse tracking tooltip for a control or remove a previously installed one. 
* @param tooltip ITooltip to install or null to remove any previously installed one.
* @param control IControl that owns the tooltip. Its updateTooltip method will be called while the tooltip is active.
*/
		public static function setTooltip(tooltip:ITooltip=null, control:IControl=null):void
		{
			__stageManager.setTooltip(tooltip, control);
		}
/* Please do not call this method. */
		public function setManagers(iLoadManager:ILoadManager, iConfigManager:IConfigManager, iStageManager:IStageManager):void
		{
			__loadManager = iLoadManager;
			__configManager = iConfigManager;
			__stageManager = iStageManager;
			
			setByID(ReservedID.LOADER, __loadManager);
			
			__stageManager.addEventListener(FullScreenEvent.FULL_SCREEN, __fullscreenedStage);
			__stageManager.addEventListener(Event.RESIZE, __resizedStage);
			__resizedStage(null);
			
			var policy:String = getParameter('policy');
			
			if (policy.length)
			{
				__loadManager.addPolicy(policy);
			}
			
			__configManager.addEventListener(EventType.LOADING, __configManagerLoading);
			var url:String = getParameter('preloader');
			if (url.length)
			{
				var loader:IAssetFetcher = assetFetcher(url) as IAssetFetcher;
				if (loader.state == EventType.LOADING)
				{
					loader.addEventListener(Event.COMPLETE, __preloaderLoaded);
				}
			}
			url = getParameter('config');
			if (url.length)
			{
				loadConfiguration(url);
			}
			
			var do_evaluate:String = getParameter('evaluate');
			if (do_evaluate == '1')
			{
				if (ExternalInterface.available) ExternalInterface.addCallback('evaluate', evaluate);
			}
		}
		override public function get width():Number
		{ 
			return __stageManager.size.width; 
		}
		override public function get height():Number
		{ 
			return __stageManager.size.height; 
		}
/** Set overall dimensions of interface.
* @param w Number  
* @param h Number 
*/
		public static function setSize(w:Number, h:Number):void
		{
			__stageManager.size = new Size(w, h);
			instance.__resizedStage(new Event(Event.RESIZE));
		}
/**
* The singleton instance of this class.
*/
		public static var instance:MovieMasher;
/**
* The global object space, keyed by ID.
*/
		public static var objects:Object = new Object();
		private function __resizedStage(event:Event):void
		{
			try
			{
				
				if (__preloader != null)
				{
					if (__preloader.content is IPreloader)
					{
						var preloader:IPreloader = __preloader.content as IPreloader;
						preloader.metrics = new Size(width, height);
						
					}
					else
					{
						__preloader.x = Math.round((width - __preloader.width) / 2);
						__preloader.y = Math.round((height - __preloader.height) / 2);
						__preloader.visible =  ! ((__preloader.x < 0) || (__preloader.y < 0));
					}
				}
			}
			catch(e:*)
			{
				//msg('MovieMasher.__resizedStage', e);
			}
			if (event != null) dispatchEvent(event);
		}
		private function __fullscreenedStage(event:Event):void
		{
			dispatchEvent(event);
		}
		private static function __configManagerLoading(event:Event):void
		{
			var completed:Number = __configManager.loaded();
			if ((completed > 0) && (__preloader != null) && (__preloader.content is IPreloader))
			{
				var preloader:IPreloader = __preloader.content as IPreloader;
				preloader.preloaded = completed / 2;
			}
			if (completed == 1) 
			{
				__configManager.removeEventListener(EventType.LOADING, __configManagerLoading);
			
				__loaded = 1;
				var player:IPropertied = getByID(ReservedID.MOVIEMASHER) as IPropertied;
				if (player != null)
				{
					player.addEventListener(EventType.LOADING, __playerLoading);
				}
				
				instance.dispatchEvent(new Event(EventType.LOADED));
			}
			else
			{
				instance.dispatchEvent(event);
			}
		}
		private static function __evaluateProperty(expression:String, property:String, value:String):String
		{
			var result:String = '';
			try
			{
				var object:Object = null;
				var target:IValued = null;
				var propertied:IPropertied;
				object = getByID(expression);
				if (object != null)
				{
					if (object is IValued) 
					{
						target = object as IValued;
						
						if (value == null) result = (target.getValue(property).string);
						else
						{
							if (property == 'event')
							{
								target.dispatchEvent(new Event(value, true));
							}
							else
							{
								propertied = target as IPropertied;
								if (propertied)
								{
									result = (propertied.setValue(new Value(value), property) ? '1' : '0');
								}
							}
						}
					}
					else 
					{
						while ((object != null) && (! object.hasOwnProperty(property)) && object.hasOwnProperty('parent'))
						{
							object = object['parent'];
						}
						
						if ((object != null) && object.hasOwnProperty(property))
						{
							if (object[property] is Function)
							{
								result = object[property](value);
							}
							else 
							{
								RunClass.MovieMasher['msg'](expression + '.' + property + ' is not a function', 'debug');
							
								object[property] = value;
								result = '1';
							}
						}
						else
						{
							result = expression + '.' + property + ' is null';
							RunClass.MovieMasher['msg'](result, 'debug');
						}
					}
				}
				else 
				{
					result = expression + ' not found';
					RunClass.MovieMasher['msg'](result, 'debug');
				}
							
			}
			catch(e:*)
			{
				result = String(e);
				RunClass.MovieMasher['msg'](result, 'debug');
			}
			return result;
		}
		private static function __playerLoading(event:Event)
		{
			var player:IPropertied = getByID(ReservedID.MOVIEMASHER) as IPropertied;
			if (player != null)
			{
				var completed:Number = player.getValue(EventType.LOADED).number;
				if ((completed > 0) && (__preloader != null) && (__preloader.content is IPreloader))
				{
					var preloader:IPreloader = __preloader.content as IPreloader;
					preloader.preloaded = .5 + (completed / 2);
				}
				
				if (completed == 1) 
				{
					__loaded = 2;
					if (__preloader != null)
					{
						instance.removeChild(__preloader);
					}
					__stageManager.initialize();
				}
			}
		}
		private static function __preloaderLoaded(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, __preloaderLoaded);
			if (__loaded < 2)
			{
				var i_loader:IAssetFetcher = event.target as IAssetFetcher;
				if (i_loader != null)
				{
					var loader:Loader = i_loader.loader();
					if (loader != null)
					{
						instance.addChild(loader);
						__preloader = loader;
						instance.__resizedStage(null);
					}
				}
			}
		}
		private static var __configManager:IConfigManager;
		private static var __loaded:uint = 0;
		private static var __loadManager:ILoadManager;
		private static var __preloader:Loader;
		private static var __stageManager:IStageManager;
	}
}

