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
	import flash.geom.*;
	
	public interface IPreview extends IDisplay
	{
		//READ
		function get backBounds():Rectangle;
		function get size():Size;
		
		// WRITE
		function set selected(value:Boolean):void;
		
		//  ACCESSORS READ+WRITE
		function get clip():IClip;
		function set clip(iclip:IClip):void;
		function get mediaTag():XML;
		function set mediaTag(xml:XML):void;
		function get container():IPreviewContainer;
		function set container(previewContainer:IPreviewContainer):void;
		function get options():IOptions
		function set options(iOptions:IOptions):void;
		function set data(object:Object):void;
		function get data():Object;
		// METHODS
		function unload():void;
	}
}