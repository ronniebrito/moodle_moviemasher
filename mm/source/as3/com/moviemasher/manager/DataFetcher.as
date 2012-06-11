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
	import flash.events.*;
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
* Implementation class for fetching text based server side resources and CGI responses.
*
* @see IDataFetcher
*/
	public class DataFetcher extends Fetcher implements IDataFetcher
	{
		public function DataFetcher(iURL:URL, postData:*=null)
		{
			super(iURL);
			
			if (_state == EventType.LOADING)
			{
			
				var url_string:String = __url.absoluteURL;

				var request:URLRequest = new URLRequest(url_string);
				__loader = new URLLoader();
				if (postData != null)
				{
					request.method = URLRequestMethod.POST;
					if (postData is XML) 
					{
						request.contentType = 'text/xml';
						request.data = (postData as XML).toXMLString() + "\n";
					}
					else if (postData is String)
					{
						request.contentType = 'text/plain';
						request.data = String(postData) + "\n";
					}
					else if (postData is ByteArray)
					{
						request.contentType = 'application/octet-stream';
						request.data = (postData as ByteArray);
					
					}
				}
				else
				{
					request.method = URLRequestMethod.GET;
				}
				_startListening(__loader);
				__loader.load(request);
				
			}
		}
		public function xmlObject():XML
		{
			var xml_object:XML = null;
			var xml_str:String;
			try
			{
				
				xml_str = data();
				if (xml_str.length)
				{
					xml_object = new XML(xml_str);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + ' ' + xml_str, e);
			}
			return xml_object;	
		}
		public function data():String
		{
			var s:String = '';
			try
			{
				if (_state == EventType.LOADED)
				{
					s = __loader.data;
					LoadManager.removeSession(this);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			
			return s;
		}
		override public function toString():String
		{
			var s:String = '[DataFetcher';
			if (__url != null)
			{
				s += ' ' + __url.absoluteURL;
			}
			s += ']';
			return s;
		}
		private var __loader:URLLoader;
	}
}