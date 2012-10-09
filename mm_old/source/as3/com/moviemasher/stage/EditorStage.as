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
package com.moviemasher.stage
{
	import com.moviemasher.constant.*;
	import com.moviemasher.control.*;
	import com.moviemasher.preview.*;
	import com.moviemasher.utils.*;
	import flash.display.*;
/**
* Implementation class for editor SWF root object
*/
	public class EditorStage extends MovieClip
	{
		function EditorStage()
		{ 
			RunClass.BrowserPreview = BrowserPreview;
			RunClass.DragUtility = DragUtility;
		}
		private static  var __needsBrowser:Browser;
		private static  var __needsField:Field;
		private static  var __needsPicker:Picker;
		private static  var __needsPlotter:Plotter;
		private static  var __needsRuler:Ruler;
		private static  var __needsScrollbar:Scrollbar;
		private static  var __needsTimeline:Timeline;
		private static  var __needsTrimmer:Trimmer;
		
	}
}