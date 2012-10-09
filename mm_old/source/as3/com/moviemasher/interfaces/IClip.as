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
	import com.moviemasher.constant.*;
	import com.moviemasher.type.*;
	import flash.display.*;
	import flash.geom.*;
/**
* Interface represents a {@link Clip} within a {@link Mash}
* 
* @see IClip
* @see IMash
*/
	public interface IClip extends IValued, IPlayable, IBuffered
	{
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
* Sets a property that might change the length of the clip.
* 
* @param property String containing the name of the property being changed
* @param value {@link Value} object containing new value for property
* @returns Boolean true if clip length was actually changed
* @see ClipsValueAction
* @see ClipValuesAction
*/

		function referencedMedia(object:Object):void;

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
		
		

		function get canTrim():Boolean;
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
		
	}
}
