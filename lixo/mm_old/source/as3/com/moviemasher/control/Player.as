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

package com.moviemasher.control
{
	import com.moviemasher.constant.*;
	import com.moviemasher.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.system.*;
	import flash.utils.*;
/**
* Implimentation class represents a player control
*/
	public class Player extends Control implements IDrop
	{
		public function Player()
		{
			
			_defaults.id = ReservedID.PLAYER;
			_defaults.volume = '75';
			_defaults.source = ClipProperty.MASH;
			_defaults.fps = '10';
			_defaults.buffertime = '10';
			_defaults.minbuffertime = '1';
			_defaults.unbuffertime = '2';
			_defaults.dirty = '0';
			_defaults.hisize = '2';
			_defaults.hicolor = 'FFFFFF';
			_defaults.hialpha = '50';
			
			_defaults[MashProperty.STALLING] = '0';
			_allowFlexibility = true;

			
		}	
		public function dragAccept(drag:DragData):void
		{
			
			var clip:IClip = null;
			var media:IMedia = null;
			clip = drag.items[0] as IClip;
			if (clip != null)
			{
				media = clip.media as IMedia;
				if (media != null)
				{
					var source:String = media.getValue('url').string;
					if (source.length)
					{
						setValue(new Value(source), 'source');
					}
				}
				else RunClass.MovieMasher['msg'](this + '.dragAccept was not able to get media from clip ' + clip); 
			}
			else RunClass.MovieMasher['msg'](this + '.dragAccept was not able to coerce to IClip ' + drag.items);
		}
		public function dragHilite(tf:Boolean):void
		{
			__dragIndicator.visible = tf;
		}
		public function dragOver(drag:DragData):Boolean
		{
			var ok:Boolean = false;
			try
			{
				if ( ! ((__mash == null) || __mash.getValue(PlayerProperty.DIRTY).boolean))
				{
					
					if (drag.items[0] is IClip)
					{
						var clip:IClip = drag.items[0] as IClip;
						if (clip.getValue(CommonWords.TYPE).equals(ClipProperty.MASH))
						{
							ok = true;
							if (__mash != null)
							{
								if (__mash.getValue(CommonWords.ID).equals(clip.getValue(CommonWords.ID).string))
								{
									ok = false;
								}
							}
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return ok;
		}
		public function overPoint(root_pt:Point):Boolean
		{
			var over_point:Boolean = false;
			var pt:Point = globalToLocal(root_pt);
						
			if ((pt.x >0) && (pt.y > 0) && (pt.x < _width) && (pt.y < _height))
			{
				over_point = true;
			}
			return over_point;
		}
		override public function getValue(property:String):Value
		{
			var value:Value;
			switch(property)
			{
				case MediaProperty.FPS:
					value = new Value(__fps);
					break;
				case PlayerProperty.LOCATION:
					value = new Value(RunClass.TimeUtility['timeFromFrame'](__seekingFrame, __fps));
					break;
				case MashProperty.POSITION:
					value = new Value(RunClass.StringUtility['timeString'](RunClass.TimeUtility['timeFromFrame'](__seekingFrame, __fps), __fps, RunClass.TimeUtility['timeFromFrame'](__mashLength, __fps)));
					break;
				case 'completed':
					value = new Value((__seekingFrame * 100) / __mashLength);
					break;
				case ClipProperty.LENGTH:
					value = new Value(RunClass.TimeUtility['timeFromFrame'](__mashLength, __fps));
					break;
				case MediaProperty.DURATION:
					value = new Value(RunClass.StringUtility['timeString'](RunClass.TimeUtility['timeFromFrame'](__mashLength, __fps), __fps, RunClass.TimeUtility['timeFromFrame'](__mashLength, __fps)));
					break;
								
				case ClipProperty.MASH:
					value = new Value(__mash);
					break;
				case 'displaywidth':
					value = new Value(_width);
					break;
				case 'displayheight':
					value = new Value(_height);
					break;
				case PlayerProperty.PLAY:
					value = new Value(__mashPlay ? 1 : 0);
					break;
				case ClipProperty.VOLUME:
					value = new Value(__mashVolume);
					break;
				//case 'mask':
				case PlayerProperty.DIRTY:
				case ClipProperty.TRACK:
				case MashProperty.TRACKS:
				case MediaProperty.LABEL:
				case 'fullscreen':
				case MashProperty.STALLING:

					if (__mash != null)
					{
						value = __mash.getValue(property);
						break;
					}
					
				default:
					value = super.getValue(property);
			}
			return value;
		}
		override public function resize() : void
		{
			
			try
			{
				if (_width && _height)
				{
				
					var initing:Boolean = ((__source == null) && (__mash == null));
					if (initing)
					{
						setValue(getValue('source'), 'source');
					}
					if (__mash != null)
					{
						__mash.metrics = new Size(_width, _height);
						if (getValue(PlayerProperty.AUTOSTART).boolean || getValue('play').boolean)
						{
							if (initing)
							{
								// auto start
								setValue(new Value(0), PlayerProperty.AUTOSTART);
							}
							__resetPlayback();
							__mashPlay = false;
							setValue(new Value(1), PlayerProperty.PLAY);
						}
					}
					if (__dragIndicator != null)
					{
						var hialpha:Number = getValue('hialpha').number;
						var hicolor:String = getValue('hicolor').string;
						var c:Number = RunClass.DrawUtility['colorFromHex'](hicolor);
						var hisize:Number = getValue('hisize').number;
						__dragIndicator.graphics.clear();
						RunClass.DrawUtility['fillBox'](__dragIndicator.graphics, 0, 0, _width, hisize, c, hialpha);
						RunClass.DrawUtility['fillBox'](__dragIndicator.graphics, 0, _height - hisize, _width, hisize, c, hialpha);
						RunClass.DrawUtility['fillBox'](__dragIndicator.graphics, 0, hisize, hisize, _height - (2 * hisize), c, hialpha);
						RunClass.DrawUtility['fillBox'](__dragIndicator.graphics, _width - hisize, hisize, hisize, _height - (2 * hisize), c, hialpha);
					}
					
					
					if (__mash != null)
					{
						__mash.metrics = new Size(_width, _height);
					}					
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		override public function setValue(value:Value, property:String):Boolean
		{
			var dispatch:Boolean = false;
			var set_mash:Boolean = false;
			switch(property)
			{
				case MediaProperty.FPS:
					__fps = value.number;
					RunClass.TimeUtility['fps'] = __fps;
					dispatch = true;
					break;
				case PlayerProperty.DIRTY:
					set_mash = true;
					break;
				case 'refresh':
					__resetPlayback();
					break;
				case 'revert':
					__source.items = new Array(__mashXML);
					__sourceChange(null);
					break;
				case 'new':
					__newMash(value.string);
					break;
				case 'completed':
					__userSetLocation(Math.round((value.number * __mashLength) / 100), __mashPlay);
					break;
				case MashProperty.POSITION:
				case PlayerProperty.LOCATION:
					__userSetLocation(RunClass.TimeUtility['frameFromTime'](value.number, __fps), __mashPlay);
					break;
				case ClipProperty.VOLUME:
					value.number = Math.max(Math.min(100, value.number), 0);
					__mashVolume = value.number;
					set_mash = true;
					dispatch = true;
					break;
				case PlayerProperty.PLAY:
					if (__mashPlay != value.boolean)
					{	
						__muted = false;
						__mashPlay = value.boolean;
						set_mash = true;
						dispatch = true;
					}
					break;
				
				case 'fullscreen':
				case MediaProperty.LABEL:
					set_mash = true;
					break;
				case 'source':
					source = RunClass.MovieMasher['source'](value.string);
					dispatch = true;					
					break;
				default:
					super.setValue(value, property);
					dispatch = true;
			}
			if (set_mash && (__mash != null))
			{
				__mash.setValue(value, property);
			}
			
			if (dispatch)
			{
				dispatchEvent(new ChangeEvent(value, property));
			}
			return false;
		}
		public function set mash(iMash:IMash):void
		{
			try
			{
				if (__mash != iMash)
				{
					var property:String;
					if (__mash != null) 
					{
						setValue(new Value(0), MashProperty.POSITION);
						for each(property in __mashProperties)
						{
							__mash.removeEventListener(property, __mashChange);
						}
						removeChild(__mash.displayObject);
						__mash.unbuffer();
						__mash.unload();
					}
					__mash =iMash;
					
					if (__mash != null)
					{
						__saveXML();
						
						
						__mash.setValue(getValue(PlayerProperty.BUFFERTIME), PlayerProperty.BUFFERTIME);
						__mash.setValue(getValue(PlayerProperty.MINBUFFERTIME), PlayerProperty.MINBUFFERTIME);
						__mash.setValue(getValue(PlayerProperty.UNBUFFERTIME), PlayerProperty.UNBUFFERTIME);
						__mash.setValue(getValue(PlayerProperty.AUTOSTOP), PlayerProperty.AUTOSTOP);
						__mashSetLength(RunClass.TimeUtility['convertFrame'](__mash.lengthFrame, __mash.getValue(MashProperty.QUANTIZE).number, __fps));
							
						for each(property in __mashProperties)
						{
							__mash.addEventListener(property, __mashChange);
							if (property == MediaProperty.LABEL)
							{
								__mashChange(new ChangeEvent(__mash.getValue(property), property));
							}
						}
						if (_width && _height)
						{
							resize();
						}
						addChildAt(__mash.displayObject, 0);

						RunClass.MovieMasher['setByID'](ClipProperty.MASH, __mash);
					
						dispatchEvent(new ChangeEvent(getValue(ClipProperty.MASH), ClipProperty.MASH));
						if (__mash.getValue(PlayerProperty.DIRTY).boolean)
						{
							__mash.setValue(new Value(0), PlayerProperty.DIRTY);
						}
						else dispatchEvent(new ChangeEvent(new Value(0), PlayerProperty.DIRTY));
						__resetPlayback();
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		public function set source(iSource:ISource):void
		{
			if (__source != null)
			{
				__source.removeEventListener(Event.CHANGE, __sourceChange);
			}
			__source = iSource;
			if (__source != null)
			{
				var count:Number = __source.getValue(ClipProperty.LENGTH).number;
				if (count)
				{
					__sourceChange(null);
				}
				else if (! __source.getValue('url').empty)
				{
					__source.addEventListener(Event.CHANGE, __sourceChange);
				}
				else 
				{
					__source = null;
					__newMash();
				}
			}
		}	
		override protected function _createChildren() : void
		{
			
			__dragIndicator = new Sprite();
			addChild(__dragIndicator);
			__dragIndicator.visible = false;
			if (RunClass.DragUtility != null)
			{
				RunClass.DragUtility['addTarget'](this);
				RunClass.DragUtility['registerClipParent'](RunClass.MovieMasher['getByID'](ReservedID.MOVIEMASHER) as Sprite);
			}
			
			setValue(super.getValue(MediaProperty.FPS), MediaProperty.FPS);
		}
		private function __resetPlayback():void
		{
			if (__mash != null)
			{
				__mash.gotoFrame(-1);
			}
		}
		private function __sourceChange(event:Event):void
		{
			try
			{
				var mash_tag:XML;
				
				if ((__source != null) && __source.length)
				{
					for (var i = 0; i < __source.length; i++)
					{
						mash_tag = __source.getResultAt(i);
						if (mash_tag.name() == ClipProperty.MASH)
						{
							break;
						}
					}
				}
				if (mash_tag != null)
				{
					mash = RunClass.Mash['fromXML'](mash_tag);
					__source.removeEventListener(Event.CHANGE, __sourceChange);
					
				}
				else
				{
					__newMash();
				}
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}

		}
		
		private function __mashChange(event:ChangeEvent):void
		{
		
			var dispatch:Boolean = false;
			switch (event.property)
			{
				case PlayerProperty.LOCATION:
					__mashLocation = RunClass.TimeUtility['convertFrame'](event.value.number, __mash.getValue(MashProperty.QUANTIZE).number, __fps); 
					
					if ((__seekingFrame != __mashLocation))
					{
						__seekingFrame = __mashLocation;
						__dispatchLocationEvent();
					}
					break;
				case ClipProperty.LENGTH:
					__mashSetLength(RunClass.TimeUtility['convertFrame'](__mash.lengthFrame, __mash.getValue(MashProperty.QUANTIZE).number, __fps));
					break;
				case PlayerProperty.DIRTY:
					if (! event.value.boolean) 
					{
						__saveXML();
						
					}
				case ClipProperty.TRACK:
				case MashProperty.TRACKS:
				case MashProperty.STALLING:
				case MediaProperty.LABEL:
					dispatch = hasEventListener(event.property);
					break;
				case ClipProperty.VOLUME:
					break;
				case PlayerProperty.PLAY:
					dispatch = true;
					__mashPlay = event.value.boolean;
					break;
					
			}
			if (dispatch)
			{
				dispatchEvent(new ChangeEvent(event.value, event.property));
			}
		}
		private function __newMash(id:String = ''):void
		{
			source = null;
			try
			{
				var dims:Size = null;
				if (__mash != null)
				{
					dims = __mash.getValue('displaysize').object as Size;
				}
				if (dims == null)
				{
					dims = new Size(_width, _height);
				}
				if (! id.length) id = RunClass.MD5['hash'](Capabilities.serverString + String((new Date()).getTime()) + String(Math.random()));
				var mash_xml:XML = <mash />;
				mash_xml.@width = dims.width;
				mash_xml.@height = dims.height;
				mash_xml.@id = id;
				mash_xml.@label = 'Untitled';
				mash = RunClass.Mash['fromXML'](mash_xml);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __userSetLocation(n:Number, dont_delay:Boolean = false):void
		{
			n = Math.max(0, Math.min(n, __mashLength));
			if (__seekingFrame != n)
			{
				__seekingFrame = n;
				__dispatchLocationEvent();
				if (dont_delay)
				{
					__seekTimed(null);
				}
				else if (__seekTimer == null)
				{
				
					__seekTimer = new Timer(1);
					__seekTimer.addEventListener(TimerEvent.TIMER, __seekTimed);
					__seekTimer.start();				
				}
			}
		}
		private function __seekTimed(event:TimerEvent):void
		{
			try
			{
				if (__seekedFrame != __seekingFrame)
				{
					__seekedFrame = __seekingFrame;
				}
				else if (__seekTimer != null)
				{
					__seekTimer.removeEventListener(TimerEvent.TIMER, __seekTimed);
					__seekTimer.stop();
					__seekTimer = null;
				}
				if (__mash != null)
				{
				
					__mash.gotoFrame(RunClass.TimeUtility['convertFrame'](__seekedFrame, __fps, __mash.getValue(MashProperty.QUANTIZE).number, ''));
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __dispatchLocationEvent():void
		{
			if (hasEventListener(PlayerProperty.LOCATION)) 
			{
				dispatchEvent(new ChangeEvent(getValue(PlayerProperty.LOCATION), PlayerProperty.LOCATION));
			}
			if (hasEventListener('completed')) 
			{
				dispatchEvent(new ChangeEvent(getValue('completed'), 'completed'));
			}
			if (hasEventListener(MashProperty.POSITION)) 
			{
				dispatchEvent(new ChangeEvent(getValue(MashProperty.POSITION), MashProperty.POSITION));
			}
		}
		
		private function __mashSetLength(n:int):void
		{
			if (__mashLength != n)
			{
					
				__mashLength = n;
				if (__mashLength < __mashLocation) __userSetLocation(__mashLength);
				
				if (hasEventListener(ClipProperty.LENGTH)) 
				{
					dispatchEvent(new ChangeEvent(getValue(ClipProperty.LENGTH), ClipProperty.LENGTH));
				}
				if (hasEventListener('completed')) 
				{
					dispatchEvent(new ChangeEvent(getValue('completed'), 'completed'));
				}
				if (hasEventListener(MediaProperty.DURATION)) 
				{
					dispatchEvent(new ChangeEvent(getValue(MediaProperty.DURATION), MediaProperty.DURATION));
				}
			}
		}
		private function __saveXML():void
		{
			__mashXML = __mash.getValue(ClipProperty.XML).object as XML
			
			var object:Object = __mash.referencedMedia();
			var key:String;
			for (key in object)
			{
				__mashXML.appendChild(object[key]);
			}
		}
		private static var __mashProperties:Array = [MashProperty.STALLING, ClipProperty.LENGTH, PlayerProperty.PLAY, PlayerProperty.DIRTY, ClipProperty.VOLUME, ClipProperty.TRACK, MashProperty.TRACKS, PlayerProperty.LOCATION, MediaProperty.LABEL];
		private var __dragIndicator:Sprite;
		private var __hidden:Boolean = false;
		private var __mash:IMash;
		private var __mashLength:Number = 1;
		private var __mashLocation:Number = 0;
		private var __mashPlay:Boolean;
		private var __mashVolume:Number = 75;
		private var __muted:Boolean = true;
		private var __seekedFrame:Number = 0;
		private var __seekingFrame:Number = 0;
		private var __seekTimer:Timer;
		private var __source:ISource;
		private var __fps:int = 0;
		private var __mashXML:XML;
		
	}	
}