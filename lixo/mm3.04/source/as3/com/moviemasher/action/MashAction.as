﻿/*
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

package com.moviemasher.action
{
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;

/**
* Abstract base class represents a change to an {@link IMash} object
*
* @see IMash
* @see ClipsIndexAction
* @see ClipsTimeAction
* @see ClipsValueAction
* @see ClipValuesAction
*/
	public class MashAction extends Action
	{
		
/**
* Constructs an {@link Action} object
*
* @param iMash {@link IMash} object associated with the action

*/
		public function MashAction(iMash:IMash)
		{
			super(true);
			_mash = iMash;
		}
		public function get end():Number
		{
			return _end;
		}
/**
* The {@link IMash} object associated with the action (read-only)
*
* @returns {@link IMash} object associated with the action

*/
		public function get mash():IMash
		{
			return _mash;
		}
/**
* The start time of the action (read-only)
*
* @returns Float object indicating start time

*/
		public function get start():Number
		{
			return _start;
		}
/**
* The track type of {@link IClip} items related to action (read-only)
*
* @returns String object containing a ClipType

*/
		public function get type():String
		{
			return _type;
		}
		
		
		protected var _end:Number = Number.MIN_VALUE;
		protected var _mash:IMash;
		protected var _start:Number = Number.MAX_VALUE;
		protected var _type:String = ClipType.VIDEO;
	}
}
