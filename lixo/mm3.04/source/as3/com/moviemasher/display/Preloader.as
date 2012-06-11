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
package com.moviemasher.display
{
	import flash.display.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
/**
* Abstract base class represents a simple loading animation that plays while initial assets load
*
* @see MovieMasher
* @see IPreloader
*/
	public class Preloader extends MovieClip implements IPreloader
	{
		public function Preloader()
		{
				
		}
		public function set metrics(iMetrics:Size):void
		{
			_size = iMetrics;
			_resize();
		}
		public function get metrics():Size
		{
			return _size;
		}
		public function get displayObject():DisplayObjectContainer
		{
			return this;
		}
		public function set preloaded(n : Number):void
		{
			_preloaded = n;
			_update();
		}
		protected function _resize():void
		{
			x = Math.round((_size.width - width) / 2);
			y = Math.round((_size.height - height) / 2);
		}
		protected function _update():void
		{
			// do something with _preloaded value
		}
		protected var _size:Size;
		protected var _preloaded:Number;
		
			
	}
}