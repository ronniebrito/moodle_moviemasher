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
	import com.moviemasher.type.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.constant.*;
	import flash.events.*;
	import com.moviemasher.events.*;
/**
* Base class for conditional searching of source tags
*
* @see Player
* @see Browser
*/
	public class Source extends Propertied implements ISource
	{
		public static function getByID(id:String):XML
		{
			var xml_item:XML;
			var item_xml:XML;
			var xml_list:XMLList;
			try
			{
				for each (var isource:ISource in __sources)
				{
					for each (var item:* in isource.items)
					{
						if ( ! (item is XML)) break;
						item_xml = (item as XML);
						if (String(item_xml.@id) == id)
						{
							xml_item = item_xml;
							break;
						}
						xml_list = item_xml.media;
						if (xml_list.length())
						{
							xml_list = xml_list.(attribute(CommonWords.ID) == id);
							if (xml_list.length())
							{
								xml_item = xml_list[0];
							}
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](Source, e);
			}
		
			return xml_item;
			
		}
		private static var __sources : Array = new Array(); 
		public function Source()
		{
			__sources.push(this);
			__items = new Array();
			
		}
		final public function getResultAt(index:Number):XML
		{
			var x:XML = null;
			try
			{
				var ob:* = getItemAt(index);
				if ((ob != null) && (ob is XML)) x = (ob as XML);
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return x;
		}
		final public function getItemAt(index:Number):*
		{
			try
			{
				if (! __active) __activate();
				if (_more && ((index + 1) == __length))
				{
					_gettingLastItem();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return __items[index];
		}
		final public function get items():Array
		{
			return __items;
		}
		final public function set items(array:Array):void
		{
			if (__items != array)
			{
				__items = array;
				_itemsDidChange();
			}
		}
		final public function get length() : uint 
		{ 
			return __length; 
		}
		final protected function _addResultIfUnique(item_xml:XML, dont_dispatch:Boolean = false):Boolean
		{
			var did_add:Boolean = false;
			var i: uint;
			var z:uint;
			var id:String = String(item_xml.@id);
			if (id.length)
			{
				did_add = true;
				z = __items.length;
				for (i = 0; i < z; i++)
				{
					if (__items[i] is XML)
					{
						if (__items[i].@id == id)
						{
							did_add = false;
							break;
						}
					}
				}
				if (did_add)
				{
					__items.push(item_xml);
					if (! dont_dispatch)
					{
						_itemsDidChange();
					}
				}
			}
			return did_add;
			
		}
		final protected function _itemsDidChange():void
		{
			__length = __items.length;
			dispatchEvent(new Event(Event.CHANGE));
		}
		final protected function _xmlSort(a:XML, b:XML):Number
		{
			var a_value:String = String(a.@[_sort]);
			return a_value.localeCompare(String(b.@[_sort]));
		}
		override public function getValue(property:String):Value
		{
			var value:Value;
			switch(property)
			{
				case 'terms':
				case _termsKey:
					value = new Value(_terms);
					break;
				case 'sort':
				case _sortKey:
					value = new Value(_sort);
					break;
				case 'length':
					if (! __active) __activate();
					value = new Value(__length);
					break;
				default:
					value = super.getValue(property);
			}
			return value;
		}
		override public function setValue(value:Value, property:String):Boolean
		{
			_searchInvalid = true;
			var set_super:Boolean = true;
			var change_properties:Array = new Array();
			var k:String;
			change_properties.push(property);
					
			switch(property)
			{
				case 'terms':
					change_properties.push(_termsKey);
					// intentional fallthrough to _termsKey
				case _termsKey:
					_terms = value.string;
					set_super = false;
					break;
				case 'sort':
					change_properties.push(_sortKey);
					// intentional fallthrough to _sortKey
				case _sortKey:
					_sort = value.string;
					set_super = false;
					break;
				default: // otherwise, clear the search terms
					change_properties.push(_termsKey);
					_terms = '';					
			}
			if (set_super) 
			{
				super.setValue(value, property);
			}
			for each (k in change_properties)
			{
				dispatchEvent(new ChangeEvent(getValue(k), k));
			}
			__parametersDidChange();
			return false;
		}
		override protected function _parseTag():void
		{
			if (_defaults[_termsKey] == null) _defaults[_termsKey] = '';	
			if (_defaults[_sortKey] == null) _defaults[_sortKey] = '';	

			super._parseTag();
			
			var value:Value;
			value = getValue(_sortKey);
			if (! value.empty)
			{
				_sort = value.string;
			}
			value = getValue(_termsKey);
			if (! value.empty)
			{
				_terms = value.string;
			}
		}
		private function __activate():void
		{
			__active = true;
			if (_searchInvalid) __parametersDidChange();
		}
		private function __parametersDidChange():void
		{
			if (__active)
			{
				_search();
			}
		}
		protected function _gettingLastItem():void
		{ }
		protected function _search():void
		{ }
		protected var _sort:String = '';
		protected var _terms:String = '';
		protected var _more:Boolean = false;
		protected var _searchInvalid:Boolean = true;
		private var __active:Boolean = false;
		private var __items:Array;
		private var __length:uint = 0;
		
		protected var _sortKey:String = 'sort';
		protected var _termsKey:String = 'label';
		
	}
}

		
