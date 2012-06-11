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
	import flash.events.*;
	import flash.geom.*;
	import flash.display.*;
	import flash.system.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;	
	import com.moviemasher.events.*;
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
/**
* Implementation class for composite effect module
*
* @see IModule
* @see Clip
* @see Mash
*/
	public class Composite extends ModuleTransition
	{
		public function Composite()
		{
			_defaults.blend = 'normal';
			_defaults.alpha = '100';
			_defaults.alphafade = '100';
			_defaultMatrix();
			_displayObjectContainer = new Sprite();
			addChild(_displayObjectContainer);
		}
		override public function buffer(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):void
		{
			try
			{
				super.buffer(first, last, mute, rebuffer);
							
				var composited_clip:IClip = __composited;
				if (composited_clip == null) composited_clip = composited;
				if (composited_clip != null)
				{
					__composited.addEventListener(EventType.BUFFER, __clipBuffer);
					var cfirst:Number = _compositedFrame(first);
					var clast:Number = _compositedFrame(last);
					if (clast < cfirst)
					{
						var sf:Number = _getClipPropertyNumber(ClipProperty.STARTFRAME);
						var lf:Number = _getClipPropertyNumber(ClipProperty.LENGTHFRAME);
						__composited.buffer(cfirst, sf + lf, mute, rebuffer);
						__composited.buffer(sf, clast, mute, true); // this is a rebuffer of the begining
					}
					else __composited.buffer(cfirst, clast, mute, rebuffer);
				}
				/*
				else
				{
					RunClass.MovieMasher['msg'](this + '.buffer would call __clipBuffer');
					return;
					__clipBuffer(null);
				}
				*/
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.buffer', e);
			}
		}
		override public function buffered(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):Boolean
		{
			//return false;
			var is_buffered:Boolean = false;
			var composited_clip:IClip = __composited;
			if (composited_clip == null) composited_clip = composited;
			if (composited_clip != null)
			{
				var cfirst:Number = _compositedFrame(first);
				var clast:Number = _compositedFrame(last);
				if (clast < cfirst)
				{
					var sf:Number = _getClipPropertyNumber(ClipProperty.STARTFRAME);
					var lf:Number = _getClipPropertyNumber(ClipProperty.LENGTHFRAME);
					is_buffered = __composited.buffered(cfirst, sf + lf, mute, rebuffer);
					is_buffered = __composited.buffered(sf, clast, mute, true) && is_buffered; // this is a rebuffer of the begining
				}
				else is_buffered = __composited.buffered(cfirst, clast, mute, rebuffer);
			}
			else
			{
			//	RunClass.MovieMasher['msg'](this + '.buffered without composite'); 
				is_buffered = true;
			}
			return is_buffered;
		}
		override public function setFrame(clip_frame:Number):void
		{
			super.setFrame(clip_frame);

			try
			{
				
				if ((__composited != null) && (! _displayObjectContainer.contains(__composited.displayObject)))
				{
					_displayObjectContainer.addChild(__composited.displayObject);
				}

				if (__composited != null)
				{
					_setCompositedSize();
					if (! _mute) __composited.volumeLevel = __composited.volumeFromTime(_compositedFrame(), _volume * 100);
					var blend:String = _getClipProperty('blend');
					if (! blend.length) blend = RunClass.DrawUtility['blendModes'][0];
					blend = RunClass.DrawUtility['blendMode'](blend);
					__composited.displayObject.blendMode = blend;
				}
				/*
				else
				{
					if (__composited == null)
					{
						if (parent != null) _setDisplayObjectMatrix(parent);
					}
				}
				*/
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.setFrame COMPOSITE ' + parent + ' ' + _displayObjectContainer, e);
			}
		}
		/*
		override public function getValue(property:String):Value
		{
			var value:Value;
			switch(property)
			{
				case 'hasaudio':
					if (__composited != null)
					{
						value = __composited.getValue(property);
						break;
					}
				default:
					value = super.getValue(property);
			}
			return value;
		}
		*/
		override public function get displayObject():DisplayObjectContainer
		{
			return this;
		}
		override public function set volumeLevel(percent:Number):void
		{
			_volume = percent;
		}
		override public function unbuffer(first:Number = -1, last:Number = -1):void
		{ 
			if (__composited != null)
			{
				// wait for unload to be called
				//__composited.unbuffer(_compositedFrame(first), _compositedFrame(last));
			}
			super.unbuffer(first, last);
		}
		override public function unload():void
		{
			__unloadCompositedModule();
			super.unload();
		}
		
		override public function get keepsTime():Boolean
		{
			 var boolean:Boolean = false;
			 if (__composited != null) 
			 {
			 	boolean = __composited.keepsTime;
			 }
			return boolean;
		}
		override public function set playing(iBoolean:Boolean):void
		{
			if (_playing != iBoolean)
			{
				_playing = iBoolean;
				if (__composited != null)
				{
					__composited.playing = _playing;
				}
				
			}
		}
		override protected function _changedSize():void
		{
			if (__composited != null)
			{
				__composited.metrics = _size;
			}
			
		}
		override protected function _clipDidChange(event:Event):void
		{
			super._clipDidChange(event);
			var getit:IClip = composited;
		}
		override protected function _clipPropertyDidChange(event:ChangeEvent):void
		{
			super._clipPropertyDidChange(event);
			switch (event.property)
			{
				case 'composites':
					var getit:IClip = composited;
					break;
			}
				
		}
		protected function get composited():IClip
		{
			try
			{
				var composites:Array = new Array();
				var iclip:IClip = null;
				var imedia:IMedia = null;
				var string:String;
				var object:Object = _getClipPropertyObject('composites');
				if (object != null) 
				{
					if (object is Array) composites = object as Array;
					else if (object is String) 
					{
						// it's a comma delimited list of media ids
						string = object as String;
						if (string.length) composites = string.split(',');
					}
					if (composites.length)
					{
						object = composites[0];
						if (object is String)
						{
							string = object as String;
							if (string.length)
							{
								imedia = RunClass.Media['fromMediaID'](string);
								if (imedia != null)
								{
									iclip = RunClass.Clip['fromMedia'](imedia);
									
									if (iclip != null) 
									{
										iclip.setValue(new Value(_getClipProperty(ClipProperty.LENGTHFRAME)), ClipProperty.LENGTHFRAME);
										iclip.track = -1;
									}
								}		
							}
						}
						else if (object is IClip)
						{
							iclip = object as IClip;
						}
					}
				}	
				if (__composited != iclip)
				{
					__unloadCompositedModule();
					__composited = iclip;
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.composited', e);
			}
			return __composited;
		}
		protected function _compositedFrame(number:Number = NaN):Number
		{
			// support looping if number is longer than composited clip's length
			if (isNaN(number)) number = _frame;
			var frames:Number = __composited.lengthFrame;
			if (frames < number)
			{
				number = ((number + frames) % frames);
			}
			return number;
		}
		protected function _defaultMatrix():void
		{
			_defaults.scale = '50,50';
			_defaults.shear = '50,50';
			_defaults.rotate = '0';
			_defaults.position = '50,50';
			_defaults.scalefade = '50,50';
			_defaults.shearfade = '50,50';
			_defaults.rotatefade = '0';
			_defaults.positionfade = '50,50';
			
		}
		protected function _setCompositedFrame(invert:Boolean = false):void
		{
			if (__composited != null)
			{
				try
				{
					var cf:Number = NaN;
					if (invert) cf = _getClipPropertyNumber(ClipProperty.LENGTHFRAME) - (_frame + 1);
					cf = _compositedFrame(cf);
					__composited.setFrame(cf);
				}
				catch(e:*)
				{
					RunClass.MovieMasher['msg'](this + '._setCompositedFrame', e);
				}
			}
		}
		protected function _setCompositedSize():void
		{
			
			if (__composited != null)
			{
				try
				{
					__composited.metrics = _size;
					_setCompositedFrame();
					_setDisplayObjectMatrix(__composited.displayObject);
				}
				catch(e:*)
				{
					RunClass.MovieMasher['msg'](this + '._setCompositedSize', e);
				}
			}
		}
		protected function _setDisplayObjectMatrix(display_object:DisplayObject):void
		{
			try
			{
				var apply_values:Object = new Object();
				var default_values:Object = new Object();
				var key:String;
				var z:uint = __transformKeys.length;
				var s:String;
				var per:Number = _getFade(_frame);
				for (var i:uint = 0; i < z; i++)
				{
					key = __transformKeys[i];
					s = _getClipProperty(key);
					if ((s != null) && s.length)
					{
						if ((i < 3) && (s.indexOf(',') == -1)) s = s + ',' + s;
						
					
						apply_values[key] = s;
						if (per != 100)
						{
							s = _getClipProperty(key + 'fade');
							if ((s != null) && s.length)
							{
								if ((i < 3) && (s.indexOf(',') == -1)) s = s + ',' + s;
								default_values[key] = s;
							}
							else default_values[key] = apply_values[key];
						}
					}
					else RunClass.MovieMasher['msg'](this + '._setDisplayObjectMatrix no value for ' + key);
				}
				__applyTransform(per, display_object, apply_values, default_values);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._setDisplayObjectMatrix ' + display_object, e);
			}
		}
		private function __applyTransform(per:Number, display_object:DisplayObject, apply_values:Object, default_values:Object):void
		{
			try
			{
				var matrix:Matrix = new Matrix();
				var tmp_matrix:Matrix = new Matrix();
				if (per != 100)
				{
					apply_values = RunClass.PlotUtility['perValues'](per, apply_values, default_values, __transformKeys);
				}
				// scale
				apply_values.scale = apply_values.scale.split(',');
				tmp_matrix.a = parseFloat(apply_values.scale[0]) / 100;
				tmp_matrix.d = parseFloat(apply_values.scale[1]) / 100;
				matrix.concat(tmp_matrix);
	
				// shear
				tmp_matrix = new Matrix();
				apply_values.shear = apply_values.shear.split(',');
				tmp_matrix.b = ((50 - parseFloat(apply_values.shear[0]))/180) * Math.PI;
				tmp_matrix.c = ((50 - parseFloat(apply_values.shear[1]))/180) * Math.PI;
				matrix.concat(tmp_matrix);
	
				// rotation
				tmp_matrix = new Matrix();
				tmp_matrix.rotate((apply_values.rotate/180) * Math.PI);
				matrix.concat(tmp_matrix);
	
				// translation
				
				display_object.alpha = apply_values.alpha/100;
				display_object.transform.matrix = matrix;
			
				var total_size:Size = _size.copy();
				total_size.width += 2 * display_object.width;
				total_size.height += 2 * display_object.height;
				
				var pt:Point = RunClass.PlotUtility['plotPoint'](apply_values.position, total_size);
				
				pt.x -= total_size.width / 2;
				pt.y -= total_size.height / 2;
			
				display_object.x = pt.x;
				display_object.y = pt.y;
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__applyTransform ' + per + ' ' + display_object + ' ' + apply_values + ' ' + default_values, e);
			}
		}
		private function __clipBuffer(event:Event):void
		{
			dispatchEvent(new Event(EventType.BUFFER));
		}
		private function __unloadCompositedModule():void
		{
			try
			{
				if (__composited != null)
				{
					if ((__composited.displayObject != null) && _displayObjectContainer.contains(__composited.displayObject))
					{
						_displayObjectContainer.removeChild(__composited.displayObject);
					}
				}
				if (__composited != null)
				{
					__composited.removeEventListener(EventType.BUFFER, __clipBuffer);
						
					__composited.playing = false;
					__composited.unload();
					__composited = null;
				}		
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__unloadCompositedModule', e);
			}
		}
		private static var __transformKeys:Array = [ModuleProperty.POSITION, 'scale', 'shear', 'rotate','alpha'];
		private var _volume:Number = 0;
		protected var __composited:IClip;
		protected var _displayObjectContainer:Sprite;
	}
}

