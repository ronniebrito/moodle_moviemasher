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
	
	import flash.text.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
/**
* Implementation base class for preview options
*
* @see Browser
* @see IOptions
*/
	public class PreviewOptions extends BoxOptions
	{
		public function PreviewOptions()
		{
			super();
			
			try
			{
			
				// text properties that vary depending on selected and disabled 
				
				_defaults.textbackcolor = 'FFFFFF';
				_defaults.textcolor = '333333';
				_defaults.textbackalpha = '50';
				
				_multiples.sel.push('textbackcolor');
				_multiples.sel.push('textcolor');
				_multiples.sel.push('textbackalpha');
				
				// non varying text properties
				_defaults.label = '';
				_defaults.font = 'default';
				_defaults.textalign = 'left';
				_defaults.textvalign = 'bottom';
				_defaults.textsize = '12';
				_defaults.textheight = '20';
				_defaults.textoffset = '0';
				_defaults.preview = '';
				_defaults.type = '';
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg']('PreviewOptions', e);
			}
		}
		override public function get metrics():Size
		{
			var size:Size = super.metrics;

			var textsize:Number = getValue('textsize').number;
			var textheight:Number = getValue('textheight').number;
			
			if (textheight && textsize)
			{
				switch(getValue('textvalign').string)
				{
					case 'above':
					case 'below':
					
						size.height += textheight;
						break;
				}
			}
			
			return size;
		}
	}
}