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

package com.moviemasher.action
{
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	
/**
* Implimentation class represents splitting a video clip into two and inserting a frame clip
*
* @see Action
* @see IClip
*/
	public class ClipFreezeAction extends ClipSplitAction
	{

		public function ClipFreezeAction(clip:IClip, frame:Number)
		{
			var clip_xml:XML;
			var converted_frame:Number;
			var quantize:Number = clip.mash.getValue('quantize').number;
			
			clip_xml = clip.tag.copy();
			
			converted_frame = RunClass.TimeUtility['convertFrame'](clip.clipTime(frame), quantize, clip.media.getValue(MediaProperty.FPS).number, '');
			clip_xml.@type = ClipType.FRAME;
			clip_xml.@frame = converted_frame;
			clip_xml.@length = RunClass.TimeUtility['frameFromTime'](RunClass.MovieMasher['getOption']('mash', 'frameseconds'), quantize, '');
			delete clip_xml.@[ClipProperty.TRIMENDFRAME];
			delete clip_xml.@[ClipProperty.TRIMSTARTFRAME];
			delete clip_xml.@[ClipProperty.SPEED];
			
			__freezeClip = RunClass.Clip['fromXML'](clip_xml, clip.mash, clip.media);
			super(clip, frame);
		}
		override protected function _redo():void
		{ 
			super._redo();
			var track:String = ClipType.VIDEO;
			var index:int = _clip.index;
			_mash.tracks[track].splice(index + 1, 0, __freezeClip);
			__freezeClip.setValue(new Value(_mash), ClipProperty.MASH);
			_mash.invalidateLength(track);

		}
		override protected function _undo():void
		{ 
			var track:String = ClipType.VIDEO;
			var index:int = _clip.index;
			
			__freezeClip.setValue(new Value(), ClipProperty.MASH);
			_mash.tracks[track].splice(index + 1, 1);

			super._undo();
		}
		
		private var __freezeClip:IClip;
	}
}