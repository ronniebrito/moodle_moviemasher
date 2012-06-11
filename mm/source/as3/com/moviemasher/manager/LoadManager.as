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
* Implementation class for load manager
*
* @see MoviemasherStage
* @see ILoadManager
*/
	public class LoadManager extends Sprite implements ILoadManager
	{
		public function LoadManager()
		{
			// this should not be called directly - use LoadManager.sharedInstance
			
			__sessions = new Object();
			policies = new Dictionary();
			__purgeSessions = new Array();
			__purgeTimer = new Timer(3000);
			__purgeTimer.addEventListener(TimerEvent.TIMER, __purge);
			__purgeTimer.start();
		}
		public static function purgeSession(session:IAssetFetcher):void
		{
			__purgeSessions.push(session);
		}
		public static function unpurgeSession(session:IAssetFetcher):void
		{
			var index:int = __purgeSessions.indexOf(session);
			if (index != -1)
			{
				__purgeSessions.splice(index, 1);
			}
		}
		public function assetFetcher(iUrlString:String, format:String = ''):IAssetFetcher
		{
			var session:IAssetFetcher = null;
			if (iUrlString.length)
			{
				var url:URL = new URL(iUrlString, format);
				var url_key:String = url.key;
				session = __sessions[url_key];
				if (session == null)
				{
					session = new AssetFetcher(url);
				}
				__initFetcher(session, url_key, iUrlString);
			}
			return session;


		}
		public function dataFetcher(iUrlString:String, postData:*=null):IDataFetcher
		{
			var session:IDataFetcher = null;
			if (iUrlString.length)
			{
				var url:URL = new URL(iUrlString, 'xml');
				var url_key:String = url.key;
				session = __sessions[url_key];
				if (session == null)
				{
					session = new DataFetcher(url, postData);
				}
				__initFetcher(session, url_key, iUrlString);
			}
			return session;
		}
		public function getValue(property:String):Value
		{
			var value:Value;
			var k:String;
			var fetcher:IFetcher;
			var total:Number = 0;
			var loaded:Number = 0;
			var fetcher_total:Number = 0;
			switch(property)
			{
				case EventType.LOADING:
				
					for(k in __sessions)
					{
						fetcher = __sessions[k];
						total++;
						if (fetcher.state != EventType.LOADING)
						{
							loaded ++;
						}
					}
					if (total) loaded = 100 - Math.ceil((loaded / total) * 100);
					value = new Value(loaded);
					break;
				
				case EventType.LOADED:
					
					for(k in __sessions)
					{
						fetcher = __sessions[k];
						if (fetcher.state == EventType.LOADING)
						{
							fetcher_total = fetcher.bytesTotal;
							if (fetcher_total)
							{
								total += fetcher_total
								loaded += fetcher.bytesLoaded;
							}
						}
					}
					if (total) loaded /= total;
					value = new Value(loaded * 100);
					break;
				default:
					value = new Value('');
			}
			return value;
		}
	
		public static function removeSession(session:IFetcher):void
		{
			var key:String = session.key;
			__sessions[key] = null;
			delete __sessions[key];
		}
		public function addPolicy(iURL:String):void
		{
			if (iURL.length)
			{
				var url:URL = new URL(iURL);
				
				var absolute_url:String = url.absoluteURL;
				if (absolute_url.length)
				{
					absolute_url = absolute_url.substr(0, - (url.file.length + url.extension.length + 1));
					policies[absolute_url] = url;
					Security.loadPolicyFile(url.absoluteURL);
				}
			}
		}
		private function __initFetcher(session:IFetcher, url_key:String, iUrlString:String, format:String = null):void
		{
			if (__sessions[url_key] == null)
			{
				__sessions[url_key] = session;
				if (sharedInstance.hasEventListener(EventType.LOADED) || sharedInstance.hasEventListener(EventType.LOADING))
				{		
					session.addEventListener(Event.CHANGE, __sessionChange);
				}
				session.addEventListener(Event.COMPLETE, __sessionChange);
			}
			else session.url = iUrlString;
		}
		private function __purge(event:TimerEvent):void
		{
			try
			{
				if (__purgingTimer == null)
				{
					if (__purgeSessions.length)
					{
						__purgingTimer = new Timer(1000);
						__purgingTimer.addEventListener(TimerEvent.TIMER, __purgeTimed);
						__purgingTimer.start();
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __purgeTimed(event:TimerEvent):void
		{
			try
			{
				var app:IValued = RunClass.MovieMasher['getByID'](ReservedID.MOVIEMASHER) as IValued;
				if (app != null)
				{
					var session:IAssetFetcher;
					__purgeSessions.sortOn('displayTime');
					
					var z:uint = __purgeSessions.length;
					var orig_z:uint = z;
					var time_left:Boolean = true;
					var url:String;
					var mem:Number = app.getValue('memory').number;
					while (z-- && time_left)
					{
						
						session = __purgeSessions.shift();
						if (session != null)
						{
							if (! session.unload(mem))
							{
								__purgeSessions.push(session);
							}
						}
						time_left = app.getValue('freetime').boolean;
					}
					z = __purgeSessions.length;
					if ((! z) || ((orig_z == z) && time_left))
					{
						if (__purgingTimer != null)
						{
							__purgingTimer.removeEventListener(TimerEvent.TIMER, __purgeTimed);
							__purgingTimer.stop();
							__purgingTimer = null;
						}
					}
					System.gc();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
				__purgeSessions = new Array();
			}
		}
		private static function __preloadingTimed(event:Event):void
		{
			if (__loadingPercent == 0)
			{

				sharedInstance.dispatchEvent(new ChangeEvent(new Value(__loadingPercent), EventType.LOADING));
			}
			__loadingTimer.stop();
			__loadingTimer.removeEventListener(TimerEvent.TIMER, __preloading);
			__loadingTimer = null;
		}
		private static function __preloading():void
		{
			var percent:int = sharedInstance.getValue(EventType.LOADING).number;
			var done:Number = 0.0;
			var step:Number = 1.0;
			var n:Number;
			if (__loadingPercent != percent)
			{
				__loadingPercent = percent;
				if (percent == 0)
				{
					__preloadingCount++;
					if (__preloadingCount < 3)
					{
						percent = 100; // we are now just starting the next step
						
						if (__preloadingCount == 2)
						{
							// configuration, interface elements and sources have been loaded
							if (__loadingTimer == null)
							{
								// start timer to see if additional requests are made in the next second
								__loadingTimer = new Timer(1000);
								__loadingTimer.addEventListener(TimerEvent.TIMER, __preloadingTimed);
								__loadingTimer.start();
							}
						}
					}
				}
				switch(__preloadingCount)
				{
					case 0: // loading XML config and SWFs in 'symbol' attributes
						step = .2;
						break;
					case 1: // loading SWFs and graphics referenced in panels
						step = .3;
						done = .3;
						break;
					case 2: // possibly loading icons for browser/timeline and frame one of player
						step = .3;
						done = .7;
						break;
					
				}
				n = (100 - percent) / 100;
				percent = 100 - Math.round(100 * (done + (n * step)));
				
				sharedInstance.dispatchEvent(new ChangeEvent(new Value(percent), EventType.LOADING));
				
			}
		}
		private static function __sessionChange(event:Event):void
		{
			var session:IFetcher = event.target as IFetcher;
			try
			{
				if (session.state != EventType.LOADING)
				{
					session.removeEventListener(Event.CHANGE, __sessionChange);
					session.removeEventListener(Event.COMPLETE, __sessionChange);
				}
				if (sharedInstance.hasEventListener(EventType.LOADED))
				{
					var value:Value;
					value = sharedInstance.getValue(EventType.LOADED)

					sharedInstance.dispatchEvent(new ChangeEvent(value, EventType.LOADED));
				}
				if (sharedInstance.hasEventListener(EventType.LOADING))
				{
					__preloading();
				}
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](LoadManager, e);
			}
		}
		private static var __bytesTotal:Number = 0;
		private static var __loadingPercent:int = 0;
		private static var __loadingTimer:Timer;
		private static var __needsAssetFetcher:AssetFetcher;
		private static var __needsDataFetcher:DataFetcher;
		private static var __preloadingCount:int = 0;
		private static var __purgeSessions:Array;
		private static var __purgeTimer:Timer;
		private static var __sessions:Object;
		private var __purgingTimer:Timer;
		public static var policies:Dictionary; // accessed by Fetcher
		public static var sharedInstance:LoadManager = new LoadManager();
		
		
	}
}

		