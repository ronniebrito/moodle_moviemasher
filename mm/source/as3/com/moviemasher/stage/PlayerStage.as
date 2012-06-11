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
	import com.moviemasher.control.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.display.*
	import com.moviemasher.events.*;
	import com.moviemasher.source.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.module.*;
	import com.moviemasher.core.*;
	import com.moviemasher.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;

/**
* Implementation class for player SWF root object
*/
	public class PlayerStage extends PropertiedMovieClip
	{
		function PlayerStage()
		{
			RunClass.LocalSource = LocalSource;
			RunClass.RemoteSource = RemoteSource;
			RunClass.Mash = Mash;
			RunClass.Clip = Clip;
			RunClass.Media = Media;
			RunClass.Module = Module;
			RunClass.DrawUtility = DrawUtility;
			RunClass.MouseUtility = MouseUtility;
			RunClass.PlotUtility = PlotUtility;
			RunClass.StringUtility = StringUtility;
			RunClass.TimeUtility = TimeUtility;
			RunClass.FontUtility = FontUtility;
			
			instance = this;
			
			__panels_mc = new Sprite();
			addChild(__panels_mc);
			
			__panels = new Array();
			
			_defaults.id = ReservedID.MOVIEMASHER;
			RunClass.MovieMasher['setByID'](ReservedID.MOVIEMASHER, this);
			RunClass.MovieMasher['instance'].addEventListener(FullScreenEvent.FULL_SCREEN, __moviemasherFullscreen);
			RunClass.MovieMasher['instance'].addEventListener(Event.RESIZE, __moviemasherResize);
			if (! RunClass.MovieMasher['loaded'])
			{
				RunClass.MovieMasher['instance'].addEventListener(EventType.LOADED, __moviemasherLoaded);
			}
			else
			{
				__moviemasherLoaded(null);
			}
		}
		public static function addSource(xml:XML):ISource
		{
			var isource:ISource;
			var c:Class;
			var symbol:String;
			var loader:IAssetFetcher;
			var id:String;
			id = String(xml.@id);
			if (id.length)
			{
				symbol= String(xml.@symbol);
				if (! symbol.length)
				{
					symbol = String(xml.@url);
					symbol = '@' + (symbol.length ? 'Remote' : 'Local') + 'Source';
				}
				loader = RunClass.MovieMasher['assetFetcher'](symbol, 'swf');
				if (loader != null)
				{
					if (loader.state != EventType.LOADING)
					{
						c = loader.classObject(symbol, 'source');
					}
				}
				if (c != null)
				{
					isource = new c();
					if (isource != null)
					{
						isource.tag = xml;
						RunClass.MovieMasher['setByID'](id, isource);
					}
				}		
			}
			return isource;
		}
		public static var instance:PlayerStage;
		/*
		override public function changeEvent(event:ChangeEvent):void
		{
			setValue(event.value, event.property);
		}
		*/
		override public function getValue(property:String):Value
		{
			var value:Value = null;
			switch (property)
			{
				case 'freetime':
					value = new Value(timeLeft());
					break;
				case 'memory':
					value = new Value((System.totalMemory * 100) / RunClass.MovieMasher['getOptionNumber']('memory', 'maximum'));
					break;
				case 'loaded':
					value = new Value((__loading ? (__loaded / __loading) : 1));
					break;
				default:
					value = new Value(RunClass.MovieMasher['getByID'](property));
					//super.getValue(property);
			}
			return value;
		}
		override public function setValue(value:Value, property:String):Boolean
		{
			RunClass.MovieMasher['setByID'](property, value.object);
			dispatchEvent(new ChangeEvent(value, property));
			return false;
		}
		public function timeLeft():Number
		{
			var time_left:Number;
			if (__playingClip == null)
			{
				time_left = Infinity;
			}
			else
			{
				time_left = __playingClip.timeLeft();
			}
			return time_left;
		}
		public function resize():void
		{
			try
			{
				var rect:Object;
				var panel:PanelView;
				var z:Number = __panels.length;
				var empty:Boolean;
				var rects:Array = new Array();
				var i:Number;
				for (i = 0; i < z; i++)
				{
					rect = new Object();
					panel = __panels[i];
					rect.x = panel.getValue('x').number;
					rect.y = panel.getValue('y').number;
					rect.width = panel.getValue('width').number;
					rect.height = panel.getValue('height').number;
					rects.push(rect);
				}
				rects =  __flexibleRects(rects, new Size(__w, __h));
				for (i = 0; i < z; i++)
				{
					empty = rects[i].isEmpty()
					panel = __panels[i];
					if (panel.visible && empty)
					{
						panel.visible = false;
					}
					if (! empty) 
					{
						panel.visible = true;
						panel.setRect(rects[i]);
					}
				}
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			
		}
		public function fullScreen(focus:IMetrics = null):void
		{
		
			__resizeFocus = focus;
			__resizeFocusSize = __resizeFocus.metrics;
			__resizeFocusParent = __resizeFocus.displayObject.parent;
			__resizeFocusParent.removeChild(__resizeFocus.displayObject);
			addChild(__resizeFocus.displayObject);
			removeChild(__panels_mc);
			var w:Number = __w;
			var h:Number = __h;
			try
			{
				instance.stage.displayState = StageDisplayState.FULL_SCREEN;
			}
			catch(e:*)
			{
				// probably a security error, AllowFullScreen not set?
			}
			if ((w == __w) && (h == __h))
			{
				// didn't resize for some reason
				RunClass.MovieMasher['instance'].addEventListener(KeyboardEvent.KEY_DOWN, fullScreenExit);
				RunClass.MovieMasher['instance'].addEventListener(MouseEvent.MOUSE_DOWN, fullScreenExit);
				__moviemasherResize(null);
				__moviemasherFullscreen(new FullScreenEvent(FullScreenEvent.FULL_SCREEN, false, false, true));
			}
	
		
		}
		public function fullScreenExit(event:Event = null):void
		{
			try
			{
				RunClass.MovieMasher['instance'].removeEventListener(KeyboardEvent.KEY_DOWN, fullScreenExit);
				RunClass.MovieMasher['instance'].removeEventListener(MouseEvent.MOUSE_DOWN, fullScreenExit);
				__moviemasherFullscreen(new FullScreenEvent(FullScreenEvent.FULL_SCREEN));
		
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		public function startPlaying(clip:IPlayer):void
		{
			stopPlaying();
			__playingClip = clip;
			if (RunClass.BrowserPreview != null) RunClass.BrowserPreview['animatePreviews'](false); 
		}
		public function stopPlaying():void
		{
			if (__playingClip != null)
			{
				__playingClip.paused = true;
			}
			__playingClip = null;
			if (RunClass.BrowserPreview != null) RunClass.BrowserPreview['animatePreviews'](true); 
		}
		public function set size(iSize:Size):void
		{
			__w = iSize.width;
			__h = iSize.height;
			
			resize();
		}
		public function sortByZ(a:XML, b:XML):Number
		{
			var a_track:Number = Number(a.@z);
			var b_track:Number = Number(b.@z);
			
			if (a_track < b_track)
			{
				return -1;
			}
			if (a_track > b_track)
			{
				return 1;
			}
			return 0;
		}
		private function __initializeTimer(event:TimerEvent):void
		{
			try
			{
				
				//RunClass.MovieMasher['instance'].addEventListener(Event.CHANGE, __moviemasherChange);
				
				event.target.removeEventListener(TimerEvent.TIMER, __initializeTimer);
				var array:Array;
				var xml_list:XMLList;
				var xml:XML;
				var i:int;
				var z:int;
				
				array = RunClass.MovieMasher['searchTags']('source');
				
				for each (xml in array)
				{
					addSource(xml);
				}
	
				array = RunClass.MovieMasher['searchTags']('panel');
				z = array.length;
				if (z)
				{
					
					var panel:PanelView;
					try
					{
						for (i = 0; i < z; i++)
						{
							xml = array[i];
							if (! String(xml.@z).length)
							{
								xml.@z = '-' + String(z - i);
							}
						}
						array.sort(sortByZ);
						for (i = 0; i < z; i++)
						{
							xml = array[i];
							panel = new PanelView();
							__panels_mc.addChild(panel);
							__panels.push(panel);
							try
							{
								panel.tag = xml;
							}
							catch(e:*)
							{
								RunClass.MovieMasher['msg'](this, e);
							}
							if (panel.isLoading)
							{
								panel.addEventListener(Event.COMPLETE, __panelComplete);
								
								__loading++;
			
							}
						}
					}
					catch (e:*)
					{
						RunClass.MovieMasher['msg'](this, e);
					}
												
					if (__loading == __loaded)
					{
						__initPanels();
					}
					
				}
			}
			catch (e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __panelComplete(event:Event):void
		{
			__loaded++;
			try
			{
				event.target.removeEventListener(Event.COMPLETE, __panelComplete);
				if (__loading == __loaded)
				{
					// will dispatch final loading event after timer
					__initPanels();
					
				}
				else
				{
					dispatchEvent(new Event(EventType.LOADING));
				}
			}
			catch (e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __initPanels():void
		{
			__initPanelsTimer = new Timer(100, 1);
			__initPanelsTimer.addEventListener(TimerEvent.TIMER, __initPanelsTimed);
			__initPanelsTimer.start();
		}
		private function __initPanelsTimed(event:TimerEvent):void
		{
			__initPanelsTimer.removeEventListener(TimerEvent.TIMER, __initPanelsTimed);
			__initPanelsTimer.stop();
			__initPanelsTimer = null;
			var panel:PanelView;
			var z:int = __panels.length;
			var i:int;
			for (i = 0; i < z; i++)
			{
				panel = __panels[i];
				try
				{
					panel.callControls('initDispatchers');
				}
				catch(e:*)
				{
					
					RunClass.MovieMasher['msg'](this, e);
				}
			}
			
			try
			{
				for (i = 0; i < z; i++)
				{
					panel = __panels[i];
					panel.callControls('initListeners');
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			try
			{
				for (i = 0; i < z; i++)
				{
					panel = __panels[i];
					panel.callControls('makeConnections');
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			if (hasEventListener('memory'))
			{
				__memoryTimer = new Timer(2000);
				__memoryTimer.addEventListener(TimerEvent.TIMER, __memoryTimed);
				__memoryTimer.start();
			}
			try
			{
				__moviemasherResize(null);
			
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			try
			{
				for (i = 0; i < z; i++)
				{
					panel = __panels[i];
					panel.callControls('finalize');
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			try
			{
				dispatchEvent(new Event(EventType.LOADING));
				//dispatchEvent(new Event(Event.COMPLETE));
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			//dispatchEvent(new Event(EventType.LOADING));
		}
		private function __memoryTimed(event:TimerEvent):void
		{
			var value:Value = getValue('memory');
			if (__memory != value.number)
			{
				__memory = value.number;
				dispatchEvent(new ChangeEvent(value, 'memory'));
			}
		}
		private function __moviemasherLoaded(event:Event):void
		{
			try
			{
				if (event != null) event.target.removeEventListener(EventType.LOADED, __moviemasherLoaded);
				__initialize();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __initialize():void
		{
			var timer:Timer = new Timer(100, 1);
			timer.addEventListener(TimerEvent.TIMER, __initializeTimer);
			timer.start();
		}
		private function __flexibleRects(a:Array, size:Size):Array
		{
			var rectangles:Array = new Array();
			var z:int = a.length;
			var r:Rectangle;
			var ob:Object;
			var n:Number;
			var keys:Array = ['x','width','y','height'];
			var key:String;
			rectLoop: for (var i:int = 0; i < z; i++)
			{
				ob = a[i];
				r = new Rectangle();
				for (var j:int = 0; j < 4; j++)
				{
					key = keys[j];
					n = Number(ob[key]);
					if (isNaN(n))
					{
						continue rectLoop;
					}
					if ((n <= 0) && (n || (key.length > 1)))
					{
						n = size[(j < 2 ? 'width':'height')] + n;
					}
					r[key] = n;
				}
				rectangles.push(r);
			}
			return rectangles;
		}
		private function __moviemasherResize(event:Event):void
		{
			try
			{
				var mm_size:Size = new Size(RunClass.MovieMasher['instance'].width, RunClass.MovieMasher['instance'].height);
				if (__resizeFocus == null)
				{
					size = mm_size;
				}
				else
				{
					__resizeFocus.metrics = mm_size;
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __moviemasherFullscreen(event:FullScreenEvent)
		{
			__fullScreen = true;
			if (__resizeFocus != null)
			{
				if (! event.fullScreen)
				{
					removeChild(__resizeFocus.displayObject);
					addChild(__panels_mc);
					__resizeFocusParent.addChild(__resizeFocus.displayObject);
					__resizeFocus.metrics = __resizeFocusSize;
					__resizeFocus = null;
					__resizeFocusParent = null;
				}
			}
			dispatchEvent(event);
		}
		private static var __needsCGI:Class = CGI;
		private static var __needsAVMash:Class = AVMash;
		private static var __needsAVSequence:Class = AVSequence;
		private static var __needsAVVideo:Class = AVVideo;
		private static var __needsIcon:Class = Icon;
		private static var __needsPlayer:Class = Player;
		private static var __needsSlider:Class = Slider;
		private static var __needsText:Class = Text;
		private static var __needsToggle:Class = Toggle;
		private static var __panels_mc:Sprite;
		private static var __resizeFocus:IMetrics;
		private static var __resizeFocusParent:DisplayObjectContainer;
		private var __initPanelsTimer:Timer;
		private var __h:Number = 0;
		private var __resizeFocusSize:Size;
		private var __fullScreen:Boolean = false;
		private var __loaded:Number = 0;
		private var __loading:Number = 0;
		private var __memory:Number;
		private var __memoryTimer:Timer;
		private var __panels:Array;
		private var __playingClip:IPlayer;
		private var __w:Number = 0;
		
	}
}

