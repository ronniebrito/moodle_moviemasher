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
* Static class contains String constants related to resource fetching.
*/
	public class EventType
	{
/** 
* Resources have been at least partially fetched.
*/
		public static const BUFFER:String = 'buffer';
/** 
* An error occured while fetching resources.
*/
		public static const ERROR:String = 'error';
/** 
* Resources have been fully fetched.
*/
		public static const LOADED:String = 'loaded';
/** 
* Resources are still being fetched.
*/
		public static const LOADING:String = 'loading';
/** 
* Fetching of resources has caused playback to pause.
*/
		public static const STALL:String = 'stall';
	}
}
