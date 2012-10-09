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
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;

/**
* Implementation class for image sequence based video module
*
* @see IModule
* @see IClip
*/
	public class AVFrame extends AVSequence
	{
		public function AVFrame()
		{
			_defaults.frame = '0';
		}
		override public function buffer(first:Number, last:Number, mute:Boolean):void
		{
			//RunClass.MovieMasher['msg'](this + '.buffer ' + first + '->' + last);
			var frame:Number = __getFrame();
			super.buffer(frame, frame, true); // always muted
		}
		override public function buffered(first:Number, last:Number, mute:Boolean):Boolean
		{
			var frame:Number = __getFrame();
			return super.buffered(frame, frame, true); // always muted
		}
		override public function unbuffer(first:Number = -1, last:Number = -1):void
		{
			var frame:Number = __getFrame();
			super.unbuffer(frame, frame); 
		}
		override public function setFrame(clip_frame:Number):void
		{
			var frame:Number = __getFrame();
			super.setFrame(frame);
		}	
		private function __getFrame():Number
		{
			var frame:Number = _getClipPropertyNumber('frame');
			var quantize:Number = _getQuantize();
			var fps:Number = media.getValue(MediaProperty.FPS).number;
			var converted_frame = RunClass.TimeUtility['convertFrame'](frame, fps, quantize, ''); 
			//RunClass.MovieMasher['msg'](this + '.__getFrame ' + converted_frame + ' = ' + frame + ' ' + fps + ' ' + quantize);
			return converted_frame;
		}

	}
}