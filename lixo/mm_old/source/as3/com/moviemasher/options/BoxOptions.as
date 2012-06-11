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

package com.moviemasher.options
{

	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import flash.text.*;
	
/**
* Implementation base class for preview options
*
* @see Browser
* @see IOptions
*/
	public class BoxOptions extends Propertied implements IOptions
	{
		public function BoxOptions()
		{
			super();
			try
			{
				// properties that vary depending on selected and disabled 
			
				_defaults.color = '';
				_defaults.alpha = '100';
				_defaults.angle = '90';
				_defaults.shadowblur = '4';
				_defaults.shadowstrength = '2';
				_defaults.blend = 'normal';
				_defaults.border = '0';
				_defaults.bordercolor = '000000';
				_defaults.grad = '0';
				_defaults.shadow = '0';
				_defaults.shadowcolor = '';
				
				_multiples = new Object();
				_multiples.sel = new Array();
				for (var k:String in _defaults)
				{
					_multiples.sel.push(k);
				}
				_multiples.dis = _multiples.sel;
				
				// non varying properties
				_defaults.curve = '4';
				_defaults.width = '0';
				_defaults.height = '0';
				_defaults.ratio = '0';
				_defaults.padding = '0';
				_defaults.source = '';
				_defaults.symbol = '';
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.BoxOptions', e);
			}

		}
		public function get metrics():Size
		{
			var n:Number = getValue('height').number;
			var w:Number = getValue('width').number;
			if (! n)
			{
				n = w / getValue('ratio').number;
			}
			return new Size(w, n);
		}
		override public function getValue(property:String):Value
		{
			var value:Value = super.getValue(property);
			try
			{
				if (value.empty)
				{
					var prop:String;
					var l:int;
					
					for (var k:String in _multiples)
					{
						l = k.length;
						
						if (property.substr(0, l) == k)
						{
							
							prop = property.substr(l);
							if (_multiples[k].indexOf(prop) != -1)
							{
								value = super.getValue(prop);
							}
							//else RunClass.MovieMasher['msg'](this + '.getValue ' + k + ' ' + property + ' ' + prop);
						
							break;
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.getValue', e);
			}

			return value;
		}
		protected var _multiples:Object;
	}
}