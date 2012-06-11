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

package com.moviemasher.type
{

	import com.moviemasher.interfaces.*;
	import flash.display.*;
	import flash.geom.*;
/**
* Class representing previews dragged around in the timeline and browser controls
*/
	public class DragData extends Object
	{
		public function DragData()
		{
			rootPoint = new Point();
			items = new Array();
		}
		public var callback:Function;
		public var previewCallback:Function;
		public var display:DisplayObjectContainer;
		public var dragged:Boolean;
		public var items:Array;
		public var local:Boolean;
		public var rootPoint:Point;
		public var clickPoint:Point;
		public var source:DisplayObject;
		public var target:IDrop;
	}
	
}