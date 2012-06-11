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
package com.moviemasher.source
{
	
	import com.moviemasher.interfaces.*;
	import flash.utils.*;
	import flash.events.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;

/**
* Class allows conditional searching of paged tags from remote cgi
*
* @see Player
* @see Browser
*/
	public class RemoteSource extends Source
	{
		public function RemoteSource()
		{
			super();
			_termsKey = 'terms';
			
		}
		override public function getValue(property:String):Value
		{
			var value:Value;
			switch(property)
			{
				case 'count':
				case _countKey:
					value = new Value(_count);
					break;
				case 'index':
				case _indexKey:
					value = new Value(_index + _indexStart);
					break;
				default:
					value = super.getValue(property);
			}
			return value;
		}
		
		protected function _parsedURL():String
		{
			var url:String = RunClass.ParseUtility['brackets'](getValue('url').string, this);
			if (url.indexOf('{') != -1)
			{
				url = RunClass.ParseUtility['brackets'](url, RunClass.MovieMasher['getByID']('parameters'));
			}
			if (url.indexOf('{') != -1)
			{
				url = RunClass.ParseUtility['brackets'](url);
			}
			url= url + '&cmid=' +  RunClass.MovieMasher['instance'].loaderInfo.parameters['cmid'];
			//trace('a url é'+ url);
			return url;
		}
		override protected function _gettingLastItem():void
		{
			// asking for last item in items
			if (! _requesting)
			{
				_index += _count;
				__initRequest();
			}
		}
		override protected function _search():void
		{
			if (! _requesting)
			{
				__resetRequest();
			}
		}
		
		protected function _searchArgs(args:Object, ignore:Array = null):Object
		{
			var k:String;
			
			var result:Object = null;
			if (_count < 1) RunClass.MovieMasher['msg'](this + ' requires the ' + _countKey + ' attribute to be greater than zero');
			else
			{
			
				if (args == null) result = new Object();
				else result = args;
				
				if (result[_countKey] == null) result[_countKey] = String(_count); 
				if (result[_indexKey] == null) result[_indexKey] = String(_index + _indexStart);
				
				
				if (result[_termsKey] == null)
				{
					k = getValue(_termsKey).string;
					if (k.length) result[_termsKey] = k;
				}
				if (result[_sortKey] == null)
				{
					k = getValue(_sortKey).string;
					if (k.length) result[_sortKey] = k;
				}
				
				for (k in _attributes)
				{
					if (result[k] != null) continue;
					switch (k)
					{
						case 'terms':
						case _termsKey:
						case 'sort':
						case _sortKey:
						case 'index':
						case _indexKey:
						case 'count':
						case _countKey:
						case 'id':
						case 'symbol':
						case 'config':
						case 'url':
							break;
						default:
							if ((ignore == null) || (ignore.indexOf(k) == -1))
							{
								result[k] = getValue(k).string;
							}
					}
				}
			}
			return result;
		}



		protected var _loader:IDataFetcher;
		protected function _makeRequest():void
		{
			var parsed:String = _parsedURL();
			if ((parsed != null) && parsed.length)
			{
				
				_loader = RunClass.MovieMasher['dataFetcher'](parsed);
				_loader.addEventListener(Event.COMPLETE, __urlLoad);
			}
		}
		private function __initRequest():void
		{
			_requesting = true;
			if (__requestTimer == null)
			{
				__requestTimer = new Timer(1000, 1);
				__requestTimer.addEventListener(TimerEvent.TIMER, __requestURLTimed, false, 0, true);
				__requestTimer.start();
			}
				
		}
		private function __requestURLTimed(event:TimerEvent):void
		{
			try
			{
				if (__requestTimer != null)
				{
					__requestTimer.removeEventListener(TimerEvent.TIMER, __requestURLTimed);
					__requestTimer.stop();
					__requestTimer = null;
				}
				_makeRequest();
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __resetRequest():void
		{
			_searchInvalid = false;
			_index = 0;
			_more = true;
			items = new Array();
			__initRequest();
		}
		override protected function _parseTag():void
		{
			if (_defaults[_countKey] == null) 
			{
				_defaults[_countKey] = '20';	
			}
			super._parseTag();
			
			var value:Number = super.getValue(_countKey).number;
			if (value > 0)
			{
				_count = value;
			}
			//else RunClass.MovieMasher['msg'](this + '._parseTag with ' + _countKey + ' = ' + value);
			
		}

		protected function _loadItemsFromData(data:String):void
		{
			var list_xml:XML;
				
			var xml_list:XMLList;
			var tag:XML;
			var did_add:Boolean = false;
			var count:int = _count;
			
			try
			{
				list_xml = new XML(data);
				xml_list = list_xml.children();
				
				for each (tag in xml_list)
				{
					count --;

					if (_addResultIfUnique(tag, true))
					{
						did_add = true;
					}
				}
				_more = ! count;
				if (did_add) _itemsDidChange();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
				_more = false;
			}
		}
		private function __urlLoad(event:Event):void
		{
			try
			{
				_requesting = false;
				_loader.removeEventListener(Event.COMPLETE, __urlLoad);
				var data:String = _loader.data();
				if (data != null)
				{
					if (_searchInvalid)
					{
						// parameters changed since we requested, ignore result
						__resetRequest();
					}
					else
					{
						_loadItemsFromData(data);
						
					}
					_loader = null;
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}				
		}
		
		protected var _requesting:Boolean = false;
		private var __requestTimer:Timer = null;
		protected var _index:Number = -1;
		protected var _indexStart:int = 0;
		protected var _count:int = -1;
		protected var _countKey:String = 'count';
		protected var _indexKey:String = 'index';
		
	}
}

		