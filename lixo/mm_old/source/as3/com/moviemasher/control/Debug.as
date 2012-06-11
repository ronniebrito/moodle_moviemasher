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



/** Control symbol provides simple debug message functionality.

*/
package com.moviemasher.control
{
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.events.*;
	import flash.text.*;
	import flash.events.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
/**
* Implimentation class represents a control for displaying debug messages
*/
	
	public class Debug extends ControlPanel
	{

		public function Debug()
		{
			
			_defaults.id = 'debug';
			_defaults.font = 'default';
			_defaults.textcolor = '333333';
			_defaults.textsize = '12';
			_defaults.multiline = '1';
			_defaults.textalign = '';
			_defaults.wordwrap = '0';
			_allowFlexibility = true;
	
			_defaults.filter = '';
			_defaults.filters = '';
			_defaults.autofilter = '';
			_widths = new Object();
			__msgs = new Object();
		}
		
		override public function setValue(value:Value, property:String):Boolean
		{
			var redraw:Boolean = (property == 'filter');
			if (__msgs[property] == null) 
			{
				super.setValue(value, property);
				switch (property)
				{
					case 'clear':
						__clear();
						break;
				}
			}
			else
			{
				__msgs[property].unshift(value.string);
				redraw = true;
				if (getValue('autofilter').boolean && (property != getValue('filter').string))
				{
					setValue(new Value(property), 'filter');
				}
			}
			if (redraw && root)
			{
				dispatchEvent(new ChangeEvent(value, property));
				redraw = ! __vScrollReset();
				if (property != 'filter')
				{
					var w:Number = __textField.getLineMetrics(0).width + 4;
					if (_widths[property] < w)
					{
						_widths[property] = w;
						if (! __hScrollReset()) 
						{
							redraw = true;
						}
					}
				}
					
			}
			return false;
		}
		protected function __hScrollReset():Boolean
		{
			var tf:Boolean = false;
			if (__lineHeight)
			{
				var filter:String = getValue('filter').string;
				if (filter.length && (_widths[filter] != null))
				{
					tf = _setScrollDimension('width', _widths[filter]);
				}
			}
			return tf;
		}
		
		protected function __vScrollReset():Boolean
		{
			var tf:Boolean = false;
			if (__lineHeight)
			{
				var filter:String = getValue('filter').string;
				if (filter.length && (__msgs[filter] != null))
				{
					tf = _setScrollDimension('height', (__lineHeight * __msgs[filter].length) + 4);
				}
			}
			return tf;
		}
		override protected function _drawClips(force:Boolean = false):void
		{
			if (__lineHeight )
			{
				var filter:String = getValue('filter').string;
				if (filter.length && (__msgs[filter] != null))
				{
					var start_index:Number = Math.ceil(_scroll.y / __lineHeight);
					var displayed:Array = __msgs[filter].slice(start_index, start_index + __lineCount);
					__textField.text = displayed.join("\n");
					if (__textField.x != - _scroll.x)
					{
						__textField.x = - _scroll.x;
						__textField.width = _width + _scroll.x;
						
					}
				}
			}
		}

		
		override protected function _createChildren():void
		{
			super._createChildren();
			__textField = new TextField();
			addChild(__textField);
			_displayObjectLoad(ModuleProperty.FONT);
		}
		override public function initialize():void
		{
			super.initialize();
			RunClass.FontUtility['formatField'](__textField, this);
			
			var msg_filters:Array = getValue('filters').array;
			var z:uint = msg_filters.length;
			for (var i:uint = 0; i < z; i++)
			{
				__msgs[msg_filters[i]] = new Array();
				_widths[msg_filters[i]] = 0;
			}
			
		}
		override public function resize():void
		{
			super.resize();
			//__textField.text = 'jgklyp';
			__textField.width = _width;
			__textField.height = _height;
			__lineHeight = Math.ceil(__textField.getLineMetrics(0).height);
			__lineCount = Math.floor((_height - 4) / __lineHeight);
			//__msgs.warning.push(this + '.resize height = ' + __lineHeight + ' count = ' + __lineCount); 
			var did_draw:Boolean =  __vScrollReset();
			if (__hScrollReset())
			{
				did_draw = true;
			}
			if (! did_draw)
			{
				_drawClips();
			}
		}
		private function __clear():void
		{
			var filter:String = getValue('filter').string;
			if (filter.length && (__msgs[filter] != null))
			{
				__msgs[filter] = new Array();
				_widths[filter] = 0;
				if (! __vScrollReset())
				{
					_drawClips();
				}
			}
		}
		private var __lineCount:Number = 0;
		private var __textField:TextField;
		private var __msgs:Object;
		private var _widths:Object;
		private var __lineHeight:Number = 0;
	}
	
}