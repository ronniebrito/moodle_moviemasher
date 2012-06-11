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
	import flash.utils.*;
	
/**
* Interface for certain mash functionality.
* 
* These are just the methods called by objects defined outside Player SWF. 
* 
* @see Mash
* @see IClip
*/
	public interface IMash extends IPlayer, IModule, ISelectable
	{
/**
* Searches mash for all clips within time range, ignoring track placement.
* 
* @param first int containing first frame
* @param last int containing last frame
* @returns Array of {@link IClip} objects within range
* @see Mash
* @see Decoder
*/
		function clipsInRange(first:Number, last:Number):Array;
/**
* Searches mash for audio or effect clips within time and track range.
* 
* @param first int containing first frame
* @param last int containing last frame
* @param ignore Array of {@link IClip} objects to exclude
* @param track int containing first track number
* @param count int containing number of tracks to search
* @returns Array of {@link IClip} objects within ranges
* @see Mash
* @see Timeline
* @see Clip
*/
		function clipsInOuterTracks(first:Number, last:Number, ignore:Array = null, track:int = 0, count:int = 0, type:String = ''):Array;
/**
* Searches mash for all clips of a type within time and track range.
* 
* @param first int containing first frame
* @param last int containing last frame
* @param type String containing ClipType
* @param transitions Boolean true to exclude visual clips within transitions
* @param track int containing first track number
* @param count int containing number of tracks to search
* @returns Array of {@link IClip} objects within ranges
* @see Mash
* @see Timeline
* @see Clip
*/
		function clipsInTracks(first:Number, last:Number, type:String, transitions:Boolean = false, track:int = 0, count:int = 0):Array;		
/**
* Searches mash for best start time on an audio or effect track, avoiding collision.
* 
* @param first int containing first frame
* @param last int containing last frame
* @param type String containing ClipType.AUDIO or ClipType.EFFECT
* @param ignore Array of {@link IClip} objects to exclude
* @param track int containing first track number
* @param count int containing number of tracks to search
* @returns Number containing start time
*/
		function freeTime(first:Number, last:Number, type:String = '', ignore:Array = null, track:int = 0, count:int = 0):Number;
/**
* Searches mash for best track for audio or effect tracks within range, avoiding collision.
* 
* @param first int containing first frame
* @param last int containing last frame
* @param type String containing ClipType.AUDIO or ClipType.EFFECT
* @param count int containing number of tracks to search
* @returns Number containing track
*/
		function freeTrack(first:Number, last:Number, type:String, count:uint):uint;
		function invalidateLength(type:String, dont_dirty:Boolean = false):void;
		function referencedMedia():Object;
		function get tracks():Object;

		function get lengthFrame():Number;
		function gotoFrame(n:Number):Boolean;
		
	}
}