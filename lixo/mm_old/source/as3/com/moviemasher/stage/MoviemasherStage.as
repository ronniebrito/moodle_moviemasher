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
package com.moviemasher.stage
{
	import com.adobe.crypto.*;
	import com.moviemasher.core.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.type.*;
	import com.moviemasher.manager.*;
	import flash.display.*;
/**
* Implementation class for moviemasher SWF root object
*/
	public class MoviemasherStage extends MovieClip
	{
		
		public function MoviemasherStage()
		{
			
			RunClass.MovieMasher = MovieMasher;
			RunClass.MD5 = MD5;
			RunClass.URL = URL;

			var mm:MovieMasher = new MovieMasher();
			addChild(mm);
			addChild(StageManager.sharedInstance);
			StageManager.sharedInstance.setManagers(LoadManager.sharedInstance);
			ConfigManager.sharedInstance.setManagers(LoadManager.sharedInstance, StageManager.sharedInstance);
			mm.setManagers(LoadManager.sharedInstance, ConfigManager.sharedInstance, StageManager.sharedInstance);
			
		}
	}
}

