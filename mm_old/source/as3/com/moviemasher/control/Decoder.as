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
	
	import com.adobe.images.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;
/**
* Control override assists in rendering mash
*/
	public class Decoder extends Control
	{
		public function Decoder()
		{
			
			// for optional timecode
			_defaults.timecode = '0';
			_defaults.textsize = '12';
			_defaults.textalign = 'left';
			_defaults.textvalign = '';
			_defaults.font = 'default';
			_defaults.forecolor = '000000';
			_defaults.multiline = '1';


			_defaults.autostop = '1';
			_defaults.buffertime = '10';
			_defaults.minbuffertime = '2';
			_defaults.unbuffertime = '2';
			_defaults.localhost = 'localhost';
			
			// player related
			
			_defaults.id = ReservedID.PLAYER;
			_defaults.volume = '75';
			_defaults.source = ControlProperty.MASH;
			_defaults.fps = '10';
			_defaults.buffertime = '10';
			_defaults.minbuffertime = '1';
			_defaults.unbuffertime = '2';
			_allowFlexibility = true;


			__jpegs = new Array();
			__updateTime();
			__timeoutTimer = new Timer(__timeout / 4);
			__timeoutTimer.addEventListener(TimerEvent.TIMER, __checkTimeout);
			__timeoutTimer.start();
			__postTimer = new Timer(1);
			__postTimer.addEventListener(TimerEvent.TIMER, __checkPost);
			__postTimer.start();
			
			RunClass.MovieMasher['setByID']('debug', this);
		}
		override public function initialize():void
		{
			//RunClass.MovieMasher['msg(this + '.initialize ' + _tag.toXMLString']());
			super.initialize();
			
			__version = getValue('version').string;
			
			if (__version.length)
			{
				var spans:XMLList = _tag.timespan;
				__spans = new Array();
				var tag:XML;
				var z:int = spans.length();
				var i:int;
				for (i = 0; i < z; i++)
				{
					tag = spans[i];
					__spans.push(new Array(Number(tag.@frame), Number(tag.@frames), 0));	
				}
			}
			if (__textField != null) 
			{
				RunClass.FontUtility['formatField'](__textField, this);
			}
			setValue(getValue('source'), 'source');
			
			
		}
		override public function resize() : void
		{
			// this is only called once
			
			super.resize();
			if (_width && _height)
			{
				if (__textField != null)
				{
					__textField.width = _width;
					__textField.height = _height;
					if (! contains(__textField))
					{
						addChild(__textField);
					}
				}
				if (__decoderMash != null) 
				{
					__decoderMash.metrics = new Size(_width, _height);
					if (! contains(__decoderMash.displayObject))
					{
						addChildAt(__decoderMash.displayObject, 0);
					}
					// we are ready to start loading first frame
					__doNextFrame();
				}
			}
		}		
		override public function setValue(value:Value, property:String):Boolean
		{
			switch(property)
			{
				case 'error':
					__outputString(value.string + ' status: ' + __statusMessage(), true);
					break;
				case 'debug':
					//TODO: output debug messages too!!
					//__outputString(value.string, false);
					break;
				case 'source':
					source = RunClass.MovieMasher['source'](value.string);
					break;
				default:
					super.setValue(value, property);
			}
			return false;
		}
		public function set mash(iMash:IMash):void
		{
			try
			{
				//RunClass.MovieMasher['msg(this + '.mash ' + '](__decoderMash != iMash));
				if (__decoderMash != iMash)
				{
					var property:String;
					
					__decoderMash =iMash;
					RunClass.MovieMasher['setByID'](ReservedID.MASH, __decoderMash);
					if (__decoderMash != null)
					{
						__decoderMash.setValue(getValue(PlayerProperty.BUFFERTIME), PlayerProperty.BUFFERTIME);
						__decoderMash.setValue(getValue(PlayerProperty.MINBUFFERTIME), PlayerProperty.MINBUFFERTIME);
						__decoderMash.setValue(getValue(PlayerProperty.UNBUFFERTIME), PlayerProperty.UNBUFFERTIME);
						__decoderMash.setValue(getValue(PlayerProperty.AUTOSTOP), PlayerProperty.AUTOSTOP);
							
						__decoderMash.setValue(new Value(1), 'readonly');
						__decoderMash.addEventListener(PlayerProperty.LOCATION, __locationMash);
						
					}
				}
			}
			catch(e:*)
			{
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
				var count:Number = __source.getValue('length').number;
				if (count)
				{
					__sourceChange(null);
				}
				else if (! __source.getValue('url').empty)
				{
					__source.addEventListener(Event.CHANGE, __sourceChange, false, 0, true);
				}
				else 
				{
					// this will call __newMash() during initialize
					__source = null;
				}
			}
		}	
		override protected function _createChildren():void
		{
			//RunClass.MovieMasher['msg(this + '._createChildren ' + _tag.toXMLString']());

			// not calling super
			__fps = getValue(MediaProperty.FPS).number;
			RunClass.TimeUtility['fps'] = __fps;

			if (getValue('timecode').boolean)
			{
				__textField = new TextField();
				_displayObjectLoad(ModuleProperty.FONT);
			}
			//RunClass.MovieMasher['msg(this + '._createChildren ' + getValue']('timecode').boolean, 'debug');
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
						if (mash_tag.name() == TagType.MASH)
						{
							break;
						}
					}
				}
				if (mash_tag != null)
				{
					//RunClass.MovieMasher['msg(this + '.__sourceChange ' + mash_tag.toXMLString']());
					mash = RunClass.Mash['fromXML'](mash_tag);
					__source.removeEventListener(Event.CHANGE, __sourceChange);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__sourceChange', e);
			}

		}
		private function __doNextFrame():void
		{
			if (__spanIndex == __spans.length)
			{
						
				if ((! __jpegs.length) && (! __posting)) fscommand("quit");
			}
			else
			{
				var span:Array = __spans[__spanIndex];
				var frame:Number = span[0] + span[2];
				__goFrame(frame);
			}
		
		}
		private function __locationMash(event:Event):void
		{
			__updateTime();
			if (event != null)
			{
				__updateStatus();
			}
			__grabFrame();
		}
		private function __grabFrame():void
		{
			try
			{
				if (__spanIndex < __spans.length)
				{
					var jpgSource:BitmapData = new BitmapData (width, height);
					jpgSource.draw(RunClass.MovieMasher['instance']);
					
					var jpgEncoder:JPGEncoder = new JPGEncoder(100);
					var jpgStream:ByteArray = jpgEncoder.encode(jpgSource);
					jpgSource.dispose();
					var span:Array = __spans[__spanIndex];
					
					var url:String = 'http://' + getValue('localhost').string + '/' + __version + '/frame/?frame=' + (span[2] + 1);
					url += '&zeropadding=' + getValue('zeropadding').string;
					url += '&path=' + getValue('path').string;
					url += '&span=' + __spanIndex;
					var object:Object = new Object();
					object.jpeg = jpgStream;
					object.url = url;
					__jpegs.push(object);
					__jpegCreated = true;
				}
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__grabFrame', e);
			}
		}
		private function __outputString(s:String, is_error:Boolean):void
		{
			try
			{
				
				var url:String = 'http://' + getValue('localhost').string + '/' + __version + '/';
				url += (is_error ? 'error' : 'debug');
				url += '/?path=' + getValue('path').string;
					
				
				__loader = RunClass.MovieMasher['dataFetcher'](url, s);
				__loader.addEventListener(Event.COMPLETE, (is_error ? __quit : __removeListener));
				
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__outputString', e);
			}
		}
		private function __grabURLDidLoad(event:Event):void
		{
			try
			{
				event.target.removeEventListener(Event.COMPLETE, __grabURLDidLoad);
				__posting --;
				
				//__checkPost(null);
				/*
				var fetcher:IDataFetcher = event.target as IDataFetcher;
				var s:String = fetcher.data();
				
				*/
			}
			catch(e:*)
			{
			}
		}
		private function __advanceSpan():void
		{
			__spans[__spanIndex][2]++;
			if (__spans[__spanIndex][2] == __spans[__spanIndex][1])
			{
				__spanIndex++;
			}
			__doNextFrame();
		}
		private var __jpegs:Array;
		private var __posting:int = 0;
		private var __jpegCreated:Boolean = false;
		private function __checkPost(event:TimerEvent):void
		{
			if (__jpegCreated)
			{
				__jpegCreated = false;
				__advanceSpan();
			}
			if (__jpegs.length && (__posting < 20))
			{
				__posting++;
				var object:Object = __jpegs.shift();
				var fetcher:IDataFetcher = RunClass.MovieMasher['dataFetcher'](object.url, object.jpeg);
				fetcher.addEventListener(Event.COMPLETE, __grabURLDidLoad);
			}
			else if ((! __jpegs.length) && (! __posting))
			{
				if (__spanIndex == __spans.length)
				{
					fscommand('quit');
				}
			}
		}
		private function __checkTimeout(event:TimerEvent):void
		{
			
			var d:Date = new Date();
			var now:Number = d.getTime();
					
			if (now > (__timeoutTime + __timeout))
			{
				var s:String = '';
				var all_buffered:Boolean = true;
				if (__decoderMash == null)
				{
					all_buffered = false;
				}
				else
				{
					var frame_number:Number = RunClass.TimeUtility['convertFrame'](__decoderMash.getFrame(), __decoderMash.getValue(MashProperty.QUANTIZE).number);
					var is_buffered:Boolean;
					
					if (frame_number != __goingToFrame)
					{
						s = "Timed out at " + RunClass.TimeUtility['timeFromFrame'](frame_number, __fps) + ' (frame ' + frame_number + ') caching frame ' + __goingToFrame + ') with clips:';
							
						var clips:Array = __decoderMash.clipsInRange(__goingToFrame, __goingToFrame);
						var clip:IClip;
						for each (clip in clips)
						{
							if (! clip.getValue(CommonWords.TYPE).equals(ClipType.AUDIO))
							{
								is_buffered = clip.buffered(__goingToFrame, __goingToFrame, true, false);
								if (! is_buffered) 
								{
									all_buffered = false;
								}
								s += "\n[" + clip.getValue(CommonWords.TYPE).string + ' ' + clip.getValue(CommonWords.ID).string + ' ' + (is_buffered ? '' : 'not ') + 'buffered]';
							}
						}
					}
				}
				if (all_buffered) 
				{
					// TODO: figure out why the mash is getting stalled
					__goFrame(__goingToFrame);
					return;
				}
				__timeoutTimer.removeEventListener(TimerEvent.TIMER, __checkTimeout);
				__timeoutTimer.stop();
				__timeoutTimer = null;
				if (! s.length) s = __statusMessage();
				__outputString(s, true); // will quit
			
			}
		}
		private function __goFrame(frame:int):void
		{
			__goingToFrame = frame;
			
			var frame_number:Number = RunClass.TimeUtility['convertFrame'](__decoderMash.getFrame(), __decoderMash.getValue(MashProperty.QUANTIZE).number);
			if (frame_number == __goingToFrame)
			{
				__locationMash(null);
			}
			else
			{
				__decoderMash.gotoFrame(RunClass.TimeUtility['convertFrame'](__goingToFrame, __fps, __decoderMash.getValue(MashProperty.QUANTIZE).number, ''));

			}
		}
		private function __removeListener(event:Event):void
		{
			if (__loader != null)
			{
				__loader.removeEventListener(Event.COMPLETE, __removeListener);
				__loader = null;
				
			}
		}
		private function __updateStatus():void
		{
				
			if (__textField != null) 
			{
				__textField.text = __statusMessage();
			}
		}
		private function __statusMessage():String
		{
			var frame_number:Number = RunClass.TimeUtility['convertFrame'](__decoderMash.getFrame(), __decoderMash.getValue(MashProperty.QUANTIZE).number);
			var s:String = '';
			s += 'Time: ' + RunClass.TimeUtility['timeFromFrame'](frame_number, __fps);
			s += "\nFrame: " + (1 + frame_number);
			s += "\nMemory: " + StringUtility.byteString(System.totalMemory);
			s += "\nJPEGS: " + __jpegs.length + ' queued ' + __posting + ' posted';
			
			var clips:Array = __decoderMash.clipsInRange(frame_number, frame_number);
			var clip:IClip;
			for each (clip in clips)
			{
				if (! clip.getValue(CommonWords.TYPE).equals(ClipType.AUDIO))
				{
					s += "\n[" + clip.getValue(CommonWords.TYPE).string + ' ID ' + clip.getValue(CommonWords.ID).string + ']';
				}
			}
			return s;
		}
		private function __updateTime():void
		{
			var d:Date = new Date();
			__timeoutTime = d.getTime();
		}
		private function __quit(event:Event):void
		{
			__postTimer.removeEventListener(TimerEvent.TIMER, __checkPost);
			__postTimer.stop();
			__postTimer = null;

			fscommand("quit");
		}
		private static var __timeout:Number = 1000 * 20; // milliseconds
		private var __goingToFrame:int = -1;
		private var __decoderMash:IMash;
		private var __loader:IDataFetcher;
		private var __source:ISource;
		private var __textField : TextField;
		private var __timeoutTime:Number = 0;
		private var __timeoutTimer:Timer;
		private var __postTimer:Timer;
		private var __version:String;
		private var __spans:Array;
		private var __spanIndex:int = 0;
		private var __fps:int = 0;
		
	}
	
}

