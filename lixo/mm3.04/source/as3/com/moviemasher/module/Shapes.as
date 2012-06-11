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
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.utils.*;

/**
* Implementation class for generating various vector animations
*
* @see IModule
* @see Clip
* @see Mash
*/
	public class Shapes extends Module
	{

		public function Shapes()
		{
			_defaults.map = 'rects';
			_defaults.instances = '5';
			_defaults.orientation = 'vertical';
			_defaults.forecolor = 'FFFFFF';
			_defaults.backcolor = '000000';
			_defaults.fade = Fades.IN;
			_defaults.alpha = '100';
			_defaults.curve = '0';
			__canvas = new Shape();
			addChild(__canvas);
		}

		override public function backColor():String
		{
			return _getClipProperty(ModuleProperty.BACKCOLOR);
		}
		override public function setFrame(clip_frame:Number):Boolean
		{
			var changed:Boolean = super.setFrame(clip_frame);
			if (_size == null) return false;
			try
			{
				__canvas.graphics.clear();
				var map:String = _getClipProperty('map');
				if (typeof(this['__' + map + 'Map']) == 'function')
				{
					this['__' + map + 'Map'](_getFade(clip_frame));
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.setFrame = ' + clip_frame, e);
			}
			return changed;
		}
		private function __rectsMap(per:Number):void
		{
			try
			{
				var forecolor:Number = RunClass.DrawUtility['colorFromHex'](_getClipProperty('forecolor'));
				var done:Number = (per / 100);
				var instances:int = _getClipPropertyNumber('instances');
				
				
				var offset_x:Number = - (_size.width / 2) / instances;
				var offset_y:Number = - (_size.height / 2) / instances;
				var offset_x2:Number = offset_x * done;
				var offset_y2:Number = offset_y * done;
				offset_x -= offset_x2;
				offset_y -= offset_y2;

				var rect:Rectangle = new Rectangle(- _size.width / 2, - _size.height / 2, _size.width, _size.height);
				var alpha:Number = _getClipPropertyNumber('alpha');
				var curve:Number =  _getClipPropertyNumber('curve');
				
				RunClass.DrawUtility['setFill'](__canvas.graphics, forecolor, alpha);
				var points:Array;
				for (var i:Number = 0; i < instances; i++)
				{
					if (rect.isEmpty()) break;
					rect.inflate(offset_x, offset_y);
					RunClass.DrawUtility['drawPoints'](__canvas.graphics, RunClass.DrawUtility['points'](rect.x, rect.y, rect.width, rect.height, curve), true);
					rect.inflate(offset_x2, offset_y2);
					points = RunClass.DrawUtility['points'](rect.x, rect.y, rect.width, rect.height, curve);
					points.reverse();
					if (curve) 
					{
						for (var j:uint = 0; j < points.length; j++)
						{
							points[j].type = ((points[j].type == 'curve') ? '' : 'curve');
						}
					}
					RunClass.DrawUtility['drawPoints'](__canvas.graphics, points, true, true);
				}
				__canvas.graphics.endFill();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__rectsMap = ' + per, e);
			}
		}
		private function __rectMap(per:Number):void
		{
			try
			{
				var done:Number = 1 - (per / 100);
				var forecolor:Number = RunClass.DrawUtility['colorFromHex'](_getClipProperty('forecolor'));
				var w:Number = _size.width / 2;
				var h:Number = _size.height / 2;
				var rect:Rectangle = new Rectangle(0, 0, _size.width, _size.height);
				rect.offset(-w, - h);
				rect.inflate(-w * done, -h * done);
				RunClass.DrawUtility['fillBox'](__canvas.graphics, rect.x, rect.y, rect.width, rect.height, forecolor, _getClipPropertyNumber('alpha'));
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__rectMap = ' + per, e);
			}
		}
		private function __circleMap(per:Number):void
		{
			try
			{
				
				var done:Number = per / 100;
				var forecolor:Number = RunClass.DrawUtility['colorFromHex'](_getClipProperty('forecolor'));
				var distance:Number = Point.distance(new Point(0,0), new Point(_size.width / 2, _size.height /2));
				distance = Math.max(1, Math.round(distance * done));
				RunClass.DrawUtility['setFill'](__canvas.graphics, forecolor, _getClipPropertyNumber('alpha'));
				var offset_x:Number = 0;
				var offset_y:Number = 0;
				
				__canvas.graphics.drawCircle(offset_x, offset_y, distance);
				__canvas.graphics.endFill();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__circleMap = ' + per + ' caught ' + e);
			}
		}
		private function __barsMap(per:Number):void
		{
			
			try
			{
				
				var done:Number = per / 100;
				var instances:Number = _getClipPropertyNumber('instances');
				var is_horz:Boolean = (_getClipProperty('orientation') == 'horizontal');
				var space:Number = _size[(is_horz ? 'width' : 'height')];
				var w:Number = (is_horz ? Math.max(1, ((_size.width / instances) * per) / 100 ) : _size.width);
				var h:Number = (is_horz ? _size.height : Math.max(1, ((_size.height / instances) * per) / 100 ));
				var forecolor:Number = RunClass.DrawUtility['colorFromHex'](_getClipProperty('forecolor'));
				var offset_x:Number = (is_horz ? (space / instances) : 0);
				var offset_y:Number = (is_horz ? 0 : (space / instances));
				var alpha:Number = _getClipPropertyNumber('alpha');
				var rect:Rectangle = new Rectangle(- _size.width / 2, - _size.height / 2, w, h);
				for (var i:Number = 0; i < instances; i++)
				{
					RunClass.DrawUtility['fillBox'](__canvas.graphics, rect.x, rect.y, rect.width, rect.height, forecolor, alpha, 0, true);
					rect.offset(offset_x, offset_y);
				}
				__canvas.graphics.endFill();
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__barsMap = ' + per + ' ' + _size,  e);
			}
		}
		private var __canvas:Shape;
	}

}