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
	import flash.geom.*;
	import flash.utils.*;
	import flash.display.*;
	import flash.events.*;
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.preview.*;
	
/**
* Class represents PANEL tag, containing bars and controls
*
* @see BarView
* @see ControlView
*/
	public class PanelView extends View
	{
		
		public function PanelView()
		{
			__children = new Array();
			_defaults = __panelDefaults;
		}
		
		public static  var controls : Object = new Object();
		private static  var __panelDefaults : Object = {angle: '90', border: '0', bordercolor: '0', curve: '0', grad: '0', height: '*', padding: '0', width: '*', x: '0', y: '0', alpha:'100'};

		public function delayedDraw():void
		{
			if (__laterInterval == null)
			{
				__laterInterval = new Timer(1, 1);
				__laterInterval.addEventListener(TimerEvent.TIMER, __callResize, false, 0, true);
				__laterInterval.start();
			}
		}
		
		private function __callResize(event:TimerEvent):void
		{
			resize();
		}
		override public function resize():void
		{		
			
			if (__laterInterval != null)
			{
				__laterInterval.stop();
				__laterInterval.removeEventListener(TimerEvent.TIMER, __callResize);
				__laterInterval = null;
			}
			_resizeView();
		
			
			__setContentSize();



		}

		override protected function _parseTag():void
		{
			try
			{
				super._parseTag();
				var bars : XMLList = _tag.bar;
				var z:int;
				var i:int;
				var bar:BarView;
				
				z = bars.length();
				if (z > 0)
				{
					for (i = 0; i < z; i++)
					{
						bar = new BarView(this);
						
						__children.push(bar);
						bar.tag = bars[i];
						__children_mc.addChildAt(bar, bar.getValue('under').boolean ? 0 : __children_mc.numChildren);
						if (bar.isLoading)
						{
							_loadingThings++;
				
							bar.addEventListener(Event.COMPLETE, _tagCompleted, false, 0, true);
						}
						
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __setContentSize()
		{
			var should_be_visible:Boolean = ! getValue('invisible').boolean;
			if (should_be_visible)
			{
				var z : Number = __children.length;
				if (z)
				{
					should_be_visible = false;
					var hORw:String;
					var bar : BarView;
					var i : Number;
					var rects : Dictionary = new Dictionary();
					var hard : Size = new Size();
					var flex : Size = new Size();
					
					var verticals:Array = new Array();
					var horizontals:Array = new Array();
					
					for (i = 0; i < z; i++)
					{
						bar = __children[i];
						bar.visible = bar.hasVisibleControl();
						if (bar.visible)
						{
							should_be_visible = true;
							rects[bar] = new Rectangle();
							if (bar.vertical)
							{
								verticals.push(bar);
							}
							else
							{
								horizontals.push(bar);
							}
						}
					}
					
					if (should_be_visible)
					{
						z = horizontals.length;
						for (i = 0; i < z; i++)
						{
							bar = horizontals[i];
							
							if (bar.flexible) 
							{
								flex.height += bar.flexible;
							}
							else 
							{
								rects[bar].height = bar.getValue('size').number;
								hard.height += rects[bar].height;
							}
						}
						z = verticals.length;
						
						if (z)
						{
							flex.height ++;
							for (i = 0; i < z; i++)
							{
								bar = verticals[i];
								if (bar.flexible)
								{
									flex.width += bar.flexible;
								}
								else
								{
									rects[bar].width = bar.getValue('size').number;
									hard.width += rects[bar].width;
								}		
							}
						}
						
						var padding : Number = getValue(ControlProperty.PADDING).number + getValue('border').number;
						var content_width:Number = _width - (2 * padding);
						
						if (flex.width || flex.height)
						{
							if (flex.width) flex.width = (content_width - hard.width) / flex.width;
							if (flex.height) flex.height = ((_height - (2 * padding)) - hard.height) / flex.height;
						}
	
	
	
						var align : String;
						
						var ys:Object = new Object();
						ys.top = padding;
						ys.bottom = _height - padding;
						var xs:Object = new Object();
						xs.left = padding;
						xs.right = _width - padding;
						
						z = horizontals.length;
						for (i = 0; i < z; i++)
						{
							bar = horizontals[i];
							align = bar.getValue('align').string;
							if (bar.flexible)
							{
								rects[bar].height = flex.height * bar.flexible;
							}
							rects[bar].width = content_width;
							if (align == 'bottom')
							{
								ys[align] -= rects[bar].height;
							}
							rects[bar].x = padding;
							rects[bar].y = ys[align];
							if (align == 'top')
							{
								ys[align] += rects[bar].height;
							}
							
						}
						z = verticals.length;
						for (i = 0; i < z; i++)
						{
							bar = verticals[i];
							align = bar.getValue('align').string;
							if (bar.flexible)
							{
								rects[bar].width = flex.width * bar.flexible;
							}
							rects[bar].height = flex.height;
							if (align == 'right')
							{
								xs[align] -= rects[bar].width;
							}
							rects[bar].x = xs[align];
							rects[bar].y = ys.top;
							if (align == 'left')
							{
								xs[align] += rects[bar].width;
							}
							
						}
						
						
						z = __children.length;
						for (i = 0; i < z; i++)
						{
							bar = __children[i];
							if (rects[bar] != null)
							{
								bar.setRect(rects[bar]);
							}
						}
						
					}
				}
			}
			visible = should_be_visible;
		}
		
		private var __laterInterval : Timer;
		
	}
}