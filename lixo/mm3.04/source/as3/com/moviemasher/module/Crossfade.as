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
	import flash.geom.ColorTransform;
	import flash.display.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;

/**
* Implementation class for crossfade transition module
*
* @see IModule
* @see Transition
* @see Mash
*/
	public class Crossfade extends Module
	{
		public function Crossfade()
		{
		}
		
		override public function setFrame(clip_frame:Number):Boolean
		{
			
			var changed:Boolean = super.setFrame(clip_frame);
			var done:Number = _clipCompleted(clip_frame);
			var to_sprite:Sprite = getChildByName('to_sprite') as Sprite;
			var from_sprite:Sprite = getChildByName('from_sprite') as Sprite;
			
			
			var sprite:Sprite = to_sprite;
			if (sprite == null)
			{
				sprite = from_sprite;
				done = 1 - done;
			}
			if (sprite != null)
			{
				var colortransform:ColorTransform = new ColorTransform();
				if ((sprite == to_sprite) && (from_sprite != null))
				{
					from_sprite.transform.colorTransform = new ColorTransform();
				}
				colortransform.alphaMultiplier = done;
				sprite.transform.colorTransform = colortransform;
				
			}
			return changed;
		}
	}
}