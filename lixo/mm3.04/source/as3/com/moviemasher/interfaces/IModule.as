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

package com.moviemasher.interfaces
{
	import flash.display.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;

/**
* Interface for all modules (things that are displayed in a {@link Player}).
*
* @see Clip
* @see Mash
*/
	public interface IModule extends IValued, IMetrics
	{
/**
* Indication that module will soon need to display itself.
* 
* @param first int containing first frame
* @param last int containing last frame
* @param mute Boolean object indicating whether or not sound is needed.
* @param rebuffer Boolean object indicating whether or not this module playing at both the start and end of mash.
*/
		function buffer(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):void;
/**
* See whether or not a time range is loaded and ready for display.
* 
*
* @param first int containing first frame
* @param last int containing last frame
* @param mute Boolean object indicating whether or not sound is needed.
* @param rebuffer Boolean object indicating whether or not this module playing at both the start and end of mash.
* @returns Boolean true if range is buffered.
*/
		function buffered(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):Boolean;
/**
* Marks assets for partial unloading
* 
* If the module has loaded external media through the {@link LoadManager} it 
* should unbuffer it during this call.
*  
* @param first int containing first frame
* @param last int containing last frame
*/
		function unbuffer(first:Number = -1, last:Number = -1):void;
/**
* Marks assets for complete unloading
* 
*/
		function unload():void;
/**
* Called if instance is icon of Browser or Timeline preview
* 
*/
		function set runningAsPreview(options:IPreview):void;
/**
* Called if instance is icon of Browser or Timeline preview and it's selected
* 
*/
		function set animating(tf:Boolean):void
/**
* Current clip time for module (read/write).
* 
* Zero indicates the start of the clip. 
*/
		
		function getFrame():Number;
		function setFrame(clip_frame:Number):Boolean;
/**
* Changes playback state (write only).
*/
		function set playing(iBoolean:Boolean):void;
/**
* Changes playback volume (write only).
*/
		function set volume(iNumber:Number):void;
/**
* Sets associated {@link Clip} (write only).
* 
* The pointer sent can be cast to an {@link IClip} or {@link Clip} pointer if desired.
* {@link IPropertied} is used here to minimize compile size. 

*/
		function set clip(iClip:IClip):void;
		function get keepsTime():Boolean;
		
	}
}