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
	import flash.display.*;
	import flash.geom.*;
	import com.moviemasher.constant.*;
/**
* Interface represents a {@link TransitionClip} within a {@link Mash}
* 
* @see IClipTransition
* @see IMash
*/
	public interface IClipTransition extends IClipEffect
	{
/**
* Array of filter objects to apply to the clip appearing after receiver
* 
* @see MaskedSprite
*/	
		function get transitionFilters():Array;	
/**
* Matrix object to apply to the clip appearing after receiver
* 
* @see MaskedSprite
*/	
		function get transitionMatrix():Matrix;
/**
* ColorTransform object to apply to the clip appearing after receiver
* 
* @see MaskedSprite
*/	
		function get transitionColorTransform():ColorTransform;
/**
* DisplayObject to mask the clip appearing after receiver
* 
* @see MaskedSprite
*/	
		function get transitionMask():DisplayObject;
	}
}
