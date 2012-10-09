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
* Doug Anarino are Copyright (C) 2007-2012 Movie Masher, Inc.
* All Rights Reserved.
*/

package com.moviemasher.constant
{
/**
* Static class contains Class constants for many runtime classes. Use these references to avoid
* having to compile in the classes themselves, if you're sure they will be available at runtime. 
* The constants here are set as SWFs are loaded and some may never be set, depending on the 
* supplied configuration. 
* @see MoviemasherStage
* @see PlayerStage
* @see EditorStage
*/
	public class SourceClass
	{

/**
* {@link com.moviemasher.source.LocalSource}
*/
		public static var LocalSource:Class;

/**
* {@link com.moviemasher.utils.RemoteSource}
*/
		public static var RemoteSource:Class;
/**
* {@link com.moviemasher.source.Source}
*/
		public static var Source:Class;
	}
}
