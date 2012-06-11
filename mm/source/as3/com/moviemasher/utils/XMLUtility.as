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
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
/**
* Static class provides functions for parsing XML
*/
	public class XMLUtility
	{
		public static function attributeData(node : XML = null, data : Object = null) : Object
		{
			if (data == null) data = new Object();
			if (node != null) 
			{
				data.xmlNode = node;
			
				var list : XMLList =  node.@*;
				var z : int = list.length();
				var node_name : String;
				for (var i : Number = 0; i < z; i ++)
				{
					node_name = String(list[i].name());
					data[node_name] = flashValue(node.@[node_name]);
				}
				data.nodeName = node.name();
			}
			return data;
		}
		public static function flashValue(val : String):*
		{
			var r:* = val;
			if (val == null) 
			{
				r = '';
			}
			if (r.length)
			{
				var new_val : Number = Number(val);
				if (! isNaN(new_val)) 
				{
				
					if (val.indexOf('.') > -1)
					{
				
						new_val = parseFloat(val);	
					}
					
					r = new_val;
				}
			}
			return r;	
		}
	}
}

