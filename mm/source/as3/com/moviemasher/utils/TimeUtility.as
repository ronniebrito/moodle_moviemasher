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

package com.moviemasher.utils
{
/**
* Static class provides frame/time conversion functions
*/
	public class TimeUtility
	{
		public static var fps:int = 0;
		
		public static function frameFromTime(time:Number, rate:int = 0, rounding:String = 'round'):Number
		{
			if (! rate) rate = fps;
			time = time * Number(rate);
			if (rounding.length) time = Math[rounding](time);
			return time;
		}
		public static function timeFromFrame(frame:Number, rate:int = 0):Number
		{
			if (! rate) rate = fps;
			return frame / Number(rate);
		}
		public static function convertFrame(frame:Number, from_rate:int = 0, to_rate:int = 0, rounding:String = 'round'):Number
		{
			if (! to_rate) to_rate = fps;
			if (! from_rate) from_rate = fps;
			if (from_rate == to_rate) 
			{
				if (rounding.length) frame = Math[rounding](frame);
			}
			else frame = frameFromTime(timeFromFrame(frame, from_rate), to_rate, rounding);
			return frame;	
		}
	}
}
