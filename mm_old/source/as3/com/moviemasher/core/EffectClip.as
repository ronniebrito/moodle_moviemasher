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

package com.moviemasher.core
{
	import com.moviemasher.events.*;
	import com.moviemasher.display.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.system.*;
	import flash.utils.*;

/**
* Implementation class represents an instance of a {@link IMedia} item, usually within a mash.
* 
* @see IClip
*/
	public class EffectClip extends Clip implements IClipEffect
	{
		public function EffectClip(type:String, media:IMedia, mash:IMash = null)
		{
			super(type, media, mash);
			
		}
		public function get clipMatrix():Matrix
		{
			var module_matrix:Matrix = null;
			var effect:IModuleEffect;
			if ((_module != null) && (_module is IModuleEffect))
			{
				effect = _module as IModuleEffect;
				module_matrix = effect.moduleMatrix;
			}
			return module_matrix;
		}
		public function get clipColorTransform():ColorTransform
		{
			// should only be called on effects!!
			var module_transform:ColorTransform = null;
			var effect:IModuleEffect;
			if ((_module != null) && (_module is IModuleEffect))
			{
				effect = _module as IModuleEffect;
				module_transform = effect.moduleColorTransform;
			}
			return module_transform;
		
		}
		public function get clipFilters():Array
		{
			// should only be called on effects!!
			var module_filters:Array = null;
			var effect:IModuleEffect;
			if ((_module != null) && (_module is IModuleEffect))
			{
				effect = _module as IModuleEffect;
				module_filters = effect.moduleFilters;
			}
			return module_filters;
		}	
	}
}
