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

package com.moviemasher.constant
{
	
/** 
* Static class contains String constants for supported methods of resizing visuals 
* within dimensions having a different aspect ratio.
*/
	public class FillType
	{
/** 
* The visual is resized to fit the dimensions exactly, potentially stretching.
*/
		public static const STRETCH:String = 'stretch';
/** 
* The visual is resized as much as is needed to completely fill the dimensions, potentially cropping.
*/
		public static const CROP:String = 'crop';
/** 
* The visual is resized as much as is need to display all of it, potentially exposing 
* underlying visuals or background color.
*/
		public static const SCALE:String = 'scale';
	}
}
