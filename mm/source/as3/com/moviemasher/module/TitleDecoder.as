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
	import flash.text.*;
	import flash.events.*;
	import com.moviemasher.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.events.*;
	
	import mx.utils.Base64Encoder;
	import mx.utils.Base64Decoder;
	
/**
* Implementation class for displaying base64 encoded text
*
* @see Title
*/
	public class TitleDecoder extends Title
	{
		public function TitleDecoder()
		{
			
		}
		public function base64Decode(s:String):String
		{
			var encoder:Base64Decoder = new Base64Decoder();
			encoder.decode(s);
			
			return encoder.toByteArray().toString();
		}
		public function base64Encode(s:String):String
		{
			var encoder:Base64Encoder = new Base64Encoder();
			encoder.insertNewLines = false;
			encoder.encodeUTFBytes(s);
			return encoder.toString();
		}		

		
		override protected function _getText(clip_frame:Number):String
		{
			var text:String = super._getText(clip_frame);
			
			text = base64Decode(text);
			
			return text;
		}
	}
}