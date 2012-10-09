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
	import com.moviemasher.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
/**
* Abstract base class for all modules. 
*
* @see Clip
* @see Mash
*/
	public class ModuleTransition extends ModuleEffect implements IModuleTransition
	{
		public function ModuleTransition()
		{
			
		}
		public function get transitionFilters():Array
		{
			return _transitionFilters;
		}
		public function get transitionMask():DisplayObject
		{
			return _transitionMask;
		}
		public function get transitionColorTransform():ColorTransform
		{
			return _transitionColorTransform;
		}
		public function get transitionMatrix():Matrix
		{
			return _transitionMatrix;
		}
		protected var _transitionFilters:Array = null;
		protected var _transitionColorTransform:ColorTransform = null;
		protected var _transitionMatrix:Matrix = null;
		protected var _transitionMask:DisplayObject = null;
		
		
	}
}