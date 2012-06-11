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
package com.moviemasher.preview
{

import com.moviemasher.control.Timeline;
import com.moviemasher.type.*;
import com.moviemasher.events.*;
import com.moviemasher.interfaces.*;
import com.moviemasher.type.*;
import com.moviemasher.utils.*;
import flash.display.*;
import flash.events.*;
import flash.geom.*;


	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import com.moviemasher.events.*;
	import com.moviemasher.options.*;
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.control.Browser;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.utils.*;
	import flash.display.*;

/**
* Implementation class for clip preview appearing in the timeline
*
* @see Timeline
* @see TimelineOptions
* @see IPreview
* @see IClip
* @see IModule
*/
	public class TimelinePreview extends BrowserPreview
	{
		public function TimelinePreview()
		{
		}
		override public function toString():String
		{
			var s:String = '[TimelinePreview';
			if (clip) s += ' ' + clip;
			s += ']';
			return s;
		}
		
		override public function hitTestPoint(x:Number, y:Number, shapeFlag:Boolean = false):Boolean
		{
			var boolean:Boolean = false;
			try
			{
				boolean = __mouse_mc.hitTestPoint(x, y, shapeFlag);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.hitTestPoint', e);
			}
			return boolean;
		}
		
		override public function get backBounds():Rectangle
		{
			return back_mc.getBounds(this);
		}
		
		override protected function _initialize():void
		{
			super._initialize();
			if (back_mc == null)
			{
				back_mc = new Sprite();
				addChildAt(back_mc, 0);
			}
			__createWaveform();
		}
		
		private function __createWaveform():void
		{
			if (_options.getValue('audioheight').boolean && (__waveform_mc == null))
			{
				//WAVEFORM
				__waveform_mc = new Sprite();
				addChildAt(__waveform_mc, 1);
				__waveformBitmap = new Bitmap();
				__waveform_mc.addChild(__waveformBitmap);
				__waveform_mc.blendMode = BlendMode[_options.getValue((_options.getValue(CommonWords.TYPE).equals(ClipType.AUDIO) ? '' : 'wave') + 'blend').string.toUpperCase()];
				__waveformMask = new Sprite();
				__waveform_mc.addChild(__waveformMask);
				__waveformBitmap.mask = __waveformMask;
			}
		}
		private function __drawWaveform():Boolean
		{
			var had_a_prob:Boolean = false;
			try
			{
				if (__waveform_mc != null)
				{
					__waveform_mc.visible = _data[ClipProperty.HASAUDIO];
					if (__waveform_mc.visible)
					{
						if (! (__waveWidth && __waveHeight))
						{
							var wave:String = _options.getValue('wave').string;
							if (wave.length)
							{
								__waveLoader = RunClass.MovieMasher['assetFetcher'](wave);
								if (__waveLoader.state == EventType.LOADING)
								{
									__waveLoader.addEventListener(Event.COMPLETE, __waveformLoaded, false, 0, true);
								}
								else
								{
									__waveformLoaded(null);
								}
							}
						}
						if (__waveWidth && __waveHeight) __adjustWaveform();
						else 
						{
							//__waveform_mc.visible = false;
							had_a_prob = true;
						}
					}
					
				}
			
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__drawWaveform', e);
			}
			return had_a_prob;
		}
		private function __waveformLoaded(event:Event):void
		{
			try
			{
				if ((__waveLoader != null) && (_options != null))
				{
					__waveformDisplayObject = __waveLoader.displayObject(_options.getValue('wave').string);
					if (__waveformDisplayObject != null)
					{
						__waveWidth = __waveformDisplayObject.width;
						__waveHeight = __waveformDisplayObject.height;
						__adjustWaveform();
					}
					
					if (event != null)
					{
						__waveLoader.removeEventListener(Event.COMPLETE, __waveformLoaded);
					}
					__waveLoader = null;
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__waveformLoaded ' + __waveLoader + ' ' + _options + ' ' + __waveformDisplayObject, e);
			}
			
		}
	
		
		private function __adjustWaveform()
		{
			try
			{
				var spacing:Number = _options.getValue(ControlProperty.SPACING).number;
				var y_pos:Number = 0;
				var n:Number
				n = _options.getValue('effectheight').number;
				y_pos += n;
				if (n) y_pos += spacing;
				n = _options.getValue('videoheight').number;
				y_pos += n;
				if (n) y_pos += spacing;
				
				
				
				__waveform_mc.y = y_pos;
		
				var audioheight:Number = _options.getValue('audioheight').number;
				
				
				var leftcrop:Number = _data['leftcrop'];
				var rightcrop:Number = _data['rightcrop'];
				var data_width:Number = _data['width'];
				var widthcrop:Number = data_width - (leftcrop + rightcrop);
				
				
				__waveform_mc.x = leftcrop;
				
				
				var bm : BitmapData = new BitmapData(Math.min(2880, widthcrop), audioheight, true, 0x00FF0000);
				var old_bm:BitmapData;
				
				var matrix = new Matrix();
				
				var translation : Number = 0;
				
				var item_trimstart:int = _data[ClipProperty.TRIMSTARTFRAME];
				var item_start:int = _data[ClipProperty.STARTFRAME];
				var type:String =  _options.getValue(CommonWords.TYPE).string;
				var media_pixels:Number = _data['durationpixels'];
				
				matrix.scale(media_pixels / __waveWidth, audioheight / __waveHeight);
				
				// remove trimming
				if (item_trimstart) translation -= _data['trimstranslation'];
				
				
				translation -= leftcrop; // remove cropping
		
				
				matrix.translate(translation, 0);
				var ct = new ColorTransform();
				bm.draw(__waveformDisplayObject, matrix, ct, 'normal', null, true);
				if ((type == ClipType.AUDIO) && (_options.getValue(MediaProperty.LOOP).boolean))
				{
					var z:Number = _data[ClipProperty.LOOPS];
					for (var i:Number = 1; i < z; i++)
					{
						matrix.translate(media_pixels, 0);
						bm.draw(__waveformDisplayObject, matrix, ct, 'normal', null, true);
					}
				}
				if (bm != null)
				{
					old_bm = __waveformBitmap.bitmapData;
					__waveformBitmap.bitmapData = bm;
					if (old_bm != null)
					{
						old_bm.dispose();
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__adjustWaveform', e);
			}
		}
		private function __backColor(selected : Boolean, type: String):Object
		{
			var ob:Object = new Object();
			try
			{
					
				var over:String = (selected ? 'sel' : '');
				var color:String = _options.getValue(over + 'color').string;
				ob.colorDefined = (color.length > 0);
				if (ob.colorDefined)
				{
					var grad:Number = _options.getValue(over + 'grad').number;
					var color_number:Number = RunClass.DrawUtility['colorFromHex'](color);
					if (grad > 0)
					{
						ob = RunClass.DrawUtility['gradientFill'](__w, __h, color_number, grad, _options.getValue(over + 'angle').number);
						ob.colorDefined = true;
					}
					else 
					{
						ob.flatColor = color_number;
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__backColor', e);
			}
			return ob;
		}
		
		
		override protected function _resize() : void
		{ 
			
			y = _data['y'];
			x = _data['x'];
			
			var starttrans:Number = _data['starttrans'];
			var border:Number = _options.getValue('border').number;
			
			back_mc.x = __mouse_mc.x = starttrans;
			
			
			__mask_mc.x = starttrans + border;
			__mask_mc.y = _displayObjectContainer.y = border;
			_displayObjectContainer.x = Math.max(__mask_mc.x, _data['leftcrop']);
		
		
			__w = _data['width'];
			__h = _options.getValue( _options.getValue(CommonWords.TYPE).string + 'height').number;
			
			var ratio:Number = _options.getValue('ratio').number;
				
			_iconHeight = __h - (2 * border);
			if (ratio)
			{
				_iconWidth = _iconHeight * ratio;
			}
			_drawBack();
			if (RunClass.MouseUtility['dragging']) 
			{
				__drawWaveform();
			}
			__label_mc.text = _data[MediaProperty.LABEL];
			_resizeLabel();
			_drawPreview();
			__label_mc.x = __label_back_mc.x = _displayObjectContainer.x;
		}
		override protected function _drawPreview() : Boolean 
		{
			var url:String;
			var called_resize:Boolean = true;
			try
			{
				if ((! _options.getValue(CommonWords.TYPE).equals(ClipType.AUDIO)) && __mask_mc.width)
				{
					called_resize = super._drawPreview();
				}
				if (! RunClass.MouseUtility['dragging']) 
				{
					__drawWaveform();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._drawPreview', e);
			}
			return called_resize;
		}
		override public function unload():void
		{
			try
			{
				
	
				
				
				
				
				if (__waveform_mc != null)
				{
					__waveformBitmap.mask = null;
					__waveform_mc.removeChild(__waveformMask);
					__waveform_mc.removeChild(__waveformBitmap);
					removeChild(__waveform_mc);
				}
				
				removeChild(back_mc);
				back_mc = null;
				
				__waveform_mc = null;
				__waveformBitmap = null;
				__waveform_mc = null;
				__waveformMask = null;
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.unload', e);
			}
			super.unload();
		}
		override protected function _displaySize():Size
		{
			var contentheight:Number = __h - (2 * (_options.getValue(ControlProperty.PADDING).number + _options.getValue('border').number));	
			var size:Size = new Size(Math.round(contentheight * _options.getValue('ratio').number), contentheight);
			_iconWidth = size.width;
			_iconHeight = size.height;
			return size;			
		}
		
		override protected function _drawBack():void
		{
			var c:Object;
			var is_selected:Boolean = _selected;
			var backwidth:Number = __w - (_data['starttrans'] + _data['endtrans']);
			var audio_height:Number;
			var back_alpha:Number = _options.getValue('alpha').number;
			
			var points : Array;
			var border:Number = _options.getValue('border').number;
			var bordercolor:Number;
			var spacing:Number;
			
			try
			{
			
				if (border > 0)
				{
					bordercolor = RunClass.DrawUtility['colorFromHex'](_options.getValue((is_selected ? 'sel' : '') + 'bordercolor').string);
				}
				back_mc.graphics.clear();
				
				__mouse_mc.graphics.clear();
				var curve:Number = _options.getValue('curve').number;
				
				points = RunClass.DrawUtility['points'](0, 0, backwidth, __h, curve);
				c = __backColor(is_selected,  _options.getValue(CommonWords.TYPE).string);
				if (border > 0)
				{
				
					RunClass.DrawUtility['setFill'](back_mc.graphics, bordercolor, back_alpha);
					RunClass.DrawUtility['drawPoints'](back_mc.graphics, points);
					points = RunClass.DrawUtility['points'](border, border, backwidth - (2 * border), __h - (2 * border), curve);
				}
				
			
				RunClass.DrawUtility['setFill'](__mouse_mc.graphics, 0, 0);
				if (c.colorDefined)
				{
					if (c.flatColor != null)
					{
						RunClass.DrawUtility['setFill'](back_mc.graphics, c.flatColor, back_alpha);
					}
					else
					{
						RunClass.DrawUtility['setFillGrad'](back_mc.graphics, c, back_alpha);
					}
					RunClass.DrawUtility['drawPoints'](back_mc.graphics, points);
				}
				
				
				
				RunClass.DrawUtility['drawPoints'](__mouse_mc.graphics, points);
				audio_height = _options.getValue('audioheight').number;
				if (audio_height && _data[ClipProperty.HASAUDIO] && (! _options.getValue(CommonWords.TYPE).equals(ClipType.AUDIO)))
				{
					spacing = _options.getValue(ControlProperty.SPACING).number;
					points = RunClass.DrawUtility['points'](0, __h + spacing, backwidth, audio_height, curve);
					c = __backColor(is_selected, ClipType.AUDIO);
					RunClass.DrawUtility['setFill'](__mouse_mc.graphics, 0, 0);
					
					if (border > 0)
					{
						RunClass.DrawUtility['setFill'](back_mc.graphics, bordercolor, back_alpha);
				
						RunClass.DrawUtility['drawPoints'](back_mc.graphics, points);
						points = RunClass.DrawUtility['points'](border, __h + spacing + border, backwidth - (2 * border), audio_height - (2 * border), curve);
					
					}
					if (c.colorDefined)
					{
						if (c.flatColor != null)
						{
							RunClass.DrawUtility['setFill'](back_mc.graphics, c.flatColor, back_alpha);
						}
						else
						{
							c.y = __h;
							c.height = audio_height;
							RunClass.DrawUtility['setFillGrad'](back_mc.graphics, c, back_alpha);
						}
						RunClass.DrawUtility['drawPoints'](back_mc.graphics, points);
					}
					RunClass.DrawUtility['drawPoints'](__mouse_mc.graphics, points);
				}
				if (__waveformMask != null)
				{
					__waveformMask.graphics.clear();
					if (backwidth >= 1)
					{
						var leftcrop:Number = _data['leftcrop'];
						var rightcrop:Number = _data['rightcrop'];
						var data_width:Number = _data['width'];
						var widthcrop:Number = data_width - (leftcrop + rightcrop);
				
						
						points = RunClass.DrawUtility['points'](0, 0, widthcrop, __h, curve);
						RunClass.DrawUtility['setFill'](__waveformMask.graphics, 0xFFFF00);
						RunClass.DrawUtility['drawPoints'](__waveformMask.graphics, points);
					}
				}
				
				__mask_mc.graphics.clear();				
				backwidth -= (2 * border);
				if (backwidth >= 1)
				{
					
					points = RunClass.DrawUtility['points'](0, 0, backwidth, __h - (2 * border), curve);
					RunClass.DrawUtility['setFill'](__mask_mc.graphics, 0xFFFF00);
					RunClass.DrawUtility['drawPoints'](__mask_mc.graphics, points);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._drawBack', e);
			}	
		}
		private var __displayObject:DisplayObject;
		private var __h : Number = 0;
		private var __highestFrameClip : Number = -1;
		private var __waveform_mc : Sprite; 
		private var __waveformBitmap:Bitmap;
		private var __waveformDisplayObject:DisplayObject;
		private var __waveformMask:Sprite;
		private var __waveHeight : Number = 0;
		private var __waveLoader:IAssetFetcher;
		private var __waveWidth : Number = 0;
		private var __w : Number = 0;
		private var back_mc : Sprite; // background for whole clip (will be rounded edge if possible)
	}
}