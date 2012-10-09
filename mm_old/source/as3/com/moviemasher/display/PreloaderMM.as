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
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	
/**
* Implementation class represents a Movie Masher logo animation with progress bar
*
* @see MovieMasher
*/
	public class PreloaderMM extends Preloader
	{
		public function PreloaderMM()
		{
			if (_logo && _progress) 
			{
				addChild(_logo);
				addChild(_progress);
				_logo.width = _progress.width;
				_logo.scaleY = _logo.scaleX;
				_progress.y = _logo.height + 10;
			}		
		}
		
		override protected function _update():void
		{
			// do something with _preloaded value
			if ((_progress != null) && (_progress.mask_mc != null))
			{
				_progress.mask_mc.width = Math.round(width * _preloaded);
			}
		}
		protected var _progress:Progress = new Progress();
		protected var _logo:Logo = new Logo();
	}
}