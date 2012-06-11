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
	import flash.events.*;
	import flash.display.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.utils.*;
	import com.moviemasher.events.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.source.*;
	
/**
* Class represents all media objects including modules
* 
* @see Clip
*/
	public class Media extends Propertied implements IMedia
	{
		public static function xmlFromMediaID(id:String, mash:IMash = null):XML
		{
			var media_xml:XML = null;
			try
			{
				media_xml = RunClass.MovieMasher['searchTag'](TagType.MEDIA, id);
				if ((media_xml == null) && (mash != null))
				{
					media_xml = RunClass.MovieMasher['searchTag'](TagType.MEDIA, id, CommonWords.ID, mash.tag);
					
				}
				if (media_xml == null) 
				{
					media_xml = Source.getByID(id);
				}
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg']('Media.xmlFromMediaID', e);
			}
			return media_xml;
		}
		public static function fromMediaID(id:String, mash:IMash = null):IMedia
		{
			var media:IMedia = null;
			
			try
			{
				var media_xml:XML = xmlFromMediaID(id, mash);
				if (media_xml != null)
				{
					media = fromXML(media_xml);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg']('Media.fromMediaID', e);
			}
			return media;
				
		}
		public static function fromXML(node:XML):IMedia
		{
			var media:IMedia = null;
			try
			{
				if (node != null)
				{
					media = new Media();
					node.setName(TagType.MEDIA);
					media.tag = node;
					if (! multitrackVideo)
					{
						var media_type:String = media.getValue(CommonWords.TYPE).string;
						if (((media_type == ClipType.VIDEO) || (media_type == ClipType.MASH)) && media.getValue(ClipProperty.HASAUDIO).boolean)
						{
							multitrackVideo = true;
						}
					}
				}
				else RunClass.MovieMasher['msg']('Media.fromXML with null xml node');
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg']('Media.fromXML', e);
			}
			return media;
		}
		public static var types:Array = [ClipType.IMAGE,ClipType.VIDEO,ClipType.AUDIO,ClipType.EFFECT,ClipType.TRANSITION,ClipType.THEME,ClipType.MASH];		
		public static var multitrackVideo:Boolean = false;	
		public function Media()
		{ }
		public function get audioIsPlayable():Boolean
		{
			return __audioIsPlayable;
		}
		
		public function get audioIsExtractable():Boolean
		{
			return __audioIsExtractable;
		}
		public function get seconds():Number
		{
			// attempt to read length attribute of tag, if defined
			var media_seconds:Number = 0;
			try
			{
				media_seconds = getValue(ClipProperty.LENGTH).number;
				if (! media_seconds) 
				{
					// attempt to read duration attribute of tag, if defined
					media_seconds = getValue(MediaProperty.DURATION).number;
				}
				if (! media_seconds) 
				{
					// relevant attribute was not set in tag, see if an option tag exists
					media_seconds = RunClass.MovieMasher['getOptionNumber']('mash', __type + 'seconds');
				}
				if (! media_seconds) 
				{
					// no option tag with type=mash having attribute [type]seconds, use some defaults
					switch(__type)
					{
						case ClipType.TRANSITION:
							media_seconds = 1;
							break;
						case ClipType.EFFECT:
							media_seconds = 4;
							break;
						case ClipType.THEME:
							media_seconds = 10;
							break;
						case ClipType.IMAGE:
							media_seconds = 2;
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.seconds', e);
			}
			return media_seconds; // could potentially be zero for non modular media, if improperly configured
		}
		override public function getValue(property:String):Value
		{
			var value:Value;
			switch (property)
			{
				case ClipProperty.HASAUDIO:
					value = new Value(__hasA());
					break;
				
				case MediaProperty.ICON:
					
					value = super.getValue(property);
					if (value.empty && super.getValue(CommonWords.TYPE).equals(ClipType.AUDIO))
					{
						value = super.getValue(MediaProperty.WAVE);
					}
					break;
				default:
					value = super.getValue(property);
			}
			return value;					
		}
		public function clipProperties():Object
		{
			return _editableProperties;
			
		}
		public function clipProperty(property:String):String
		{
			var s:String = '';
			if (_editableProperties[property] != null)
			{
				s = _editableProperties[property];
			}
			return s;
		}
		public function editableProperties():Array
		{
			var a:Array = new Array();
			var done:Object = new Object();
			for (var property:String in _defaults)
			{
				a.push(property);
				done[property] = true;
			}
			var list:XMLList =  _tag.@*;
			var z:int = list.length();
			for (var i:Number = 0; i < z; i ++)
			{
				property = list[i].name();
				if (! done[property])
				{
					a.push(property);
					done[property] = true;
				}
			}
			return a;
		}
		public function get isModular():Boolean
		{
			var is_modular:Boolean = true;
			switch (__type)
			{
				case ClipType.AUDIO:
				case ClipType.IMAGE:
				case ClipType.VIDEO: 
					is_modular = false;	
					break;
			}
			return is_modular;
		}
		public function propertyDefined(property:String):Boolean
		{
			return (_attributes[property] != null);
		}
		public function get waveformBitmap():DisplayObject
		{
			var display_object:DisplayObject = null;
			var wave:String = getValue(MediaProperty.WAVE).string;
			if (wave.length)
			{
				var loader:IAssetFetcher = RunClass.MovieMasher['assetFetcher'](wave);
				
				display_object = loader.displayObject(wave);
			}
			return display_object;
		}
		override protected function _parseTag():void
		{
			var audio:String = getValue(MediaProperty.AUDIO).string;
			__audioIsPlayable = ((audio != '0') && audio.length);
			if (__audioIsPlayable)
			{
				__audioIsExtractable = ((audio.length > 4) && (audio.substr(-4).toLowerCase() == '.mp3'));
			}
			__type = getValue(CommonWords.TYPE).string;
			switch(__type)
			{
				case ClipType.VIDEO:
					_defaults.pattern = '%.jpg';
					_defaults.zeropadding = '1';
					_defaults.begin = '1';
					_defaults.increment = '1';
					_defaults.fill = FillType.STRETCH;
					break;
				case ClipType.IMAGE:		
					_defaults.fill = FillType.STRETCH;
					break;
				case ClipType.AUDIO:
					_defaults.loop = '0';
					break;
			}
			_editableProperties = new Object();
			var names:Array = getValue(MediaProperty.EDITABLE).array;
				
			try
			{
				var ob:Object = new Object();
				var z:uint = names.length;
				var property:String;
				var value:String;
			
		
				for (var i:uint = 0; i < z; i++)
				{
					property = names[i];
					value = getValue(property).string;
					_editableProperties[property] = value;
				}
				
				

			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __hasA():Boolean
		{
			return ! getValue(MediaProperty.AUDIO).empty;
		}
		private var _editableProperties:Object;
		private var __audioIsPlayable:Boolean;
		private var __audioIsExtractable:Boolean;
		private var __type:String;

	}
}