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
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.utils.*;
	//import com.adobe.utils.*;
	
/**
* Class allows loading of Flickr content.
*
* @see RemoteSource
*/
	public class SignWritingSource extends RemoteSource
	{
		public function SignWritingSource()
		{ 
			super();
			_countKey = 'per_page';
			_termsKey = 'palavra';
			_indexKey = 'page';
			_sortKey = 'orderby';
			//_defaults.url = 'http://www.nals.cce.ufsc.br/glossario/bsw.php?';
			_defaults.url = 'http://localhost/moodle/mod/moviemasher/binarySignWriting.php?';
			_defaults.api_key = '';			
		}
		override protected function _parsedURL():String
		{
			var bracketed:Array;
			var parsed:String = '';
			var args:Object;
			var pairs:Array
			var k:String;
			var url:String;
			
			url = getValue('url').string;
			
			if (! url.length) RunClass.MovieMasher['msg'](this + ' requires the url attribute');
			else
			{
				args = new Object();
				//args.method = method;
				//args.api_key = api_key;
				
				// Flickr wants to know the page number rather than the start index
				args[_indexKey] = String(Math.floor((_index + _count) / _count));
				
				bracketed = RunClass.ParseUtility['bracketed'](url);
				args = _searchArgs(args, bracketed);
				if (args != null)
				{
					pairs = new Array();
					for (k in args)
					{
						pairs.push(k + '=' + args[k]);
					}
					parsed += super._parsedURL();
					parsed += pairs.join('&');
				}
			}
			trace('parsed' + parsed);
			return parsed;
		}

		override protected function _loadItemsFromData(data:String):void
		{
			//trace('data='+ data);
			var list_xml:XML;
			var xml_list:XMLList;
			var tag:XML;
			var did_add:Boolean = false;
			var count:int = _count;
			try
			{
				tag = __tagFromTag(data);
						if (tag != null)
						{
							//trace('tag0'+ tag.toXMLString());
							if (_addResultIfUnique(tag, true))
							{
								trace('tag'+ tag.toXMLString());
								// <media label="6" id="fc7a04ce536620d9269d07d87fdf5d0a" type="image" url="http://farm7.static.flickr.com/6129/5936170970_c654647056.jpg" icon="http://farm7.static.flickr.com/6129/5936170970_c654647056_t.jpg"/>
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
		
		// traduz uma tag do XML para a representacao interna do MM
		private function __tagFromTag(bsw:String):XML
		{
			var tag:XML = null;			
			//if ((bsw != null) && String(bsw.@id).length)
			//{
				tag = <media/>;
				tag.@label ="";		
				//tag.@id = RunClass.MD5['hash'](bsw);
				
				tag.@id = bsw;
				tag.@bsw = bsw;
				tag.@type = 'image';
				tag.@url = 'http://localhost/moodle/mod/moviemasher/temp/'+ bsw.slice(0,128)+'.png';
				tag.@href = 'http://localhost/moodle/mod/moviemasher/temp/'+ bsw.slice(0,128)+'.png';
				tag.@icon = 'http://localhost/moodle/mod/moviemasher/temp/'+bsw.slice(0,128)+'.png';
				//trace( 'url'+'http://localhost/mod/moviemasher/binarySignWritingImage.php?bsw='+bsw);
		
			//}
			return tag;
		}
		
	}
	
}
			/*	
				photo.id = p.@id.toString();
				photo.farmId = parseInt(p.@farm);
				photo.ownerId = p.@owner.toString();
				photo.secret = p.@secret.toString();
				photo.server = parseInt( p.@server );
				photo.ownerName = p.@username.toString();
				photo.title = p.@title.toString();
			http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}.jpg
	or
http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}_[mstb].jpg
	or
http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{o-secret}_o.(jpg|gif|png)
Size Suffixes

The letter suffixes are as follows:

s	small square 75x75
t	thumbnail, 100 on longest side
m	small, 240 on longest side
-	medium, 500 on longest side
b	large, 1024 on longest side (only exists for very large original images)
o	original image, either a jpg, gif or png, depending on source format
*/					
