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
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
/**
* Interface represents a mash clip.
* 
* @see Clip
* @see Mash
*/
	public interface IClip extends IPlayable
	{
/**
* Causes loading of clip assets.
* 
* @param first int containing first frame
* @param last int containing last frame
* @param mute Boolean object indicating whether or not sound is needed
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
* Translates {@link Mash} frame to {@link Clip} frame.
* 
* @param frame int object containing {@link Mash} frame
* @returns int object containing {@link Clip} frame
*/
		function clipTime(frame:Number):Number; 
/**
* Copies clip by instancing from tag.
* 
* @returns IClip copy of target
*/
	function clone():IClip;
/**
* Whether or not the clip should appear on the visual track.
* 
* @returns Boolean true if clip is {@link Video}, {@link Image} or {@link Transition} 
*/
		function isVisual():Boolean;


/**
* Allows access to the {@link IMedia} object of target.
* 
* @returns a pointer to the object.
*/
		function get media():IMedia;


/**
* Allows access to the {@link IMash} object of target.
* 
* @returns a pointer to the object.
*/
		function get mash():IMash;

/**
* Translates {@link Clip} frame to {@link Mash} frame.
* 
* @param frame int object containing {@link Clip} frame
* @returns int object containing {@link Mash} frame
*/
function projectTime(frame:Number):Number;
/**
* Sets a property that might change the length of the clip.
* 
* @param property String containing the name of the property being changed
* @param value {@link Value} object containing new value for property
* @returns Boolean true if clip length was actually changed
* @see ClipsValueAction
* @see ClipValuesAction
*/

function referencedMedia(object:Object):void;

	//	function setPropertyChangedLength(property:String, value:Value):Boolean;
/**
* Marks assets for partial unloading
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
* Calculates {@link Clip} volume for a given time and global volume level.
* 
* @param project_time Float containing {@link Mash} time intersecting with clip
* @param percent Float containing global volume level, zero to a hundred
* @returns Float containing volume level, zero to one
* @see Mash
*/
		function volumeFromTime(project_time:Number, percent:Number):Number;	
/**
* The {@link IModule} instance associated with this clip (read-only).
* 
* @see AVAudio
* @see AVImage
* @see AVMash
* @see AVSequence
* @see AVVideo
*/
		function get module():IModule;
/**
* Boolean indicating whether or not the clip should be trying to play (write-only).
*/
		function set playing(iBoolean:Boolean):void;
/**
* Float indicating current {@link Mash} time (read-write)
*/
		function getFrame():Number;

		function setFrame(clip_frame:Number):Boolean;
		function get canTrim():Boolean;
		function set metrics(iMetrics:Size):void;
		function get index():int;
		function set index(value:int):void;
		function get track():int;
		function set track(value:int):void;
		function get startPadFrame():Number;
		function set startPadFrame(value:Number):void;
		function get endPadFrame():Number;
		function set endPadFrame(value:Number):void;
		function get startFrame():Number;
		function set startFrame(value:Number):void;
		
		function get lengthFrame():Number;
		function get type():String;
		function get keepsTime():Boolean;
		
	}
}
