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
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.utils.*;
	
	import flash.geom.*;
	import flash.filters.*;
	import flash.display.*;
	import flash.display.Shader;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	
/**
* Implementation class for convolution effect module
*
* @see IModule
* @see Clip
* @see Mash
*/
	public class Bender extends ModuleTransition
	{
		private static var __shaders:Dictionary = new Dictionary();
		
		public function Bender()
		{
				
			_defaults.shader = '';
			_defaults.fade = Fades.IN;
			//_defaults.swap = '0';
			__positions =  new Array();
			__scales =  new Array();
		}
		
		override public function buffer(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):void
		{
		//	RunClass.MovieMasher['msg'](this + '.buffer');
			var shader_url:String = __shaderURL();
			
			if (__shaders[shader_url] == null)
			{
				
				var loader:URLLoader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, __completeLoader);
				loader.addEventListener(IOErrorEvent.IO_ERROR, __errorLoader);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __errorLoader);
				//loader.addEventListener(ProgressEvent.PROGRESS, __progressLoader);
			
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				
				loader.load(new URLRequest(shader_url));
				__shaders[shader_url] = loader;
				__shaders[loader] = shader_url;
			}
		}
		
		override public function buffered(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):Boolean
		{
		//	RunClass.MovieMasher['msg'](this + '.buffered');
			var is_buffered:Boolean = true;
			var shader_url:String = __shaderURL();
			if (shader_url.length)
			{
				is_buffered = false;
				if (__shaders[shader_url] != null)
				{
					if (! (__shaders[shader_url] is URLLoader))
					{
						is_buffered = true;
					}
				}
			}
			return is_buffered;
		}
		private function __errorLoader(event:Event):void
		{
		}	
		private function __completeLoader(event:Event):void
		{
			try
			{
				var loader:URLLoader = event.target as URLLoader;
				var shader_url:String = __shaders[loader];
				
				var shader:Shader = new Shader();
				shader.byteCode = loader.data;
				//loader.data
				
				
				var filter:ShaderFilter = new ShaderFilter(shader);
				__shaders[shader_url] = filter;
				__shaders[filter] = shader;
				
				
				loader.removeEventListener(Event.COMPLETE, __completeLoader);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, __errorLoader);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, __errorLoader);
				//loader.removeEventListener(ProgressEvent.PROGRESS, __progressLoader);
				
				
				delete __shaders[loader];
				dispatchEvent(new Event(EventType.BUFFER));
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__completeLoader ' + e);
			}
		}
		protected function __progressLoader(event:ProgressEvent):void
		{
		}
		private function __shaderURL():String
		{
			var shader_url:String = _getClipProperty('shader');
			if (shader_url.length)
			{
				var url:Object = new RunClass.URL(shader_url);
				shader_url = url.absoluteURL;
			}
			return shader_url;
		}
		private function __parameterValue(parameter:ShaderParameter, clip_frame:Number):Array
		{
			var index:int = parameter.index;
			var type:String = parameter.type;
			
			var per:Number = _getFade(clip_frame) / 100.00;
				
			var a:Array = null;
			var a_fade:Array = null;
			var value:String = _getClipProperty('parameter' + index);
			if ((value == null) || (! value.length))
			{
				value = _getClipProperty(parameter.name);
			}
			var value_fade:String = _getClipProperty('parameter' + index + 'fade');
			if ((value_fade == null) || (! value_fade.length))
			{
				value_fade = _getClipProperty(parameter.name + 'fade');
			}
			
			
			var i:uint;
			var z:uint;
			var n:Number;
			var faded:Number;
			var c:String = type.substr(0, 1);
			if ((value != null) && value.length)
			{
				a = value.split(',');
				if ((value_fade != null) && value_fade.length)
				{
					a_fade = value_fade.split(',');
				}
				z = a.length;
				for (i = 0; i < z; i++)
				{
					switch(c)
					{
						case 'i':
							a[i] = parseInt(a[i]);
							break;
						case 'b':
							a[i] = Boolean(parseInt(a[i]));
							break;
						default:
							a[i] = parseFloat(a[i]);
							break;
					}
					//(per != 1) && 
					if ((a_fade != null) && (i < a_fade.length))
					{
						faded = RunClass.PlotUtility['perValue'](per * 100, parseFloat(a_fade[i]), parseFloat(a[i]));
					//	RunClass.MovieMasher['msg'](this + ' faded ' + a[i] + ' -> ' + faded);
						a[i] = faded;
						switch(c)
						{
							case 'i':
								a[i] = parseInt(a[i]);
								break;
							case 'b':
								a[i] = Boolean(parseInt(a[i]));
								break;
						}
					}
					//else RunClass.MovieMasher['msg(this + ' not faded ' + per + ' ' + clip_frame + ' ' + _getFade'](clip_frame));
				}
				
			}
			return a;
		}
					
    	private function __setShaderFrame(shader:Shader, clip_frame:Number):void
		{
			var shaderData:ShaderData = shader.data; 
			var shaderParameter:ShaderParameter;
			var parameterValue:Array;
			
			
			var parameters:Array = new Array();
			var shader_parameters:Array = new Array();
			var scales:Array;
			var positions:Array;
			var scaler:Number;
			for (var prop:String in shaderData) 
			{ 
				// might be ShaderInput or meta
				if (shaderData[prop] is ShaderParameter) 
				{ 
					shaderParameter = shaderData[prop] as ShaderParameter;
					parameterValue = __parameterValue(shaderParameter, clip_frame);
					
					if (parameterValue != null)
					{
						parameters[shaderParameter.index] = parameterValue;
						shader_parameters[shaderParameter.index] = shaderParameter;
						if (__scales.indexOf(shaderParameter.index) != -1)
						{
							scales = parameterValue;
						}
						else if (__positions.indexOf(shaderParameter.index) != -1)
						{
							positions = parameterValue;
						}
					}
				} 
			}
			
			if (scales != null)
			{
				scales[0] = (scales[0] * _size.width) /100;
				if (scales.length > 1) 
				{
					scales[1] = (scales[1] * _size.height) /100;
				}
			}
			if (positions != null)
			{ 
				scaler = 0;
				if (! __ignorescale)
				{
					scaler = ((scales == null) ? 0 : scales[0]);
				}
				positions[0] = ((positions[0] * (_size.width - scaler)) /100);
				
				if (positions.length > 1)
				{
					positions[1] = Math.abs(Number(positions[1]) + (_getClipPropertyNumber('verticalinvert') ? 0 : -100));
					if (! __ignorescale)
					{
						scaler = ((scales == null) ? 0 : scales[((scales.length == 1) ? 0 : 1)]);
					}
					positions[1] = ((positions[1] * (_size.height - scaler)) /100);
					
				}
			}
			var z:uint = parameters.length;
			var i:uint;
			for (i = 0; i < z; i++)
			{
				parameterValue = parameters[i];
			
				if (parameterValue != null)
				{
					shaderParameter = shader_parameters[i];
					shaderParameter.value = parameterValue;
				}
				//else RunClass.MovieMasher['msg'](this + ' ' + i + ' is null');
			}
		}
		override public function setFrame(clip_frame:Number):void
		{	
			super.setFrame(clip_frame);
			try
			{
				
				var type:String = _getClipProperty('type');
				var a:Array = new Array();
				var shader_url:String = __shaderURL();
				if (shader_url.length)
				{
					
					if ((__shaders[shader_url] != null) && (__shaders[shader_url] is ShaderFilter)) 
					{
						var filter:ShaderFilter = __shaders[shader_url];
						__setShaderFrame(__shaders[filter], clip_frame);
						a.push(filter);
					}
				}
				//if (sprite.name == 'transition_to') _moduleFilters = a;
				//else 
				if (type == ClipType.TRANSITION) _transitionFilters = a;
				else _moduleFilters = a;
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.setFrame (Bender) ', e);
			}
		}
		override protected function _initialize():void
		{
			super._initialize();
			
			var position:String = _getMediaProperty('positions');
			var scale:String = _getMediaProperty('scales');
			var z:uint;
			var i:uint;
			
			if ((position != null) && position.length)
			{
				__positions = position.split(',');
			}
			if ((scale != null) && scale.length)
			{
				__scales = scale.split(',');
			}
			z = __positions.length;
			if (z)
			{
				for (i = 0; i < z; i++)
				{
					__positions[i] = parseInt(__positions[i]);
				}
			}
			z = __scales.length;
			if (z)
			{
				__ignorescale = (_getMediaProperty('ignorescale') == "1");
				for (i = 0; i < z; i++)
				{
					__scales[i] = parseInt(__scales[i]);
				}
			}
		}
		private var __positions:Array;
		private var __scales:Array;
		private var __ignorescale:Boolean = true;
	}
	
}
