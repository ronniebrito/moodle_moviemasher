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

	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
/**
* Implementation class for mash module
*
* @see IModule
* @see IClip
*/
	public class AVMash extends Module
	{
		public function AVMash()
		{
			
		}
		
		override public function buffered(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):Boolean
		{
			var is_buffered:Boolean = true;
			if (__mash == null)
			{
				__initMash();
			}
			if (__mash != null)
			{
				is_buffered = __mash.buffered(first, last, mute, rebuffer);
			}
			return is_buffered;
		}
		
		override public function buffer(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):void
		{
			if (__mash == null)
			{
				var m:IValued = media;
				if (m != null)
				{
					__mash = RunClass.Mash['fromXML'](m.getValue('xml').object as XML);
					if (__mash != null)
					{
						var object:Object = _getClipPropertyObject(ClipProperty.MASH);
						
						if ((object != null) && (object is IMash))
						{
							var my_mash:IValued = object as IValued;
						
							__mash.setValue(new Value(1), 'dontreposition');
							__mash.setValue(my_mash.getValue(MediaProperty.FPS), MediaProperty.FPS);
							__mash.setValue(my_mash.getValue('buffertime'), 'buffertime');
							__mash.setValue(my_mash.getValue('minbuffertime'), 'minbuffertime');
							__mash.setValue(my_mash.getValue('unbuffertime'), 'unbuffertime');
							__mash.setValue(new Value(1), 'autostop');
							__mash.setValue(new Value(1), 'dontbufferstart');
							
							addChild(__mash.displayObject);
							if (_size == null) 
							{
								_size = my_mash.getValue('displaysize').object as Size;
							}
							__mash.metrics = _size;
							
							
						}
						__mash.addEventListener(EventType.BUFFER, _mashBuffered);
				
					}
				}
			}
			if (__mash != null)
			{
				
				__mash.buffer(first, last, mute, rebuffer);
				
			}
		}
		override public function unload():void
		{
			if (__mash != null)
			{
				__mash.removeEventListener(EventType.BUFFER, _mashBuffered);
				removeChild(__mash.displayObject);
				__mash.unload();
				__mash = null;
			}
			super.unload();
		}
		override public function unbuffer(first:Number = -1, last:Number = -1):void
		{ 
			if (__mash != null)
			{
				__mash.unbuffer(first, last);
			}
		}
		override protected function _changedSize():void
		{
			__mash.metrics = _size;
		}
		override public function getFrame():Number
		{
			var n:Number = -1;
			if (__mash != null)
			{
				n = __mash.getFrame();
			}
			return n;
		}		
		override public function setFrame(clip_frame:Number):void
		{
			super.setFrame(clip_frame);
			if (__mash != null)
			{
				__mash.setFrame(clip_frame);
				__mash.gotoFrame(clip_frame);
				
			}
		}
		override public function get displayObject():DisplayObjectContainer
		{
			return this;
		}

		override public function set playing(iPlaying:Boolean):void
		{
			if (__mash != null)
			{
				__mash.playing = iPlaying;
			}
		}
		protected function _mashBuffered(event:Event):void
		{
			dispatchEvent(new Event(EventType.BUFFER));
		}
		private function __initMash():void
		{
	
			var m:IValued = media;
			if (m != null)
			{
				__mash = RunClass.Mash['fromXML'](m.getValue('xml').object as XML);
				if (__mash != null)
				{
					var object:Object = _getClipPropertyObject(ClipProperty.MASH);
						
					if ((object != null) && (object is IMash))
					{
						var my_mash:IValued = object as IValued;
						__mash.setValue(new Value(1), 'dontreposition');
						__mash.setValue(my_mash.getValue(MediaProperty.FPS), MediaProperty.FPS);
						__mash.setValue(my_mash.getValue('buffertime'), 'buffertime');
						__mash.setValue(my_mash.getValue('minbuffertime'), 'minbuffertime');
						__mash.setValue(my_mash.getValue('unbuffertime'), 'unbuffertime');
						__mash.setValue(new Value(1), 'autostop');
						__mash.setValue(new Value(1), 'dontbufferstart');
						
						addChild(__mash.displayObject);
						if (_size == null) 
						{
							_size = my_mash.getValue('displaysize').object as Size;
						}
						__mash.metrics = _size;
						
						
					}
					__mash.addEventListener(EventType.BUFFER, _mashBuffered);
			
				}
			}
		
		}
		private var __mash:IMash;
		
	}
}