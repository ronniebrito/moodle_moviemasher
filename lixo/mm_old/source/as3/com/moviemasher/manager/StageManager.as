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
package com.moviemasher.manager
{
	import flash.display.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.display.*;
	import com.moviemasher.events.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
/**
* Implementation class for stage manager
*
* @see IStageManager
* @see MoviemasherStage
* @see MovieMasher
*/
	public class StageManager extends Sprite implements IStageManager
	{
		public function StageManager()
		{
			__msgs = new Array();
			__tooltipContainer = new Sprite();
			__cursorContainer = new Sprite();
			__cursorContainer.mouseEnabled = false;
			__cursorContainer.mouseChildren = false;
			__parameters = new Object();
			__parameters.config = '';
			__parameters.base = '';
			__parameters.policy = '';
			__parameters.debug = '';
			__parameters.appletbase = '';
			
		}
		public function initialize():void
		{
			__debug = RunClass.MovieMasher['getByID']('debug') as IPropertied;
			if (__debug != null)
			{
				var z:uint = __msgs.length;
				for (var i:uint = 0; i < z; i++)
				{
					__debug.setValue(new Value(__msgs[i].value), __msgs[i].property);
				}
			}
			__msgs = null;
		}
		public function setManagers(iLoadManager:ILoadManager = null):void
		{
			
			__loadManager = iLoadManager;
			
			RunClass.MovieMasher['setByID']('parameters', __parameters);
			
			for (var k:Object in loaderInfo.parameters)
			{
				__parameters[k] = loaderInfo.parameters[k];
			}
			if (__parameters.base.length && (__parameters.base.substr(-1) != '/')) 
			{
				__parameters.base += '/';
			}
			
			
			if (__parameters.debug == '0') __parameters.debug = '';
			
			// we interpret it as a url if it contains a slash
			__debugging = (__parameters.debug.length && (__parameters.debug.indexOf('/') == -1));
			__msg_mc = new TextField();
			__msg_mc.wordWrap = true;
			__msg_mc.multiline = true;
						
			var tf:TextFormat = __msg_mc.getTextFormat();
			tf.font = '_typewriter';
			__msg_mc.defaultTextFormat = tf;
			parent.addChildAt(__msg_mc, 0);
			if (stage != null)
			{
				// override these parameters if set in the HTML
				stage.align = StageAlign.TOP_LEFT;
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.showDefaultContextMenu = false;
				stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullscreenedStage);
				stage.addEventListener(Event.RESIZE, __resizedStage);
				__resizedStage(null);
			}
			else 
			{
				__size.width = 640;
				__size.height = 480;
				__resize();
			}
			var url:String;
			if (RunClass.MovieMasher['instance'].loaderInfo != null) 
			{
				url = RunClass.MovieMasher['instance'].loaderInfo.url;
				if (url != null)
				{
					url = url.substr(0, - ("core/MovieMasher/stable.swf".length));
					__parameters.appletbase = url;
				}
			}
		}
		public function getParameter(property:String):String
		{
			var s:String = '';
			if (__parameters[property] != null)
			{
				s = __parameters[property];
			}
			return s;
		}
		public function msg(s:*, type:* = null):void
		{
			if (type == null) type = EventType.ERROR;
			else if (type is Error)
			{
				s = s + ' ';
				if (type.getStackTrace()) s += type.getStackTrace();
				else s += type;
				type = EventType.ERROR;
			}
			if (__msgs != null)
			{
				__storeMsg(s, type);
			}
			else if (__debug != null)
			{
				__debug.setValue(new Value(s), type);
			}
			if (__debugging)
			{
				__msg_mc.text = type.toUpperCase() + ': ' + String(s) + "\n" + __msg_mc.text;
			}
			else if (__parameters.debug.length)
			{
				// it's a url, post error to it
				__loadManager.dataFetcher(__parameters.debug, String(s));
			}
		}
		private function __storeMsg(s:*, type:String):void
		{
			var ob:Object = new Object();
			ob.property = type;
			ob.value = s;
			__msgs.push(ob);
		}
		public function setTooltip(tooltip:ITooltip, owner:IControl):void
		{
			//msg('MovieMasher.setTooltip');
			if (__tooltip != null)
			{
				__tooltipContainer.removeChild(__tooltip.displayObject);
			}
			__tooltip = tooltip;
			__tooltipOwner = owner;
			if (__tooltip != null)
			{
				__tooltipContainer.addChildAt(__tooltip.displayObject, 0);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, __mouseMoveTooltip);
				RunClass.MovieMasher['instance'].addChild(__tooltipContainer);
			
				__mouseMoveTooltip(null);
			}
		}
		public function setCursor(bm : DisplayObject = null, offset:Point = null):void
		{
			if (__cursor != bm)
			{
				var showing:Boolean = (__cursor == null);
				if (! showing)
				{
					__cursorContainer.removeChild(__cursor);
					if (! bm)
					{
						stage.removeEventListener(MouseEvent.MOUSE_MOVE, __mouseMoveCursor);
						Mouse.show();
					}
				}
				__cursor = bm;
				if (__cursor != null)
				{
					if (showing)
					{
						RunClass.MovieMasher['instance'].addChild(__cursorContainer);
						Mouse.hide();
					}
					__cursorContainer.addChild(__cursor);
					__cursor.x = - ((__cursor.width / 2) - offset.x)
					__cursor.y = - ((__cursor.height / 2) - offset.y)
					stage.addEventListener(MouseEvent.MOUSE_MOVE, __mouseMoveCursor);
					__mouseMoveCursor(null);
				}
			}
		}
		public function get size():Size
		{
			return __size;
		}
		public function set size(s:Size):void
		{
			__size = s;
			__resize();
		}
		private function __resize():void
		{
			__msg_mc.width = __size.width;
			__msg_mc.height = __size.height;
		}
		private function __resizedStage(event:Event):void
		{
			try
			{
				__size = new Size(stage.stageWidth, stage.stageHeight);
				__resize();
				if (event != null) dispatchEvent(event);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}

		}
		protected function fullscreenedStage(event:Event):void
		{
			try
			{
				dispatchEvent(event);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __mouseMoveCursor(event:MouseEvent):void
		{
			try
			{
				__cursorContainer.x = root.mouseX;
				__cursorContainer.y = root.mouseY;
				if (event != null)
				{
					//event.updateAfterEvent();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __mouseMoveTooltip(event:MouseEvent):void
		{
			try
			{
				var x_pos:Number = ((event == null) ? stage.mouseX : event.stageX);
				var y_pos:Number = ((event == null) ? stage.mouseY : event.stageY);
				__tooltipContainer.x = x_pos;
				__tooltipContainer.y = y_pos;
				
				var dont_delete:Boolean = false;
				if (__tooltip != null)
				{
					dont_delete = __tooltipOwner.displayObject.hitTestPoint(x_pos, y_pos);
					if (dont_delete)
					{
						__tooltip.point = new Point(x_pos, y_pos);
						dont_delete = __tooltipOwner.updateTooltip(__tooltip);
					}
					
					if (! dont_delete)
					{
						__tooltipContainer.removeChild(__tooltip.displayObject);
						stage.removeEventListener(MouseEvent.MOUSE_MOVE, __mouseMoveTooltip);
						RunClass.MovieMasher['instance'].removeChild(__tooltipContainer);
						__tooltip = null;
						__tooltipOwner = null;
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		public static var sharedInstance:StageManager = new StageManager(); // access by MovieMasher
		private var __cursor : DisplayObject;
		private var __cursorContainer : Sprite;
		private var __debug:IPropertied;
		private var __debugging:Boolean;
		private var __loadManager:ILoadManager;
		private var __msg_mc:TextField;
		private var __msgs:Array;
		private var __parameters:Object;
		private var __size:Size = new Size();
		private var __tooltip:ITooltip;
		private var __tooltipContainer : Sprite;
		private var __tooltipOwner:IControl;
	}
}

