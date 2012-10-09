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
* Doug Anarino are Copyright (C) 2007-2012 Movie Masher, Inc.
* All Rights Reserved.
*/

package com.moviemasher.module
{
	
	import com.moviemasher.interfaces.*;
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.quasimondo.geom.*;
	
/**
* Implementation class for audio pitch module.
* @see IModule
* @see Clip
* @see Mash
*/
	public class Flanger extends ModuleEffect
	{
		public function Flanger()
		{
			_defaults['depth'] = '50';
			_defaults['speed'] = '50';
			_defaults['delay'] = '50';
			_defaults['feedback'] = '50';
			_defaults['mix'] = '50';
			
			
		
		
		}
/**
* Sets current clip time for module.
* 
* Pixels in underlying tracks will be desaturated and tinted with a flat
* color. The color will be somewhere between the 'forecolor' and 'backcolor' attributes, 
* as indicated by the 'fade' attribute. If only 'forecolor' is defined, it will be
* used at all times. 
*
* @see DrawUtility
* @see PlotUtility
*/
		override public function setFrame(clip_frame:Number):void
		{
			super.setFrame(clip_frame);
			// start with forecolor attribute
			var color:Number = RunClass.DrawUtility['colorFromHex'](_getClipProperty('forecolor'));
			
			// see how much we're faded now
			var per:Number = _getFade(_frame);
			
			var pitch: Number = _getClipPropertyNumber('pitch');
			var pitchfade: Number = _getClipPropertyNumber('pitchfade');
			var cur_pitch:Number = PlotUtility.perValue(per, pitchfade, pitch);
			
			var lengthframe:Number = _getClipPropertyNumber(ClipProperty.LENGTHFRAME);
			if ((per > 100.00) || (clip_frame > lengthframe)) RunClass.MovieMasher['msg'](this + '.setFrame ' + clip_frame + ' > ' + lengthframe + ' per = ' + per + ' quantize = ' + _getQuantize() + ' fps = ' + RunClass.TimeUtility['fps']);
			if (per < 100.00)
			{
				// we are faded, so blend with backcolor
				color = RunClass.DrawUtility['blendColor'](per / 100.00, color, RunClass.DrawUtility['colorFromHex'](_getClipProperty(ModuleProperty.BACKCOLOR)));
			}
			// make sure we're not wasting time resetting the same value
			if (__color != color)
			{
				__color = color;
				
				var matrix:ColorMatrix = new ColorMatrix();
				matrix.colorize(__color);
				_moduleFilters = [matrix.filter];
			}
		}
		private const MIN_DELAY:Number = 1;// ms
		private const MAX_DELAY:Number = 10;
		private const MIN_SPEED:Number = ;
		private const MAX_SPEED:Number = ;
		private const MIN_MIX:Number = ;
		private const MAX_MIX:Number = ;
		private const MIN_FEEDBACK:Number = ;
		private const MAX_FEEDBACK:Number = ;
		private const MIN_DEPTH:Number = ;
		private const MAX_DEPTH:Number = ;
	Delay: Parameter = new Parameter( new MappingNumberLinear( 1, 10 ), 1 ); 
		public const parameterDepth: Parameter = new Parameter( new MappingNumberLinear( .2, 1 ), .8 );
		public const parameterSpeed: Parameter = new Parameter( new MappingNumberLinear( 24, .5 ), 6 ); // sec
		public const parameterFeedback: Parameter = new Parameter( new MappingNumberLinear( 0, .86 ), .2 );
		public const parameterMix
		
				
	}
}