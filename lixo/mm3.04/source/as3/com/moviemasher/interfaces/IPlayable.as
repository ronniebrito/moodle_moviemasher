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
	public interface IPlayable extends ISelectable
	{

/**
* Whether or not the target outputs audio data.
* 
* @returns Boolean true if target makes some sort of noise.
*/
		function get audioIsPlayable():Boolean;
		

/**
* Whether or not the target outputs audio data as ByteArray.
* 
* @returns Boolean true if clip is MP3 {@link Audio}.
*/
		function get audioIsExtractable():Boolean;
		
		
	}
}
