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
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import flash.display.*;
	
/**
* Implementation class for cube transition module
*
* @see IModule
* @see Transition
* @see Mash
*/
	public class Cube extends Module
	{

		private var __mask_mc:Sprite;

		public function Cube()
		{
			_defaults.direction = '0';
			__mask_mc = new Sprite();
			addChild(__mask_mc);
		}
		
		override public function setFrame(clip_frame:Number):Boolean
		{
			var changed:Boolean = super.setFrame(clip_frame);
			try
			{
				var direction:String = _getClipProperty('direction');
				var done:Number = _clipCompleted(clip_frame);
	
				var bmwidth = _size.width / 2;
				var bmheight = _size.height / 2;
	
				var frame_data:Object = new Object();
				frame_data.x = - bmwidth;
				frame_data.y = - bmheight;
				
				frame_data.w = _size.width;
				frame_data.h = _size.height;
				
				var not_done : Number = 1 - done;
				var left_matrix:Matrix = new Matrix();
				var right_matrix:Matrix = new Matrix();
				
				var from_sprite:Sprite = getChildByName('from_sprite') as Sprite;
				var to_sprite:Sprite = getChildByName('to_sprite') as Sprite;
			
				var wORh:String = 'w';
				var xORy:String = 'x';
				var amount:Number = 0;
				switch (direction)
				{
					case 'right':
					case '0':
						//RIGHT
						amount = ((to_sprite == null) ? _size.width : 0);
						break;
					case 'left':
					case '1' :
						// LEFT
						amount = ((to_sprite == null) ? 0 : _size.width);
						break;
					case 'up':
					case '3' :
						// BOTTOM
						xORy = 'y';
						wORh = 'h';
						amount = ((to_sprite == null) ? 0 : _size.height);
						break;
					case 'down':
					case '2' :
						// TOP
						amount = ((to_sprite == null) ? _size.height : 0);
						xORy = 'y';
						wORh = 'h';
						break;
				}
				
				frame_data[wORh] *= ((to_sprite == null) ? not_done : done);
				if (amount) frame_data[xORy] += amount * ((to_sprite == null) ? done : not_done);
				
				if (wORh == 'w')
				{
					left_matrix.scale(not_done, 1);
					right_matrix.scale(done, 1);
				}
				else
				{
					left_matrix.scale(1, not_done);
					right_matrix.scale(1, done);
				}
				switch (direction)
				{
					case 'right':
					case '0' :// LEFT
						left_matrix.translate(bmwidth * done, 0);
						right_matrix.translate(- bmwidth * not_done, 0);
						break;
					case 'left':
					case '1' :// RIGHT
						left_matrix.translate(- bmwidth * done, 0);
						right_matrix.translate(bmwidth * not_done, 0);
						break;
					case 'down':
					case '2' :// TOP
						left_matrix.translate(0, bmheight * done);
						right_matrix.translate(0, - bmheight * not_done);
						break;
					case 'up':
					case '3' :// BOTTOM
						left_matrix.translate(0, - bmheight * done);
						right_matrix.translate(0, bmheight * not_done);
						break;
				}
				var masked_sprite:Sprite;
				
				if (from_sprite != null)
				{
					from_sprite.transform.matrix = left_matrix;
					masked_sprite = from_sprite;
				}
				if (to_sprite != null)
				{
					to_sprite.transform.matrix = right_matrix;
					masked_sprite = to_sprite;
				}
				if (masked_sprite != null)
				{
					__mask_mc.graphics.clear();
					RunClass.DrawUtility['fillBox'](__mask_mc.graphics, frame_data.x, frame_data.y, frame_data.w, frame_data.h, 0xFFFF00);
					masked_sprite.mask = __mask_mc;
	
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.frame caught ' + e);
			}
			return changed;
		}
	}

}