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
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	//import com.adobe.utils.*;
	
	

/**
* Class allows loading of YouTube content.
*
* @see RemoteSource
*/
	public class YouTubeSource extends RemoteSource
	{
		public function YouTubeSource()
		{ 
			super();
			
			_countKey = 'max-results';
			_indexKey = 'start-index';
			_sortKey = 'orderby';
			_termsKey = 'q';
			
			_indexStart = 1;
			_defaults[_sortKey] = 'published';
			_defaults.url = 'http://gdata.youtube.com/feeds/api/videos?';
		}
		
		override protected function _parsedURL():String
		{
			var parsed:String = '';
			var bracketed:Array;
			var args:Object;
			var pairs:Array
			var k:String;
			var url:String;
			
			url = getValue('url').string;
			if (! url.length) RunClass.MovieMasher['msg'](this + ' requires the url attribute');
			else
			{
				
				args = new Object();
				args.v = '2'; // version 2 of the API
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
			return parsed;
		}
		override protected function _loadItemsFromData(data:String):void
		{
			var list_xml:XML;
			var xml_list:XMLList;
			var tag:XML;
			var did_add:Boolean = false;
			var count:int = _count;
			try
			{
				list_xml = new XML(data);
			
				xml_list = list_xml.ATOM_NS::entry;
				for each (tag in xml_list)
				{
					count--;
					tag = __tagFromTag(tag);
					if (tag != null)
					{
						if (_addResultIfUnique(tag, true))
						{
							did_add = true;
						}
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
		private function __tagFromTag(video:XML):XML
		{
			var tag:XML = null;
			if (video != null)
			{
				tag = <media/>;
				tag.@label = String(video.ATOM_NS::title);
				
				tag.@id = RunClass.MD5['hash'](String(video.ATOM_NS::id));
				tag.@duration = String(video..YT_NS::duration.@seconds);
				tag.@type = 'video';
				tag.@url = String(video..YT_NS::videoid) + '.youtube';
				tag.@icon = String(video..MEDIA_NS::thumbnail[0].@url);
				tag.@audio = '1';
				/* Video properties
				public var author:String;
				public var id:String;
				public var title:String;
				public var lengthSeconds:uint;
				public var ratingAvg:Number;
				public var ratingCount:uint;
				public var description:String;
				public var viewCount:uint;
				public var uploadTime:Date;
				public var commentCount:uint;
				public var tags:String;
				public var url:String;
				public var thumbnailUrl:String;
				public var playerURL:String;
				*/
		
			}
			return tag;
		}
		
		public static const YT_NS:Namespace = new Namespace('http://gdata.youtube.com/schemas/2007');
		public static const MEDIA_NS:Namespace = new Namespace('http://search.yahoo.com/mrss/');
		public static const ATOM_NS:Namespace = new Namespace('http://www.w3.org/2005/Atom');
		
	}
	
}
/*
<feed xmlns='http://www.w3.org/2005/Atom' xmlns:media='http://search.yahoo.com/mrss/' xmlns:openSearch='http://a9.com/-/spec/opensearch/1.1/' xmlns:gd='http://schemas.google.com/g/2005' xmlns:gml='http://www.opengis.net/gml' xmlns:yt='http://gdata.youtube.com/schemas/2007' xmlns:georss='http://www.georss.org/georss' gd:etag='W/&quot;A0ENR347eip7ImA9WxFRF0s.&quot;'>



	<entry gd:etag='W/&quot;A0ECQ347eCp7ImA9WxFRF0s.&quot;'>
		<id>
			tag:youtube.com,2008:video:u1vaAz_vUE0
		</id>
		<published>
			2010-05-02T03:06:40.000Z
		</published>
		<updated>
			2010-05-02T03:07:42.000Z
		</updated>
		<category scheme='http://schemas.google.com/g/2005#kind' term='http://gdata.youtube.com/schemas/2007#video' />
		<category scheme='http://gdata.youtube.com/schemas/2007/categories.cat' term='Sports' label='Sports' />
		<category scheme='http://gdata.youtube.com/schemas/2007/keywords.cat' term='yu-na' />
		<category scheme='http://gdata.youtube.com/schemas/2007/keywords.cat' term='kim' />
		<category scheme='http://gdata.youtube.com/schemas/2007/keywords.cat' term='yuna' />
		<category scheme='http://gdata.youtube.com/schemas/2007/keywords.cat' term='yu' />
		<category scheme='http://gdata.youtube.com/schemas/2007/keywords.cat' term='na' />
		<title>
			Yuna teaching Korean young figure skaters
		</title>
		<content type='application/x-shockwave-flash' src='http://www.youtube.com/v/u1vaAz_vUE0?f=videos&amp;app=youtube_gdata' />
		<link rel='alternate' type='text/html' href='http://www.youtube.com/watch?v=u1vaAz_vUE0&amp;feature=youtube_gdata' />
		<link rel='http://gdata.youtube.com/schemas/2007#video.responses' type='application/atom+xml' href='http://gdata.youtube.com/feeds/api/videos/u1vaAz_vUE0/responses?v=2' />
		<link rel='http://gdata.youtube.com/schemas/2007#video.related' type='application/atom+xml' href='http://gdata.youtube.com/feeds/api/videos/u1vaAz_vUE0/related?v=2' />
		<link rel='self' type='application/atom+xml' href='http://gdata.youtube.com/feeds/api/videos/u1vaAz_vUE0?v=2' />
		<author>
			<name>
				83common
			</name>
			<uri>
				http://gdata.youtube.com/feeds/api/users/83common
			</uri>
		</author>
		<yt:accessControl action='comment' permission='allowed' />
		<yt:accessControl action='commentVote' permission='allowed' />
		<yt:accessControl action='videoRespond' permission='moderated' />
		<yt:accessControl action='rate' permission='allowed' />
		<yt:accessControl action='embed' permission='allowed' />
		<yt:accessControl action='syndicate' permission='allowed' />
		<gd:comments>
			<gd:feedLink href='http://gdata.youtube.com/feeds/api/videos/u1vaAz_vUE0/comments?v=2' countHint='0' />
		</gd:comments>
		<media:group>
			<media:category label='Sports' scheme='http://gdata.youtube.com/schemas/2007/categories.cat'>
				Sports
			</media:category>
			<media:content url='http://www.youtube.com/v/u1vaAz_vUE0?f=videos&amp;app=youtube_gdata' type='application/x-shockwave-flash' medium='video' isDefault='true' expression='full' duration='62' yt:format='5' />
			<media:credit role='uploader' scheme='urn:youtube'>
				83common
			</media:credit>
			<media:description type='plain'>
				Yuna teaching Korean young figure skaters
			</media:description>
			<media:keywords>
				yu-na, kim, yuna, yu, na
			</media:keywords>
			<media:player url='http://www.youtube.com/watch?v=3IcwG0jUFxU&amp;feature=youtube_gdata' />
			<media:thumbnail url='http://i.ytimg.com/vi/u1vaAz_vUE0/default.jpg' height='90' width='120' time='00:00:31' />
			<media:thumbnail url='http://i.ytimg.com/vi/u1vaAz_vUE0/2.jpg' height='90' width='120' time='00:00:31' />
			<media:thumbnail url='http://i.ytimg.com/vi/u1vaAz_vUE0/1.jpg' height='90' width='120' time='00:00:15.500' />
			<media:thumbnail url='http://i.ytimg.com/vi/u1vaAz_vUE0/3.jpg' height='90' width='120' time='00:00:46.500' />
			<media:thumbnail url='http://i.ytimg.com/vi/u1vaAz_vUE0/hqdefault.jpg' height='360' width='480' />
			<media:title type='plain'>
				Yuna teaching Korean young figure skaters
			</media:title>
			<yt:duration seconds='62' />
			<yt:uploaded>
				2010-05-02T03:06:40.000Z
			</yt:uploaded>
			<yt:videoid>
				u1vaAz_vUE0
			</yt:videoid>
		</media:group>
	</entry>
*/