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
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.events.*;
	import com.moviemasher.manager.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	
/**
* Implementation class for data and file loading
*
* @see LoadManager
* @see MoviemasherStage
* @see MovieMasher
* @see IAssetFetcher
*/
	public class Fetcher extends EventDispatcher
	{
		public function Fetcher(iURL:URL)
		{
			__url = iURL;
			
			
			_state = (__url.server.length ? EventType.LOADING : EventType.LOADED);
			if (_state == EventType.LOADING)
			{
				__loadPolicy(__url);
			}
		}
		public function get key():String
		{ return __url.key; }
		
		public function get bytesTotal():Number
		{
			return __bytesTotal;
		}
		public function get bytesLoaded():Number
		{
			return __bytesLoaded;
		}
		public function set url(string:String):void
		{
			__url.url = string;
		}
		public function get urlObject():URL
		{ return __url; }


		public function get state():String
		{
			return _state;
		}
		private function __loadPolicy(url:URL):void
		{
			var absolute_url:String = url.absoluteURL;
			var n:int = absolute_url.length;
			
			for (var url_string:String in LoadManager.policies)
			{
				if (url_string == absolute_url.substr(0, url_string.length))
				{
					if (LoadManager.policies[url_string] != 'REQUESTED')
					{
						var policy_url:URL = LoadManager.policies[url_string];
						Security.loadPolicyFile(policy_url.absoluteURL);
						LoadManager.policies[url_string] = 'REQUESTED';
					}
					break;
				}
			}
		}
		
		
		
				
		protected function _loaderComplete(event:Event):void
		{
			try
			{
				if (event.target is IEventDispatcher)
				{
					_stopListening(event.target as IEventDispatcher);
				}
				_state = EventType.LOADED;
				dispatchEvent(new Event(Event.COMPLETE));	
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		protected function _reload():Boolean
		{
			return false;
		}
		private var __reloadCount:int = 3;// number of times we'll retry after a 504 error
		protected function __loaderError(event:IOErrorEvent):void
		{
			try
			{
				if (_httpStatus != 200) // not sure why we're getting 2124 error??
				{
					if ((_httpStatus != 504) || (! (__reloadCount--) ) || (! _reload() ) )
					{
						RunClass.MovieMasher['msg'](this + ' IO: ' + _httpStatus);
						if (event.target is IEventDispatcher)
						{
							_stopListening(event.target as IEventDispatcher);
						}
						_state = EventType.ERROR;
						dispatchEvent(new Event(Event.CHANGE));			
						dispatchEvent(new Event(Event.COMPLETE));
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		protected function __loaderSecurityError(event:SecurityErrorEvent):void
		{
			// not reported
		}
		protected function __loaderHTTPStatus(event:HTTPStatusEvent):void
		{
			_httpStatus = event.status;
		}
		protected function __loaderProgress(event:ProgressEvent):void
		{
			__bytesLoaded = event.bytesLoaded;
			__bytesTotal = event.bytesTotal;
			dispatchEvent(new Event(Event.CHANGE));			
		}
		
		protected function _startListening(listener:IEventDispatcher):void
		{
			listener.addEventListener(IOErrorEvent.IO_ERROR, __loaderError);
			listener.addEventListener(Event.COMPLETE, _loaderComplete);
			listener.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __loaderSecurityError);
			listener.addEventListener(HTTPStatusEvent.HTTP_STATUS, __loaderHTTPStatus);
			if (LoadManager.sharedInstance.hasEventListener(EventType.LOADED))
			{
				listener.addEventListener(ProgressEvent.PROGRESS, __loaderProgress);
			}
		}
		
		protected function _stopListening(listener:IEventDispatcher):void
		{
			listener.removeEventListener(IOErrorEvent.IO_ERROR, __loaderError);
			listener.removeEventListener(Event.COMPLETE, _loaderComplete);
			listener.removeEventListener(ProgressEvent.PROGRESS, __loaderProgress);
			listener.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, __loaderSecurityError);
			listener.removeEventListener(HTTPStatusEvent.HTTP_STATUS, __loaderHTTPStatus);
		}

		protected var __bytesLoaded:Number = 0;
		protected var __bytesTotal:Number = 0;
		protected var __url:URL;
		protected var _httpStatus:int;
		protected var _state:String;
	}
}