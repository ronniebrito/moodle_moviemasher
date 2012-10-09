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
package com.moviemasher.module
{
	import com.moviemasher.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
/**
* Abstract base class for all modules. 
*
* @see Clip
* @see Mash
*/
	public class Module extends Sprite implements IModule
	{
		public function Module()
		{
			_defaults = new Object();
			_defaults.fade = '';	
			_defaults.lengthframe = RunClass.TimeUtility['fps'] * 10; // used in case clip and media both return nothing
			//_defaults.swap = '0';
		}
		override public function toString():String
		{
			var s:String = '[Module';
			
			if (__clip != null)
			{
				s += ' ' + String(__clip);
			}
			s += ']';
			return s;
		}
		public function unbuffer(first:Number = -1, last:Number = -1):void
		{ }
		public function unload():void
		{
			
			// I will no longer exist after this
			
			var i:int;
			for (i = numChildren - 1; i > -1; i--)
			{
				removeChildAt(i);
			}

			if (__clip != null) 
			{
				__clip.removeEventListener(Event.CHANGE, _clipDidChange);
				for (var key:String in _defaults)
				{
					__clip.removeEventListener(key, _clipPropertyDidChange);
				}
			}
			__media = null;
			__clip = null;
		}
		public function get backColor():String
		{
			return null;
		}
		public function get displayObject():DisplayObjectContainer
		{
			return null;
		}
		public function getFrame():Number
		{
			return -1;
		}
		public function setFrame(clip_frame:Number):void
		{
			if (_frame != clip_frame)
			{
				_frame = clip_frame;
			}
		}
		public function get media():IMedia
		{
			if ((__media == null) && (__clip != null)) __media = __clip.media;
			return __media;
		}
		public function set clip(m:IClip):void
		{
			__clip = m;
			_initialize();
		}
		public function get keepsTime():Boolean
		{
			return false;
		}
		public function set volumeLevel(percent:Number):void
		{
			
		}
		public function set playing(iBoolean:Boolean):void
		{
			if (_playing != iBoolean)
			{
				_playing = iBoolean;
			}
		}
		final public function set metrics(iMetrics:Size):void
		{
			var wasnt_set:Boolean = (_size == null);
			if (! iMetrics.equals(_size))
			{
				_size = iMetrics;
				if (wasnt_set) _initializeSize();
				__changedSize();
			}
		}
		final public function get metrics():Size
		{
			return _size;
		}
		public function buffer(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):void
		{
			_mute = mute;
		}
		public function buffered(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):Boolean
		{
			_mute = mute;
			return true;
		}
		override public function set scaleX(n:Number):void
		{
			if (_size == null) _size = new Size(1, 1);
			_size.width = n;
		}
		override public function set scaleY(n:Number):void
		{
			if (_size == null) _size = new Size(1, 1);
			_size.height = n;
		}
		override public function get width():Number
		{ return 1; }
		override public function get height():Number
		{ return 1; }	
		private function __changedSize():void
		{
			_changedSize();
		}
		protected function _changedSize():void
		{}
		protected function _clipDidChange(event:Event):void
		{}
		protected function _clipPropertyDidChange(event:ChangeEvent):void
		{}
		protected function _initialize():void
		{
			if (__clip != null) 
			{
				__clip.addEventListener(Event.CHANGE, _clipDidChange);
				for (var key:String in _defaults)
				{
					__clip.addEventListener(key, _clipPropertyDidChange);
				}
			}
		}
		protected function _initializeSize():void
		{}
		protected function _clipCompleted(clip_frame:Number):Number // returns float 0 to 1
		{
			var lengthframe:Number = _getClipPropertyNumber(ClipProperty.LENGTHFRAME);
			if (lengthframe) lengthframe = clip_frame / lengthframe;
			//else RunClass.MovieMasher['msg'](this + '._clipCompleted ' +  clip_frame + ' of ' + lengthframe + ' ' + __clip);
			return lengthframe;
		}
		protected function _getFade(clip_frame:Number):Number // returns float 0 to 100
		{
			var per:Number = 100.0;
			
			var fade:String = _getClipProperty('fade');
			switch (fade)
			{
				case '':
				case Fades.ON: 
					break;
				case Fades.OFF:
					per = 0.0;
					break;
				default:
					per = RunClass.PlotUtility['value'](RunClass.PlotUtility['string2Plot'](fade), _clipCompleted(clip_frame) * 100.0);
				
			}
			return per;
		}
		protected function _getClipPropertyObject(property:String):Object
		{
			
			// get from clip's current value
			var object:Object = null;
			try
			{
				if (__clip != null) object = __clip.getValue(property).object;
				
				if (object == null)
				{
					// get from media's current value
					object = _getMediaPropertyObject(property);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._getClipPropertyObject ' + property, e);
			}

			return object;
		}
		protected function _getClipProperty(property:String):String
		{
			
			// get from clip's current value
			var s:String = '';
			try
			{
				if (__clip != null) s = __clip.getValue(property).string;
				
				if (! s.length)
				{
					// get from media's current value
					s = _getMediaProperty(property);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._getClipProperty ' + property, e);
			}
			return s;
		}
		protected function _getMediaProperty(property:String):String
		{
			// get from media's value
			var s:String = '';
			try
			{
				if (media != null) 
				{
					s = __media.getValue(property).string;
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._getMediaProperty MEDIA ' + property + ' ' + __media + ' ' + s, e);
			}
			try
			{
				if (! s.length)
				{
					// get from my own defaults
					if (_defaults[property] != null)
					{
						s = _defaults[property];
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._getMediaProperty ' + property, e);
			}
			return s;
		}
		protected function _getMediaPropertyObject(property:String):Object
		{
			var object:Object = null;
			try
			{
				// get from media's value
				if (media != null) object = __media.getValue(property).object;
				if ((object == null) && (_defaults[property] != null))
				{
					// get from my own defaults
					//RunClass.MovieMasher['msg'](this + '._getMediaPropertyObject ' + property + ' defaults');
					object = _defaults[property];
					//RunClass.MovieMasher['msg'](this + '._getMediaPropertyObject ' + property + ' defaults property = ' +  _defaults[property]);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._getMediaPropertyObject ' + property + ' defaults = ' + _defaults, e);
			}
			return object;
		}
		protected function _getClipPropertyNumber(property:String):Number
		{
			var n:Number = 0;
			var s:String = _getClipProperty(property);
			if ((s != null) && s.length)
			{
				n = Number(s);
				if (isNaN(n)) n = 0;
			}
			return n;
		}
		protected function _getMediaPropertyNumber(property:String):Number
		{
			var n:Number = 0;
			var s:String = _getMediaProperty(property);
			if (s.length)
			{
				n = Number(s);
				if (isNaN(n)) n = 0;
			}
			return n;
		}
		protected function _getQuantize():Number
		{
			var quantize:Number = 0;
			if ((__clip != null) && (__clip.mash != null)) quantize = __clip.mash.getValue(MashProperty.QUANTIZE).number;
			return quantize;
		}
		private var __clip:IClip = null;
		private var __media:IMedia = null;
		protected var _defaults:Object; 
		protected var _frame:Number;
		protected var _mute:Boolean;
		protected var _playing:Boolean = false;
		protected var _size:Size;
	}
}