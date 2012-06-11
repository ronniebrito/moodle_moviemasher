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


package com.moviemasher.manager
{
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.manager.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;
	
/**
* Implementation class for fetching of all server side assets except XML
*
* @see IAssetFetcher
*/
	public class AssetFetcher extends Fetcher implements IAssetFetcher
	{
		public function AssetFetcher(iURL:URL)
		{
			super(iURL);
			__handlers = new Array();
			var handler_url_string:String;
			var format:String = __url.format;
			if (_state == EventType.LOADING)
			{
				__unloadable = (format != 'swf');
				if (__unloadable)
				{
					__unloadable = __url.isLoaderContent;
					if (! __unloadable)
					{
						
						handler_url_string = __handlerURL(format);
						__unloadable = Boolean(handler_url_string.length);
					}
				}
				if (__url.isLoaderContent)
				{
					__loadLoader();
				}
			}
		}
		public function classInstance(type:String = ''):Object
		{
			var ob:Object = null;
			var c:Class = classObject('',  type);
			if (c != null)
			{
				ob = new c();
			}
			
			return ob;
		}
		public function loader():Loader
		{
			return __loader;
		}
		public function unload(priority:Number):Boolean
		{
			var can_unload:Boolean = false;
			try
			{
				if (__retainCount < 1)
				{
					if (! __handlers.length)
					{
						can_unload = (priority > 75);
					}
					else
					{
						can_unload = (priority > 50);
					}
					
					if (can_unload && (__handlers.length))
					{
						for each (var i_handler:IHandler in __handlers)
						{
							if (i_handler == null) continue;
							if (i_handler.active)
							{
								can_unload = false;
								break;
							}
						}
					}
				}
				//else RunClass.MovieMasher['msg'](this + '.unload ' + __retainCount + ' ' + _state);
				if (can_unload)
				{
					__unload();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.unload', e);
			}
			return can_unload;
		}
		override public function toString():String
		{
			var s:String = '[AssetFetcher';
			if (__url != null) 
			{
				s += ' ' + __url.absoluteURL;
			}
			s += ']';
			return s;
		}
		public function retain():void
		{
			var key:int = 0;
			if (__retainCount < 0)
			{
				LoadManager.unpurgeSession(this);
				__retainCount = 0;
			}
			__retainCount++;
			if ((_state == EventType.LOADING) && (__retainCount > 1) && __url.isLoaderContent)
			{
				__loadLoader(__retainCount - 1);
			}
		}
		public function releaseDisplay(display:DisplayObject):void
		{
			__release();
		}
		public function releaseAudio(handler:IHandler):void
		{
			__release();
		}
		public function handlerObject(url:String = '', format:String = ''):IHandler
		{
			if (format.length)
			{
				__url.format = format;
			}
			if (url.length)
			{
				__url.url = url;
			}
				
			displayTime = (new Date()).getTime();
			var i_handler:IHandler = null;
			var handler_url_string:String;
			var c:Class;
										
			var z:uint = __handlers.length;
			var i:uint;
			for (i = 0; i < z; i++)
			{
				i_handler = __handlers[i];
				if (i_handler.active)
				{
					i_handler = null;
				}
				else
				{
					i_handler.active = true;
					break;
				}
			}
			try
			{
				if (i_handler == null)
				{
					handler_url_string = __handlerURL(__url.format);
					
					if (handler_url_string.length)
					{
						
						if (__handlerFetcher == null)
						{
							__handlerFetcher = RunClass.MovieMasher['assetFetcher'](handler_url_string, 'swf')
							
							if (__handlerFetcher.state == EventType.LOADING)
							{
								__handlerFetcher.addEventListener(Event.COMPLETE, _loaderComplete);
							}
						}
						
						if (__handlerFetcher != null)
						{
							if (__handlerFetcher.state != EventType.LOADING)
							{
								c = __handlerFetcher.classObject(handler_url_string, TagType.HANDLER);
								if (c != null)
								{
								
									i_handler = new c(__url.absoluteURL) as IHandler;
									
									if (i_handler != null)
									{
										_startListening(i_handler);
										__handlers.push(i_handler);
									}
								}
								else RunClass.MovieMasher['msg']('No class found for ' + handler_url_string);
							}
						}
						
					}
					else RunClass.MovieMasher['msg']('No handler found for ' + __url.format);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.handlerObject ' + i_handler, e);
			}
			return i_handler;					
		}
		public function classObject(url:String='', type:String=''):Class
		{
			__url.format = 'swf';
			if (url.length)
			{
				__url.url = url;
			}
			
			
			var c:Class = null;
			var definition:String = __url.definition;
			
			if (definition.length)
			{
				if ((type.length) && (definition.indexOf('.') == -1))
				{
					definition = 'com.moviemasher.' + type + '.' + definition;
				}
				if (ApplicationDomain.currentDomain.hasDefinition(definition))
				{
					c = ApplicationDomain.currentDomain.getDefinition(definition) as Class;
				}
				else if (__loader != null)
				{
					if (__loader.contentLoaderInfo.applicationDomain.hasDefinition(definition))
					{
						c = __loader.contentLoaderInfo.applicationDomain.getDefinition(definition) as Class;
					}
				}
			}
			return c;
		}
		public function displayObject(url:String, format:String = '', size:Size = null):DisplayObject
		{
			var display_object:DisplayObject = null;
			try
			{
				if (format.length)
				{
					__url.format = format;
				}
				if (url.length)
				{
					__url.url = url;
				}
				display_object = __displayObjectFromSWF(size);
				if (size == null)
				{
				
					if (display_object != null)
					{
						display_object = __displayBitmap(display_object);
					}
				}
				else
				{
					if ((! __url.definition.length) && (display_object != null))
					{
						var bm:Bitmap = __displayBitmap(display_object, size);
						if (bm != null)
						{
							display_object = bm;
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.displayObject ' + url, e);
			}
			return display_object;
		}
		public function fontObject(url:String = ''):Font
		{
			__url.format = 'swf';
			if (url.length)
			{
				__url.url = url;
			}
			var i_font:Font = null;
			var safe_key:String = __url.key + __url.definition;
			if (__fonts[safe_key] == null)
			{
				//
				__fonts[safe_key] = classInstance(TagType.FONT) as Font;
				if (__fonts[safe_key] != null)
				{
					try
					{
						Font.registerFont(classObject('', TagType.FONT));
					}
					catch (e:*)
					{
						RunClass.MovieMasher['msg'](this, e);
					}
					
					var option_tag:XML = RunClass.MovieMasher['searchTag'](TagType.OPTION, __url.url, 'url');
					if ((option_tag != null) && (String(option_tag.@antialias) == 'advanced'))
					{
						var children:XMLList = option_tag.children();
						for each(var tag:XML in children)
						{
							var myAntiAliasSettings = new CSMSettings(Number(tag.@size), Number(tag.@incut), -Number(tag.@outcut));
							var myAliasTable:Array = new Array(myAntiAliasSettings);
							TextRenderer.setAdvancedAntiAliasingTable(__fonts[safe_key].fontName, __fonts[safe_key].fontStyle, TextColorType.DARK_COLOR, myAliasTable);
							TextRenderer.setAdvancedAntiAliasingTable(__fonts[safe_key].fontName, __fonts[safe_key].fontStyle, TextColorType.LIGHT_COLOR, myAliasTable);
						}
					}
				}
			}
			i_font = __fonts[safe_key];
			return i_font;		
		}
		override protected function _reload():Boolean
		{
			__loadLoader();
			return true;
		}
		
		private function __createLoader(i:int):void
		{
			
			var loader:Loader = new Loader();
			
			__loader = loader;
			
			_startListening(loader.contentLoaderInfo);
			
		}
		private function __displayBitmap(iDisplayObject:DisplayObject, size:Size = null):Bitmap
		{
			var bm:Bitmap = null;
			try
			{
				var bitmap_data:BitmapData = null;
				iDisplayObject.scaleX = iDisplayObject.scaleY = 1;
				var display_size:Size = new Size(iDisplayObject.width, iDisplayObject.height);
				if (! display_size.isEmpty())
				{
					bm = new Bitmap();
					var scale:Size = __scaleSize(size, display_size);
					
					bitmap_data = new BitmapData(display_size.width * scale.width, display_size.height * scale.height, true, 0x00FFFFFF);
					
				
					iDisplayObject.scaleX = scale.width;
					iDisplayObject.scaleY = scale.height;
							
					var ob_parent:DisplayObjectContainer = iDisplayObject.parent;
					var no_parent:Boolean = (ob_parent == null);
					if (no_parent)
					{
						ob_parent = new Sprite();
						ob_parent.addChild(iDisplayObject);
					}
					bitmap_data.draw(iDisplayObject.parent);
					if (no_parent)
					{
						ob_parent.removeChild(iDisplayObject);
					}
					
					iDisplayObject.scaleX = iDisplayObject.scaleY = 1;
				}
				
				if (bitmap_data != null)
				{
					bm.bitmapData = bitmap_data;
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__displayBitmap', e);
			}
			return bm;
		}
		private function __displayObjectFromSWF(size:Size=null):DisplayObject
		{
			var display_object:DisplayObject = null;
			try
			{
				if (__url.definition.length) 
				{
					display_object = classInstance('display') as DisplayObject;
					if (display_object != null)
					{
						var display_size:Size = new Size(display_object.width, display_object.height);
						var scale:Size = __scaleSize(size, display_size);
					
						display_object.scaleX = scale.width;
						display_object.scaleY = scale.height;
					}
				}
				else if (__url.anchor.length)
				{
					if (__loader)
					{
						if (__url.format == 'swf')
						{
							var mc:MovieClip = __loader.content as MovieClip;
							if (mc != null)
							{
								mc.gotoAndStop(__url.anchor);
								display_object = mc;
							}
						}
					}
				}
				else
				{
					displayTime = (new Date()).getTime();
					display_object = __loader;
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__displayObjectFromSWF', e);
			}
			return display_object;
		}
		private function __handlerURL(format:String):String
		{
			var handler_url:String = '';
			var handler:XML;
			handler = RunClass.MovieMasher['searchTag'](TagType.HANDLER, format);
			if (handler == null) handler = RunClass.MovieMasher['searchTag'](TagType.HANDLER, '*');
			if (handler != null) handler_url = String(handler.@url);
			return handler_url;
			
		}
		private function __loadLoader(index:int = 0):void
		{
			
			_state = EventType.LOADING;
			if (__requestingSessions[this] == null)
			{
				__requestingSessions[this] = new Array();
				__queuedSessions.push(this);
				if (__requestingTimer == null)
				{
					__requestingTimer = new Timer(100);
					__requestingTimer.addEventListener(TimerEvent.TIMER, __requestingTimed);
					__requestingTimer.start();
				}
			}
			__requestingSessions[this].push(index);
		}
		private function __release():void
		{
			__retainCount--;
			if (__unloadable && (__retainCount == 0))
			{
				LoadManager.purgeSession(this);
				__retainCount = -1;
			}
			
		}
		private function __scaleSize(size:Size, display_size:Size):Size
		{
			var scale:Size = new Size(1,1);
			if (size != null)
			{
				var width_valid:Boolean = (size.width && (size.width != Infinity));
				var height_valid:Boolean = (size.height && (size.height != Infinity));
				if (width_valid)
				{
					scale.width = size.width / display_size.width;
				}
				if (height_valid)
				{
					scale.height = size.height / display_size.height;
				}
				if (! size.width)
				{
					scale.width = scale.height;
				}
				if (! size.height)
				{
					scale.height = scale.width;
				}
			}
			return scale;
		}
		private function __unload():void
		{
			try
			{
				if (__url != null) LoadManager.removeSession(this);
				var i:int = 0;
				var li:LoaderInfo;
				var i_handler:IHandler;
				if (__handlers != null)
				{
					for each (i_handler in __handlers)
					{
						if (i_handler == null) continue;
						_stopListening(i_handler);
						i_handler.destroy();
						
					}
					__handlers.length = 0;
				}
				if (__loader != null)
				{
					if ((__loader.parent != null))
					{
						__loader.parent.removeChild(__loader);
					}
					li = __loader.contentLoaderInfo;
					if (li != null)
					{
						_stopListening(li);
					}
					__loader.unload();
					__loader = null;
				}
				__url = null;
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__unload', e);
			}
		}
		private static function __requestContext(url:URL):LoaderContext
		{
			var domain:ApplicationDomain = ApplicationDomain.currentDomain;
			if (url.format == 'jpg')
			{
				domain = new ApplicationDomain(domain);
			}
			var loader_context:LoaderContext = new LoaderContext(false, domain);
			if (Security.sandboxType == Security.REMOTE)
			{
				loader_context.securityDomain = SecurityDomain.currentDomain;
			}
			
			return loader_context;
		}
		private static function __requestingTimed(event:TimerEvent):void
		{
			var app:IValued = RunClass.MovieMasher['getByID'](ReservedID.MOVIEMASHER) as IValued;
			var found_one:Boolean = false;
			var session:AssetFetcher;
			var url:URL;
			try
			{
				while (__queuedSessions.length)
				{
					found_one = true;
					session = __queuedSessions.shift();
					url = session.urlObject;
					if (url != null)
					{
						var indices:Array = __requestingSessions[session];
						var index:int;
						for each (index in indices)
						{
							if (session.__loader == null)
							{
								session.__createLoader(index);
								var url_string:String = url.absoluteURL;
								var context:LoaderContext = null;
								context = __requestContext(url);
								session.loader().load(new URLRequest(url_string), context);
							}
						}
					}
					if (__queuedSessions.indexOf(session) == -1)
					{
						delete __requestingSessions[session];
					}
					if (! ((app == null) || app.getValue('freetime').boolean))
					{
						break;
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](AssetFetcher + '.__requestingTimed', e);
			}
			if ((! found_one) && (__requestingTimer != null))
			{
				__requestingTimer.removeEventListener(TimerEvent.TIMER, __requestingTimed);
				__requestingTimer.stop();
				__requestingTimer = null;
			}
		}
		private static var __fonts:Object = new Object();
		private static var __queuedSessions:Array = new Array();
		private static var __requestingSessions:Dictionary = new Dictionary();
		private static var __requestingTimer:Timer;
		private var __handlerFetcher:IAssetFetcher;
		private var __handlers:Array;
		private var __loader:Loader;
		private var __retainCount:int = 0;
		private var __unloadable:Boolean = false;
		public var displayTime:Number = -1; // used by LoadManager to sort during purging
	}
}