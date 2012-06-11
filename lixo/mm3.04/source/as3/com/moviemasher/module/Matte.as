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

package com.moviemasher.module
{
	import flash.geom.*;
	import flash.display.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
/**
* Implementation class for matte compositing transition module
*
* @see IModule
* @see Transition
* @see Mash
*/
	public class Matte extends Composite
	{
		public function Matte()
		{
			super();
		}
		override public function setFrame(clip_frame:Number):Boolean
		{
			var changed:Boolean = false;
			var sprite:Sprite = _targetSprite();
			var swap:Boolean = Boolean(_getClipPropertyNumber('swap'));
			__invertTime = false;
			if (sprite != null) __invertTime = (sprite.name == ((swap ? 'to' : 'from') + '_sprite'));

			changed = super.setFrame(clip_frame);
		
			if ((__composited != null) && (__module != null && (sprite != null)))
			{
				sprite.mask = _displayObjectContainer;
			}
		
			return changed;
		}
		override protected function _setCompositedSize():Boolean
		{ 
			var changed:Boolean = true;
			try
			{
				if ((__composited != null) && (__module != null))
				{	
					__module.metrics = _size;
					changed = _setCompositedFrame(__invertTime);
				}	
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._setCompositedSize', e);
			}
			return changed;
		}
		private var __invertTime:Boolean;
	}
}