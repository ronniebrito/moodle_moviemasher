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

package com.moviemasher.utils
{
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
/**
* Static class handles parsing of patterned string potentially containing {@link IValued} property references
*
* @see CGI
* @see Text
* @see Increment
* @see Source
*/

	public class ParseUtility
	{
		
		public static function bracketed(pat, include_indices:Boolean = false):Array
		{
			var a:Array = new Array();
			try
			{
				var left_brace:Number = pat.indexOf('{');
				var right_brace:Number = 0;
				var field:String;
				while (left_brace != -1)
				{
					
					right_brace = pat.indexOf('}', left_brace);
					field = pat.substr(left_brace + 1, right_brace - (left_brace + 1))
					if (include_indices) a.push(new Array(left_brace + 1, field));
					else a.push(field);
					left_brace = pat.indexOf('{', right_brace);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg']('RunClass.ParseUtility.brackets. caught ' + e);
			}
				
			return a;
		}
		public static function brackets(pat:String, hash:* = null):String
		{
			if (hash == null) hash = RunClass.MovieMasher['objects'];
			var a:Array;
			a = bracketed(pat, true);
			var y, j, z, i, index:int;
			var reference:String;
			var s:String = '';
			var last_index:int = 0;
			var dots:Array;
			var target:*;
			var key:String;
								
			y = a.length;
			if (y)
			{
				for (j = 0; j < y; j++)
				{
					index = a[j][0];
					reference = a[j][1];
					if ((index - 1) > last_index)
					{
						s += pat.substr(last_index, (index - 1) - last_index);
					}
					last_index = index + reference.length + 1;					
					dots = reference.split('.');
					z = dots.length;
					
					target = hash;
					for (i = 0; i < z; i++)
					{
						key = dots[i];
						if (target is IValued)
						{
							try
							{
								target = target.getValue(key).object;
							}
							catch(e:*)
							{
								RunClass.MovieMasher['msg']('ParseUtility.brackets IValued caught ' + e + ' ' + target + '.' + key);
							}
						}
						else if (target is XML)
						{
							target = String(target.@[key]);
						}
						else if (target[key] == null)
						{
							target = '{' + reference + '}';
							break;
						}
						else 
						{
							try
							{
								if (target[key] is Function) target = target[key]();
								else target = target[key];
							}
							catch(e:*)
							{
								RunClass.MovieMasher['msg']('ParseUtility.brackets caught ' + e + ' ' + target + '.' + key);
							}
						}
					}
					s += String(target);
				}
			}
			if (last_index < pat.length)//(pat.length - 1))
			{
				s += pat.substr(last_index);
			}
			return s;
		}
	}
}
