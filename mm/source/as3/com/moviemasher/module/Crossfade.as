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
	import com.moviemasher.interfaces.*;

/**
* Implementation class for crossfade transition module
*
* @see IModule
* @see Transition
* @see Mash
*/
	public class Crossfade extends ModuleTransition
	{
		public function Crossfade()
		{
		}
		
		override public function setFrame(clip_frame:Number):void
		{
			super.setFrame(clip_frame);
			try
			{
				var done:Number = _clipCompleted(clip_frame);
				/*
				var transition_to:Sprite = parent.parent.getChildByName('transition_to') as Sprite;
				var transition_from:Sprite = parent.parent.getChildByName('transition_from') as Sprite;
				
				
				var sprite:Sprite = transition_to;
				if (sprite == null)
				{
					sprite = transition_from;
					done = 1 - done;
				}
				if (sprite != null)
				{
				*/
					var colortransform:ColorTransform = new ColorTransform();
					/*if ((sprite == transition_to) && (transition_from != null))
					{
						transition_from.transform.colorTransform = new ColorTransform();
					}
					*/
					colortransform.alphaMultiplier = done;
					_transitionColorTransform = colortransform;
					
				//}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.Crossfade.setFrame ' + parent, e);
			}
		}
	}
}