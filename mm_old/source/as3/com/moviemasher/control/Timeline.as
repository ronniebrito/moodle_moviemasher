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

package com.moviemasher.control
{
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.utils.*;
	import com.moviemasher.preview.*;
	import com.moviemasher.events.*;
	import com.moviemasher.action.*;
	import com.moviemasher.options.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.system.*;
	import flash.utils.*;

/**
* Implimentation class represents a timeline control
*/
	public class Timeline extends ControlPanel
	{
		public function Timeline()
		{
			super();
			_defaultPreviewClass = TimelinePreview;
			_defaultOptionsClass = TimelineOptions;
			
			
			_defaults.autoselect = '';
			_defaults.zoom = '1';
			_defaults.id = ReservedID.TIMELINE;
			_defaults.snap = '1';
			_defaults.tie = 'player.mash,player.location,player.length,player.track,player.tracks';
			
			_defaults.novisualaudio = '0';
			_defaults.previewmode = 'normal';
			_defaults.previewcurve = '4';
			_defaults.previewinset = '2';
			
			_defaults.hscrollunit = '50';
			_defaults.hscrollpadding = '10';
			_defaults.vscrollpadding = '10';
			
			__enabledControls = new Object();
			__enabledControls.undo = false;
			__enabledControls.redo = false;
			__enabledControls.cut = false;
			__enabledControls.copy = false;
			__enabledControls.paste = false;
			__enabledControls.remove = false;
			__enabledControls.split = false;
		
			__enabledProperties = new Object();
			
			_heights = new Object();
			_heights.clip = 150;
			_heights.audio = 60;
			_heights.video = 90;
			_heights.effect = 60;
			
			_defaults.videotracks = '-1';
			_defaults.audiotracks = '-1';
			_defaults.effecttracks = '-1';
			
			
			_defaults.trimto = '5';
			_defaults.snapto = '20';
			_allowFlexibility = true;
			
			__tracks = new Object();
				
				
		}
		override public function getValue(property:String):Value
		{
			var value:Value;
			if (__enabledControls[property] != null)
			{
				value = new Value(Value[__enabledControls[property] ? 'INDETERMINATE' : 'UNDEFINED']);
			}
			else
			{
				switch(property)
				{
					case 'zoom':
						value = new Value(101 - (__zoom * 100));
						break;
					case 'selection':
						value = new Value(_selection);
						break;
					case 'mash':
						value = new Value(_mash);
						break;
					default:
						value = super.getValue(property);
				}
			}
			//if (property == 'length') RunClass.MovieMasher['msg'](this + '.getValue ' + value + ' ' + property + ' ' + _tag.toXMLString());
			return value;
		}
		override public function setValue(value:Value, property:String):Boolean
		{
			try
			{
				var dispatch:Boolean = false;
				//if (property == 'length') RunClass.MovieMasher['msg'](this + '.setValue ' + value + ' ' + property);
				switch(property)
				{
					case 'selection':
						// respond to selection changes from triggers
						__setSelection(value.string);
						break;
					case PlayerProperty.LOCATION:
						if (_selection.length) __adjustEnableds(_selection.length);
						
						break;
					case 'split':
						if (__clipCanBeSplit(_selection.firstItem() as IClip))
						{
							new ClipSplitAction(_selection.firstItem() as IClip, _mash.getFrame());
							//dispatch = true;
							 __adjustEnableds(_selection.length);
						 }
						break;
					case 'zoom' :
						//super.setValue(value, property);
						__zoom = ((101 - Math.max(1, Math.min(100, value.number))) / 100);
				
				
						__hScrollReset();
						if (! __positionScroll())
						{
							_drawClips(true);
						}
						dispatch = true;
						break;
					case 'length' :
						super.setValue(value, property);
						// fallthrough to track
					case ClipProperty.TRACK:
						if (! __hScrollReset())
						{
							_drawClips();
						}
						break;
					case 'tracks' :
						__resetTracks();
						if (! __vScrollReset())
						{
							_drawClips();
						}
						break;
					case ControlProperty.MASH:
						mash = value.object as IMash;
						break;
					case 'cut' :
						clipboard = _selection.items;
						__doDelete();
						//_selectionDidChange(null);
						break;
					case 'copy' :
						clipboard = _selection.items;
						_selectionDidChange(null);
						break;
					case 'remove' :
						__doDelete();
						break;
					case 'paste' :
						var items:Array = clipboard;
						var clip:IClip = items[0] as IClip;
						var not_visual:Boolean = (! clip.isVisual());
						if (not_visual)
						{
							var span:Object = spanOfItems(items);
							var start:Number = _mash.getFrame();
							var track:uint = _mash.freeTrack(start, start + span.frame, clip.getValue(CommonWords.TYPE).string, span.tracks);
							new ClipsTimeAction(_mash, items, track, start);
						}
						else
						{
							new ClipsIndexAction(_mash, items, __insertIndex());
							
						}
						break;
					case 'redo' :
					case 'undo' :
						//RunClass.MovieMasher['msg'](this + '.setValue ' + property);
						Action[property]();
						break;
					case 'snap':
						dispatch = true;
						// fallthrough to default
					default:
						super.setValue(value, property);
				}
				if (dispatch)
				{
					dispatchEvent(new ChangeEvent(value, property));
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.setValue ' + property, e);
			}

			return false;
		}
		override public function initialize():void
		{
			super.initialize();
			_configCursor('trimleft');
			_configCursor('trimright');
			setValue(super.getValue('zoom'), 'zoom');
			
			
			var iconwidth:Number = getValue('iconwidth').number;
			if (iconwidth)
			{
				var mc : DisplayObject;
				var z:int = __trackKeys.length;
				var kk:int;
				var k:String;
				var path:String;
				var loader:IAssetFetcher;
				for (kk = 0; kk < z; kk++)
				{
					k = __trackKeys[kk] + 'icon';
					path = getValue(k).string;
					if (path.length)
					{
						loader = RunClass.MovieMasher['assetFetcher'](path);
						mc = loader.displayObject(path);
						
						if (mc != null)
						{
							_heights[__trackKeys[kk]] = mc.height;
						}
						
					}
				}
			}
			
		}
		override public function dragAccept(drag:DragData):void
		{
		 	
		 	var offset_pt:Point = ((drag.source == this) ? __dragOffset : new Point(drag.display.x - drag.display.getBounds(drag.display.parent).left, 0));
			var clip_index:Number;
			var pt:Point = _clickSprite.globalToLocal(drag.rootPoint);
			var clip:IClip = drag.items[0] as IClip;
			var clip_type:String = clip.getValue(CommonWords.TYPE).string;
			
			var not_visual = (! clip.isVisual());
			try
			{
				if (not_visual)
				{
					try
					{
						var span:Object = spanOfItems(drag.items);
						var track:uint = pixels2Track(pt.y + _scroll.y - offset_pt.y, clip_type, ((clip_type == ClipType.EFFECT) ? span.tracks : 0));
	
						var start_time:Number = Math.max(0, pixels2Frame(pt.x + _scroll.x - (offset_pt.x + getValue('iconwidth').number)));
						
						var free_time:Number = -1;
						while (free_time == -1)
						{
							free_time = _mash.freeTime(start_time, start_time + span.frame, clip_type, (clip.getValue(ClipProperty.MASH).undefined ? null : drag.items), track, span.tracks);
							if (free_time == -1) track++;
						}	
						new ClipsTimeAction(_mash, drag.items, track, free_time);
																						 
					}
					catch(e:*)
					{
						RunClass.MovieMasher['msg'](this + '.dragAccept', e);
					}
				}
				else
				{
					var mc:IPreview = __dragClip(drag.rootPoint);
					clip_index = ((mc == null) ? _mash.tracks.video.length : mc.clip.getValue('index').number);
					new ClipsIndexAction(_mash, drag.items, clip_index);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.dragAccept', e);
			}
		}
		override public function dragOver(drag:DragData):Boolean
		{
			var root_pt:Point = drag.rootPoint;
			var items:Array = drag.items;
			
			
			var offset_pt:Point = ((drag.source == this) ? __dragOffset : new Point(drag.display.x - drag.display.getBounds(drag.display.parent).left, 0));
			
			var ok:Boolean = false;
			var pt:Point = _clickSprite.globalToLocal(root_pt);
						
			try
			{
				if ((_mash != null) && (items[0] is IClip))
				{
					var clip:IClip = items[0] as IClip;
					var clip_type:String = clip.getValue(CommonWords.TYPE).string;
					
					switch (clip_type)
					{
						case ClipType.MASH:
							return false; // at the moment mashes can't be embedded in other mashes
						case ClipType.AUDIO:
							if (! getValue('audiotracks').boolean) return false;
							break;
						case ClipType.EFFECT:
							if (! getValue('effecttracks').boolean) return false;
							break;
						default:
							clip_type = ClipType.VIDEO;
							if (! getValue('videotracks').boolean) return false;

					}
					
					
					var not_visual:Boolean = (! clip.isVisual());
					
					var autoscroll:Number = (__zoom == 1) ? 0 : getValue('autoscroll').number;
					
					var iconwidth:Number = getValue('iconwidth').number;
			
					if (pt.x < (autoscroll + iconwidth))
					{
						__doScroll(-1, true);
					}
					else if (pt.x > (_width - autoscroll))
					{
						__doScroll(1, true);
					}
					if (pt.y < autoscroll)
					{
						__doScroll(-1, false);
					}
					else if (not_visual && (pt.y > (_height - autoscroll)))
					{
						__doScroll(1, false);
					}
				
					ok = true;
					try
					{
						_dragHilite.width = _width - iconwidth;
						_dragHilite.height = _height;
						_dragHilite.x = 0;
						_dragHilite.y = 0;
						
						if (not_visual)
						{
							var highest_track:Number = getValue(clip_type + 'tracks').number;
							var span:Object = spanOfItems(items);
							var track:Number = pixels2Track(pt.y + _scroll.y - offset_pt.y, clip_type, ((clip_type == ClipType.EFFECT) ? span.tracks : 0));
							//RunClass.MovieMasher['msg'](this + '.dragOver ' + track);
							
							
							var start_time:Number = Math.max(0, pixels2Frame(pt.x + _scroll.x - (offset_pt.x + getValue('iconwidth').number)));
							
							var free_time = -1;
							while (free_time == -1)
							{
								free_time = _mash.freeTime(start_time, start_time + span.frame, clip_type, (clip.getValue(ClipProperty.MASH).undefined ? null : items), track, span.tracks);
								if (free_time == -1) track++;
							//	else RunClass.MovieMasher['msg'](this + '.dragOver ' + track + ' ' + free_time);
								if ((highest_track != -1) && (track > highest_track))
								{
									//RunClass.MovieMasher['msg'](this + '.dragOver ' + track + ' > ' + highest_track);
									ok = false
									break;
								}
							}
							if (ok)
							{
								_dragHilite.x = frame2Pixels(free_time) - _scroll.x;
								_dragHilite.height = (typeHeight(clip_type) * span.tracks) + (span.tracks - 1);
								_dragHilite.width = frame2Pixels(span.frame);
								_dragHilite.y = __track2Pixels(track, clip_type) - _scroll.y;
							}
						}
						else
						{
							// is visual selection
							var mc:IPreview = __dragClip(root_pt);
							
							if ((! mc) && (clip_type == ClipType.TRANSITION) && _mash.tracks.video.length && _mash.tracks.video[_mash.tracks.video.length - 1].getValue(CommonWords.TYPE).equals(ClipType.TRANSITION))
							{
								return false;
							}
							
							if (mc && (! __isDropTarget(mc.clip.getValue('index').number, items)))
							{
								ok = false;
								mc = null;
							}
							
							if (mc != null)
							{
								
								var mc_size:Size = mc.size;
								
								_dragHilite.height = mc_size.height;
								_dragHilite.width = 5;// mc_size.width;
								_dragHilite.y = mc.displayObject.y;
								_dragHilite.x = mc.displayObject.x + mc.data.starttrans;
							}
							
						}
					}
					catch(e:*)
					{
						RunClass.MovieMasher['msg'](this + '.dragOver', e);
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.dragOver', e);
			}
			return ok;
		}
		override public function resize():void
		{
			super.resize();
			if (! _mash) return;
			__resetSizes();
			__icons_mask_mc.graphics.clear();
			RunClass.DrawUtility['fill'](__icons_mask_mc.graphics, _width, _height, 0, 0);
			var drew:Boolean = false;
			if (__hScrollReset()) drew = true;
			if (__vScrollReset()) drew = true;
			if (! drew) _drawClips();
		}
		public function pixels2Time(pixels : Number, rounding:String = 'round'):Number
		{
			if (_mash == null) return 0;			
			var available_pixels:Number = _viewSize.width - getValue('hscrollpadding').number;
			var displayed_seconds = getValue('length').number * __zoom;
			var pixels_per_second:Number = available_pixels / displayed_seconds;
			return Math[rounding](pixels) / pixels_per_second;
		}
		private function pixels2Frame(pixels : Number, rounding:String = 'round'):Number
		{ 
			if (_mash == null) return 0;
			var available_pixels:Number = _viewSize.width - getValue('hscrollpadding').number;
			var displayed_seconds = getValue('length').number * __zoom;
			var pixels_per_second:Number = available_pixels / displayed_seconds;
			return Math[rounding]((pixels / pixels_per_second) * __fps);
		}
		public function pixels2Track(y_pixels:Number, type:String, lowest_track:int = 0):int
		{
			if (lowest_track < 1)
			{
				lowest_track = 1;
			}
			var highest_track:int = __tracks[type];
			var track:int = 0;
			if (__tracks[type])
			{
				switch (type)
				{
					case ClipType.EFFECT :

						track = __tracks.effect - Math.round(y_pixels / typeHeight(ClipType.EFFECT));
						break;

					case ClipType.AUDIO :

						y_pixels -= __tracks.effect * typeHeight(ClipType.EFFECT);
						y_pixels -= __tracks.video * typeHeight(ClipType.VIDEO);
						if (__tracks.video && RunClass.Media['multitrackVideo'] && (! getValue('novisualaudio').boolean))
						{
							y_pixels -= typeHeight(ClipType.AUDIO);
						}

						track = Math.round(y_pixels / typeHeight(ClipType.AUDIO)) + 1;

						break;

				}
			}
			// don't let user create new tracks if config specified a set number of them
			track = Math.min(__tracks[type] + (getValue(type + 'tracks').number == -1 ? 1 : 0), track);
			if (track < lowest_track)
			{
				track = lowest_track;
			}
			return track;
		}
		override public function downPreview(preview:IPreview, event:MouseEvent):void
		{
			if ( ! (getValue('notrim').boolean && getValue('nodrag').boolean))
			{
				
				var item : IClip = preview.clip;
				var on_handle : Number = __onHandle(preview, event);
				var do_press = true;
				try
				{
					var clip:IClip;
					var sel_index:int = _selection.indexOf(item);
					var shift_down:Boolean = event.shiftKey;
					if (sel_index > -1)
					{
						if (shift_down)
						{
							if (_selection.length == 1)
							{
								_selection.removeItems();
							}
							else _selection.removeItem(item);
							do_press = false;
						}
					}
					else
					{
						// item wasn't selected
						if (shift_down)
						{
							
							// make sure selection is all audio OR effects OR visual items
							clip = _selection.firstItem() as IClip;
							if (clip != null)
							{
								if ((item.isVisual() != clip.isVisual()) || ((! item.isVisual()) && (! item.getValue(CommonWords.TYPE).equals(clip.getValue(CommonWords.TYPE)))))
								{
									shift_down = false;
								}
							}
							if (shift_down)
							{
								_selection.push(item);
							}
						}
						if (! shift_down)
						{
							_selection.removeItems(true);
							_selection.push(item);
						}
					}
	
					if (do_press && on_handle && (_selection.length == 1) && (! getValue('notrim').boolean))
					{
						do_press = __trimStart(event, on_handle, _selection.firstItem() as IClip);
					}
					if (do_press)
					{
						do_press = __itemsCanBeMoved();
					}
					if (do_press && (! getValue('nodrag').boolean))
					{
						__dragStart(event);
					}
					_drawClips();
				}
				catch(e:*)
				{
					RunClass.MovieMasher['msg'](this + '.downPreview', e);
				}
			}
		}
		override public function overPreview(preview:IPreview, event:MouseEvent):void
		{
			if (! getValue('notrim').boolean)
			{
				__setCursor(__onHandle(preview, event));
			}
			else if (! getValue('nodrag').boolean)
			{
				__setCursor(0);
			}
		}
		override public function updateTooltip(tooltip:ITooltip):Boolean
		{
			var dont_delete:Boolean = false;
			var tip:String;
			try
			{
				tip = getValue('tooltip').string;
				dont_delete = Boolean(tip.length);

				if (dont_delete && (tip.indexOf('{') != -1))
				{
					var ipreview:IPreview = __dragClip(tooltip.point);
					if (ipreview == null) tip = '';
					else tip = RunClass.ParseUtility['brackets'](tip, ipreview.clip);
					dont_delete = Boolean(tip.length);
				}
				if (dont_delete) tooltip.text = tip;
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}		
			return dont_delete;
		}
		public function spanOfItems(items : Array):Object
		{
			var ob:Object = new Object();
			var clip:IClip = items[0] as IClip;
			var select_start : Number = clip.startFrame;
			var select_end : Number = select_start + clip.lengthFrame;
			
			try
			{
				var track_start : uint = clip.getValue(ClipProperty.TRACK).number;
				var track_end : uint = track_start;
				var z:uint = items.length;
				var clip_start:Number;
				var item_track : uint;
				for (var i:uint = 1; i < z; i++)
				{
					clip = items[i] as IClip;
					clip_start = clip.startFrame;
					item_track = clip.getValue(ClipProperty.TRACK).number;
					track_start = Math.min(track_start, item_track);
					track_end = Math.max(track_end, item_track);
					select_start = Math.min(select_start, clip_start);
					select_end = Math.max(select_end, clip_start + clip.lengthFrame);
				}
				ob.frame = select_end - select_start;
				ob.tracks = 1 + track_end - track_start;
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.spanOfItems', e);
			}
			return ob;
		}
		public function time2Pixels(seconds : Number = 0, rounding : String = 'ceil'):Number
		{
			var pixels:Number = 0;
			if (seconds && (_mash != null)) 
			{
				var available_pixels:Number = _viewSize.width - getValue('hscrollpadding').number;
				var displayed_seconds = getValue('length').number * __zoom;
				var pixels_per_second:Number = available_pixels / displayed_seconds;
				pixels = Math[rounding](seconds * pixels_per_second);
			}
			return pixels;
		}
		public function frame2Pixels(seconds : Number = 0, rounding : String = 'ceil'):Number
		{
			var pixels:Number = 0;
			if (seconds && (_mash != null)) 
			{
				var available_pixels:Number = _viewSize.width - getValue('hscrollpadding').number;
				var displayed_seconds = getValue('length').number * __zoom;
				var pixels_per_second:Number = available_pixels / displayed_seconds;
				pixels = Math[rounding]((seconds / __fps) * pixels_per_second);
			}
			//if (seconds) pixels = Math[rounding](seconds * __zoom);
			
			return pixels;
		}
		public function typeHeight(type : String, subtract_line : Boolean = false) : int
		{
			if ( ! ((type == ClipType.AUDIO) || (type == ClipType.EFFECT) || (type == 'clip')))
			{
				type = ClipType.VIDEO;
			}
			var n:int = _heights[type];
			if (subtract_line) n -= getValue('line').number;
			
			return n;
		}
		public function get clipboard():Array
		{
			return __cloneItems(__clipboard);
		}
		public function set clipboard(s : Array):void
		{
			__clipboard = __cloneItems(s);
		}
		public function get mash():IMash
		{
			return _mash;
		}
		public function set mash(new_mash : IMash):void
		{
			if (_mash)
			{
				_mash.removeEventListener(PlayerProperty.LOCATION, changeEvent);
				
				_selection.items = new Array();
				_deleteClips();
				Action.clear();
			}
			_mash = new_mash;
			
			if (_mash)
			{
				__fps = _mash.getValue(MashProperty.QUANTIZE).number;
				_mash.addEventListener(PlayerProperty.LOCATION, changeEvent);
				var select:String = getValue('autoselect').string;
				if (! select.length) select = _mash.getValue('autoselect').string;
				if (select.length)
				{
					switch (select)
					{
						case ControlProperty.MASH:
							_selection.items = new Array(_mash);
							break;
						default:
							__setSelection(select);
							
					}
				}
				
			}
			resize();
			dispatchEvent(new ChangeEvent(getValue('zoom'), 'zoom'));
		}
		override protected function _createChildren():void
		{
			try
			{
				
				//__resetTrackCounts();
				
				super._createChildren();
				
				
				Action.eventDispatcher.addEventListener(ActionEvent.ACTION, __actionEvent);
				// all track heights to be overridden by cliptrack, videotrack, etc.
				var k : String;
				var z:int = __trackKeys.length;
				var track:Number;
				var kk:int;
	
				for (kk = 0; kk < z; kk++)
				{
					k = __trackKeys[kk];
					track = getValue(k + ClipProperty.TRACK).number;
					if (track)
					{
						_heights[k] = track;
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._createChildren', e);
			}
			
			var mc:Sprite;
			mc = new Sprite();
			mc.name = 'other_mc';
			_clipsSprite.addChildAt(mc, 0);
			mc = new Sprite();
			mc.name = 'trans_mc';
			_clipsSprite.addChildAt(mc, 0);

			__icons_mc = new Sprite();
			addChild(__icons_mc);
			__icons_mask_mc = new Sprite();
			addChild(__icons_mask_mc);
			__icons_mc.mask = __icons_mask_mc;
			var iconwidth:Number = getValue('iconwidth').number;
			if (iconwidth)
			{
				_displayObjectLoad('clipicon');
				_displayObjectLoad('audioicon');
				_displayObjectLoad('effecticon');
				_displayObjectLoad('videoicon');
			}
			var cursors:Array = ['trimleft', 'trimright', 'hover', 'drag'];
			z = cursors.length;
			for (kk = 0; kk < z; kk++)
			{
				k = cursors[kk];
				__createCursor(k);
			}	
			if (! getValue('nodrop').boolean) RunClass.DragUtility['addTarget'](this);
			
			_createTooltip();

		}
		override protected function _drawClips(force : Boolean = false):void
		{
			
			if (force)
			{
				__drawClipsTimed(null);
			}
			else if (__drawClipsTimer == null)
			{
				__drawClipsTimer = new Timer(100,1);
				__drawClipsTimer.addEventListener(TimerEvent.TIMER, __drawClipsTimed);
				__drawClipsTimer.start();
			}
		}
		override protected function _isSelected(preview:IPreview):Boolean
		{
			var selected:Boolean = false;
			for (var k:* in _visibleClips)
			{
				
				if (_visibleClips[k] == preview)
				{
					selected = (_selection.indexOf(k) != -1);
					break;
				}
			}
			return selected;
		}
		override protected function _previewData(clip:IClip):Object
		{
			var object:Object = new Object();
			var is_multitrack:Boolean = false;
			var clip_index:Number;
			var options_x:Number;
			var options_width:Number;
			try
			{
				object[MediaProperty.LABEL] = clip.getValue(MediaProperty.LABEL).string;
				switch(clip.type)
				{
					case ClipType.AUDIO:
						is_multitrack = true;
						break;
					case ClipType.MASH:
					case ClipType.VIDEO:
						is_multitrack = clip.getValue(ClipProperty.HASAUDIO).boolean;
						break;
					case ClipType.TRANSITION: 
						if (! ((clip.getValue(ClipProperty.FREEZESTART).boolean && clip.getValue(ClipProperty.FREEZEEND).boolean))) 
						{
							var index:Number = -1;
							index = _mash.tracks.video.indexOf(clip);
							if (index > -1)
							{
								if (index && _mash.tracks.video[index - 1].getValue(ClipProperty.HASAUDIO).boolean) is_multitrack = true;
								else if ((index < (_mash.tracks.video.length - 1)) && _mash.tracks.video[index + 1].getValue(ClipProperty.HASAUDIO).boolean) is_multitrack = true;
							}
						}
						break;
				}
				if (is_multitrack && (clip.type != ClipType.AUDIO)) 
				{
					is_multitrack = ! getValue('novisualaudio').boolean;
				}
				object[ClipProperty.HASAUDIO] = is_multitrack;
				if (is_multitrack) 
				{
					object[ClipProperty.LOOPS] = clip.getValue(ClipProperty.LOOPS).number;
					if (clip.media.getValue(MediaProperty.WAVE).string.length)
					{
						object['durationpixels'] = frame2Pixels(clip.getValue(MediaProperty.DURATION).number);
						object[ClipProperty.STARTFRAME] = clip.getValue(ClipProperty.STARTFRAME).number;
						object[ClipProperty.TRIMSTARTFRAME] = clip.getValue(ClipProperty.TRIMSTARTFRAME).number;
						if (object[ClipProperty.TRIMSTARTFRAME]) object['trimstranslation'] = frame2Pixels(object[ClipProperty.TRIMSTARTFRAME] - object[ClipProperty.STARTFRAME], 'round') + frame2Pixels(object[ClipProperty.STARTFRAME], 'round'); 
					}
				}
				clip_index = clip.getValue('index').number;
				options_x = frame2Pixels(clip.startFrame, 'round') - _scroll.x;
				options_width = Math.max(1, frame2Pixels(clip.lengthFrame, 'ceil'));
				
				object['x'] = options_x;
				object['y'] = __track2Pixels(clip.getValue(ClipProperty.TRACK).number, clip.type) - _scroll.y;
				object['width'] = options_width;
				object['starttrans'] = (((clip_index < 0)) ? 0 : frame2Pixels(clip.getValue(ClipProperty.TIMELINESTARTFRAME).number, 'floor'));
				object['endtrans'] = (((clip_index < 0)) ? 0 : frame2Pixels(clip.getValue(ClipProperty.TIMELINEENDFRAME).number, 'floor'));
				object['leftcrop'] = ((options_x < 0) ? -options_x : 0);
				object['rightcrop'] = ((_viewSize.width < (options_x + options_width)) ? _viewSize.width - (options_x + options_width) : 0);
				//RunClass.MovieMasher['msg'](this + '._previewData width = ' + object['width']);
				
			}
			catch (e:*)
			{
				RunClass.MovieMasher['msg'](this + '._previewData', e);
			}
			return object;
		}
		override protected function _selectionDidChange(event:Event):void
		{
			try
			{
				//RunClass.MovieMasher['msg(this + '._selectionDidChange ' + _selection.length);// + ' ' + getValue']('mashselect').boolean + ' ' + _mash);
				
				var z:uint = _selection.length;
				
				if ((! z) && getValue('autoselect').equals(ControlProperty.MASH))
				{
					_selection.push(_mash);
				}
				else 
				{
					__adjustEnableds(z);
					
					_updateSelection();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '._selectionDidChange', e);
			}
		}
		private function __adjustEnableds(z:uint):void
		{
			var action_enabled:Boolean;
			for (var property in __enabledControls)
			{
				action_enabled = __actionIsEnabled(property, z);
				if (__enabledControls[property] != action_enabled)
				{
					__enabledControls[property] = action_enabled;
					dispatchEvent(new ChangeEvent(getValue(property), property));
				}
			}
		
		}
		private function __actionEvent(event : ActionEvent):void
		{
			try
			{
				_drawClips(true);
				// some action was taken by the user
				if (event.action != null)
				{
					_selection.items = event.action.targets;
				}
				else
				{
					_selection.removeItems();
				}
				//_selectionDidChange(null);
				dispatchEvent(new ChangeEvent(new Value(), 'refresh'));
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__actionEvent', e);
			}
		}
		private function __cloneItems(a : Array):Array
		{
			var items : Array = [];
			var z = a.length;
			var item:IClip;
			for (var i = 0; i < z; i++)
			{
				item = a[i].clone();
				item.setValue(new Value(), ClipProperty.MASH);
				items.push(item);
			}
			return items;
		}
		private function __createClip(clip:IClip, container:DisplayObjectContainer = null):IPreview
		{
			var preview : IPreview;
			try
			{
				if (container == null)
				{
					container = _clipsSprite.getChildByName((clip.getValue(CommonWords.TYPE).equals(ClipType.TRANSITION) ? 'trans' : 'other') + '_mc') as DisplayObjectContainer;
				}
				if (container != null)
				{
					preview = _instanceFromOptions(__previewOptions(clip), clip.media.tag, clip);
					if (preview != null)
					{
						container.addChild(preview.displayObject);
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__createClip', e);
			}
			return preview;
		}
		private function __createCursor(cursor_name : String)
		{
			var cursor:String = getValue(cursor_name + 'icon').string;
			if (cursor.length)
			{
				var c:Array = cursor.split(';');
				_displayObjectLoad(c[0], true);
			}
		}
		private function __doDelete():void
		{
			if (_selection.length)
			{
				var clip:IClip = _selection.firstItem() as IClip;
				var not_visual = (! clip.isVisual());
				if (not_visual)
				{
					new ClipsTimeAction(_mash, _selection.items);
				}
				else
				{
					new ClipsIndexAction(_mash, _selection.items);
				}
			}
		}
		private function __dragClip(root_pt:Point):IPreview
		{
			var mc : IPreview = null;
			for each (mc in _visibleClips)
			{
				if (mc.displayObject.hitTestPoint(root_pt.x, root_pt.y, false))
				{
					break;
				}
				mc = null;
			}
			return mc;
		}
		private function __dragStart(event:MouseEvent):void
		{
			try
			{
				
				_changeCursor();
				
				var drag_data:DragData = new DragData();
				drag_data.clickPoint = new Point(mouseX, mouseY);
				drag_data.previewCallback = __dragPreview;

				drag_data.source = this;
				drag_data.items = _selection.items;
				drag_data.callback = __finishedDrag;
				RunClass.DragUtility['begin'](event, drag_data);
				
				//drag_data.display = wrapper;
				//_changeCursor('drag');
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__dragStart', e);
			}

		}
		private function __dragPreview(drag_data:Object):DisplayObjectContainer
		{
			var wrapper:Sprite = new Sprite();
			try
			{
				var clip:IClip = drag_data.items[0] as IClip;
				var clip_type:String = clip.getValue(CommonWords.TYPE).string;
				
				__dragOffset = new Point();
				
				if (clip_type == ClipType.EFFECT)
				{
					drag_data.items.sortOn(ClipProperty.TRACK, Array.DESCENDING | Array.NUMERIC);
				}
				else
				{
					drag_data.items.sortOn(ClipProperty.TRACK, Array.NUMERIC);
				}
				__dragOffset.y = (_scroll.y + drag_data.clickPoint.y) - __track2Pixels(clip.getValue(ClipProperty.TRACK).number, clip_type);
				drag_data.items.sortOn('startFrame', Array.NUMERIC);
				__dragOffset.x = (_scroll.x + drag_data.clickPoint.x - getValue('iconwidth').number) - frame2Pixels(clip.startFrame);
				
				var z:uint = drag_data.items.length;
				var sprite:Sprite = new Sprite();
				wrapper.addChild(sprite);
				sprite.x = - (drag_data.clickPoint.x - getValue('iconwidth').number);
				sprite.y = - drag_data.clickPoint.y;
				
				sprite.alpha = .7;
				var preview:IPreview;
				for (var i:uint = 0; i < z; i++)
				{
					clip = drag_data.items[i];
					preview = __createClip(clip, sprite);
					preview.selected = true;
				}
				_changeCursor('drag');
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__dragPreview', e);
			}
			return wrapper;
		}
		private function __finishedDrag(drag:DragData):void
		{
			if (drag.display != null) _removePreviews(drag.display.getChildAt(0) as DisplayObjectContainer);
			if (drag.rootPoint.length)
			{
				
				var pt:Point = globalToLocal(drag.rootPoint);
				var rect:Rectangle = new Rectangle(0,0,_width, _height);
				
				
				//RunClass.MovieMasher['msg(this + '.__finishedDrag ' + rect + ' ' + pt + ' ' + rect.containsPoint'](pt));
				if (! rect.containsPoint(pt))
				{
					__doDelete();
				
				}
			}
		
		}
		private function __drawClipsTimed(event:TimerEvent):void
		{
			if (__drawClipsTimer != null)
			{
				__drawClipsTimer.stop();
				__drawClipsTimer.removeEventListener(TimerEvent.TIMER, __drawClipsTimed);
				__drawClipsTimer = null;
			}
			var clip:IClip;
			var newClips:Dictionary = new Dictionary();
			var changed:Boolean;
			var viewable_clips:Array = __viewableClips();
			var z : Number = viewable_clips.length;
			var object:Object;
			var preview:IPreview;
			var i:Number;
			var data:Object;
			var k:String;
			try
			{
				for (i = 0; i < z; i++)
				{
					clip = viewable_clips[i];
					
					if (clip != null)
					{
						preview = _visibleClips[clip];
						changed = (preview == null);
						if (changed) preview = __createClip(clip);
						else delete _visibleClips[clip];
						
						newClips[clip] = preview;
						object = _previewData(clip);
						if (! changed)
						{
							data = preview.data;
							changed = (data == null);
							
							if (! changed)
							{
								for (k in object)
								{
									if (object[k] != data[k])
									{
										changed = true;
										break;
									}
								}
							}
						}
						if (changed) preview.data = object;
					}
				}
				_deleteClips();
				_visibleClips = newClips;
				
				__icons_mc.y = - _scroll.y;
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__drawClipsTimed', e);
			}
		}
		private function __actionIsEnabled(property : String, z:uint):Boolean
		{
			var should_be_enabled : Boolean = true;
			try
			{
				
				switch (property)
				{
					case 'copy':
						should_be_enabled = ((z > 0) && (_selection.firstItem() is IClip));
						break;
					case 'cut':
					case 'remove':
						
						should_be_enabled = __itemsCanBeMoved();
						break;
					case 'paste':
	
						should_be_enabled = (clipboard.length > 0);
						if (should_be_enabled && clipboard[0].isVisual())
						{
							var insert_index:Number = __insertIndex();
							should_be_enabled = __isDropTarget(insert_index, clipboard);
						}
						break;
					case 'undo':
						should_be_enabled = (Action.currentDo > -1);
						break;
					case 'redo':
						should_be_enabled = (Action.currentDo < (Action.doStack.length - 1));
						break;
					case 'snap':
						should_be_enabled = getValue(property).boolean;
						break;
					case 'split':
						should_be_enabled = ((z > 0) && (_selection.firstItem() is IClip));
						if (should_be_enabled)
						{
							should_be_enabled = __clipCanBeSplit(_selection.firstItem() as IClip);
						}
						break;
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__actionIsEnabled ' + property + ' ' + z + ' ' + should_be_enabled, e);
			
			}
			return should_be_enabled;
		}
		private function __clipCanBeSplit(clip:IClip):Boolean
		{
			var can:Boolean = false;
			var type:String;
			try
			{
				type = clip.type;
				switch(type)
				{
					case ClipType.TRANSITION: 
						break;
					case ClipType.AUDIO:
					case ClipType.VIDEO:
						if (! clip.canTrim)
						{
							break;
						}
					case ClipType.IMAGE:
					case ClipType.THEME:
					case ClipType.EFFECT:
						var location:Number = _mash.getFrame();
						var frame:Number = clip.startFrame;
						if (location >= (frame + 1)) 
						{
							frame += clip.lengthFrame;
							if (location <= (frame - 1)) 
							{
								can = true;
							}
						}
				}
			
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__clipCanBeSplit ' + clip + ' _mash = ' + _mash, e);
			
			}
			return can;
		}
		private function __calculateContentHeight():void
		{
			__contentHeight = 0;
		
			if (__tracks.video)
			{
				__contentHeight += typeHeight(ClipType.VIDEO);
				if (RunClass.Media['multitrackVideo'] && (! getValue('novisualaudio').boolean))
				{
					__contentHeight += typeHeight(ClipType.AUDIO);
				}
			}
			if (__tracks.audio)
			{
				__contentHeight += __tracks.audio * typeHeight(ClipType.AUDIO);
			}
			if (__tracks.effect)
			{
				__contentHeight += __tracks.effect * typeHeight(ClipType.EFFECT);
			}
				
		}
		private function __hScrollReset():Boolean
		{
			var new_w:Number = getValue('hscrollpadding').number;
			if (_mash)
			{
				new_w += Math.round(time2Pixels(getValue('length').number));
			}
			return _setScrollDimension('width', new_w);
		}
		private function __onHandle(preview:IPreview, event:MouseEvent) : Number 
		{ 
			var is_within : Number = 0;
			try
			{
				if (! getValue('notrim').boolean)
				{
					if (! preview.clip.getValue('readonly').boolean)
					{
						var options:IOptions = preview.options;
					
						if (! ((options.getValue(CommonWords.TYPE).equals(ClipType.AUDIO)) && ((preview.clip).getValue('loop').boolean)))
						{
							var x_pos:Number = event.localX;
							var trimto:Number = getValue('trimto').number;
							var size:Size = preview.size;
							trimto = Math.min(trimto, Math.round(size.width / 4));
							if (trimto)
							{
								if (x_pos <= trimto) is_within = -1;
								else if (x_pos >= (size.width - trimto)) 
								{
									is_within = 1;
								}
							}
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return is_within;
		}
		private function __previewOptions(clip:IClip):IOptions
		{
			var options:IOptions = null;
			try
			{
				var type:String = clip[CommonWords.TYPE];
				options = _itemOptions(type);
				
				
				var media_icon:String = clip.getValue('icon').string;
				if (media_icon.length)
				{
					options.setValue(new Value(media_icon), 'icon');
				}
				
				
				// create spacing for line between tracks
				options.setValue(getValue('line'), ControlProperty.SPACING);
				
				// create height for clip type (audio will get set below)
				if (type != ClipType.AUDIO) options.setValue(new Value(typeHeight(type, true)), type + 'height');
				
				var is_multitrack:Boolean = false;
					
				switch(type)
				{
					case ClipType.AUDIO:
						is_multitrack = true;
						break;
					case ClipType.MASH:
					case ClipType.VIDEO:
						is_multitrack = clip.getValue(ClipProperty.HASAUDIO).boolean;
						break;
					case ClipType.TRANSITION: 
						if (! ((clip.getValue(ClipProperty.FREEZESTART).boolean && clip.getValue(ClipProperty.FREEZEEND).boolean))) 
						{
							var index:Number = -1;
							index = _mash.tracks.video.indexOf(clip);
							if (index > -1)
							{
								if (index && _mash.tracks.video[index - 1].getValue(ClipProperty.HASAUDIO).boolean) is_multitrack = true;
								else if ((index < (_mash.tracks.video.length - 1)) && _mash.tracks.video[index + 1].getValue(ClipProperty.HASAUDIO).boolean) is_multitrack = true;
							}
						}
						break;
				}
				if (is_multitrack)
				{
					
					options.setValue(new Value(typeHeight(ClipType.AUDIO, true)), 'audioheight');
					options.setValue(clip.media.getValue(MediaProperty.WAVE), MediaProperty.WAVE);
					options.setValue(clip.media.getValue(MediaProperty.LOOP), MediaProperty.LOOP);
				}
			}
			catch (e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__previewOptions', e);
			}
			return options;
		}
		private function __insertIndex():uint
		{
			var i:uint = 0;
			var item:IClip = _selection.firstItem() as IClip;
			
			if (item != null)
			{
				i = item.getValue('index').number;
			}
			else
			{
				var now:Number = RunClass.MovieMasher['evaluate']('player.location');
				
					
				if ((_mash != null) && _mash.tracks.video.length)
				{
					var frame:Number = RunClass.TimeUtility['frameFromTime'](now, __fps);
					var clips:Array = _mash.clipsInTracks(frame, frame, ClipType.VIDEO, true);
					if (! clips.length)
					{
						i = _mash.tracks.video.length - 1;
					}
					else
					{
						i = clips[0].getValue('index').number;
					}
				}
				
			
			}
			return i;
		}
		private function __isDropTarget(index : Number, items : Array):Boolean
		{
			var ok = true;
			try
			{
				// see if transition is first or last in selection 
				var clip:IClip = items[0];
				var first_is:Boolean = (clip.getValue(CommonWords.TYPE).equals(ClipType.TRANSITION));
				clip = items[items.length - 1];
				var last_is:Boolean = (clip.getValue(CommonWords.TYPE).equals(ClipType.TRANSITION));
				if (first_is || last_is)
				{
					clip = _mash.tracks.video[index];
					// see if we're dropping on or next to a transition
					if (last_is && (clip.getValue(CommonWords.TYPE).equals(ClipType.TRANSITION)))
					{
						ok = false;
					}
					else if (first_is && index)
					{
						clip = _mash.tracks.video[index - 1];
						if (clip.getValue(CommonWords.TYPE).equals(ClipType.TRANSITION))
						{
							ok = false;
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__isDropTarget', e);
			}
			return ok;
		}
		private function __itemsCanBeMoved():Boolean
		{
			var can_remove : Boolean = false;
			try
			{
				var items:Array = _selection.items;
				var z : int = items.length;
				if ((z > 0) && (items[0] is IClip))
				{
	
					var item:IClip = items[0];
					if (item != null)
					{
						can_remove = (item.getValue(ClipProperty.TRACK).number >= 0);
						if (can_remove)
						{
							can_remove = ! item.isVisual();
							if (! can_remove)
							{
								can_remove = true;
								var i : int;
								var item_mash:IMash;
								var index : Number;
								var is_selected : Dictionary = new Dictionary();
								var left_index : Number;
								var right_index : Number;
								var yy:int;
			
								for (i = 0; i < z; i++)
								{
									item = items[i];
									is_selected[item] = true;
								}
								for (i = 0; i < z; i++)
								{
									item = items[i];
									if (item != null)
									{
										item_mash = item.getValue(ClipType.MASH).object as IMash;
										
										if (item_mash != null)
										{
											index = item.getValue('index').number;
					
											left_index = index - 1;
											while (left_index > -1)
											{
												item = item_mash.tracks.video[left_index];
												if (! is_selected[item])
												{
													break;
												}
												left_index --;
											}
											if (left_index > -1)
											{
												right_index = index + 1;
												yy = item_mash.tracks.video.length;
												while (right_index < yy)
												{
													item = item_mash.tracks.video[right_index];
													if (item != null)
													{
														if (! is_selected[item])
														{
															break;
														}
													}
													right_index ++;
												}
												if (right_index < yy)
												{
													item = item_mash.tracks.video[left_index];
													if (item != null)
													{
														if (item.getValue(CommonWords.TYPE).equals(ClipType.TRANSITION))
														{
															item = item_mash.tracks.video[right_index];
															if (item != null)
															{
																if (item.getValue(CommonWords.TYPE).equals(ClipType.TRANSITION))
																{
																	can_remove = false;
																	break;
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__itemsCanBeMoved', e);
			}
			return can_remove;
		}
		private function __resetSizes():void
		{
			__resetTracks();
			var iconwidth:Number = getValue('iconwidth').number;
			_viewSize.width = _width - iconwidth;
			_clipsSprite.x = iconwidth;
		}
		private function __resetTrackCounts():void
		{
			

			if (_mash != null)
			{
				var videotracks:Number = getValue('videotracks').number;
				var audiotracks:Number = getValue('audiotracks').number;
				var effecttracks:Number = getValue('effecttracks').number;
				//RunClass.MovieMasher['msg'](this + '.__resetTrackCounts ' + videotracks + ' ' + audiotracks + ' ' + effecttracks);
				__tracks.video = ((videotracks == -1) ? _mash.getValue(ClipType.VIDEO).number : (videotracks ? 1 : 0));
				__tracks.audio = ((audiotracks == -1) ? _mash.getValue(ClipType.AUDIO).number : (audiotracks ? audiotracks : 0));
				__tracks.effect = ((effecttracks == -1) ? _mash.getValue(ClipType.EFFECT).number : (effecttracks ? effecttracks : 0));
			}
		}
		private function __resetTracks():void
		{
			if (_width && (_mash != null))
			{
				
				__resetTrackCounts();
				
				var i : Number;
				var z : Number;
				var clip_name : String;
				var y_pos : Number = 0;
				var k : String;
				__icons_mc.graphics.clear();
				var c;
				var mc:DisplayObject;
				var line:Number = getValue('line').number;
				var linegrad:Number = getValue('linegrad').number;
				var iconwidth:Number = getValue('iconwidth').number;
				var linecolor:String = getValue('linecolor').string;
	
				if (line && linecolor.length)
				{
					c = RunClass.DrawUtility['colorFromHex'](linecolor);
				}
				
				var icon:String;
				var loader:IAssetFetcher;
				for (var kk = 0; kk < 4; kk++)
				{
					k = __trackKeys[kk];
					i = 0;
					z =  __tracks[k];
					if ((k == ClipType.AUDIO) && __tracks.video && RunClass.Media['multitrackVideo'] && (! getValue('novisualaudio').boolean))
					{
						z++;
					}
					icon = getValue(k + 'icon').string;
					for (; i < z; i++)
					{
						if (icon.length)
						{
							clip_name = k + 'icon' + i + '_mc';
							mc = __icons_mc.getChildByName(clip_name) as DisplayObject;
							if (mc == null)
							{
								loader = RunClass.MovieMasher['assetFetcher'](icon);
								
								mc = loader.displayObject(icon);
								if (mc != null)
								{
									mc.name = clip_name;
									__icons_mc.addChild(mc);
								}
							}
							if (mc != null)
							{
								mc.y = y_pos;
							}
						}
						y_pos += _heights[k];
						if (line)
						{
							if (linegrad)
							{
								RunClass.DrawUtility['fillBoxGrad'](__icons_mc.graphics, 0, y_pos - line, _width, line, RunClass.DrawUtility['gradientFill'](_width, line, c, linegrad, getValue('liineangle').number));
							}
							else if (linecolor.length)
							{
								RunClass.DrawUtility['fillBox'](__icons_mc.graphics, 0, y_pos - line, _width, line, c);
							}
						}
					}
				
					if (icon.length)
					{
						clip_name = k + 'icon' + i + '_mc';
	
						while (mc = __icons_mc.getChildByName(clip_name) as DisplayObject)
						{
							__icons_mc.removeChild(mc);
							i++;
							clip_name = k + 'icon' + i + '_mc';
						}
					}
				}
				__calculateContentHeight();
			}
		}
		private function __positionScroll():Boolean
		{
			var new_pos:Number = 0;
			var did_draw:Boolean = false;
			if (_mash)
			{
				new_pos = Math.max(0, Math.min((_scroll.width - _width), time2Pixels(RunClass.TimeUtility['timeFromFrame'](_mash.getFrame(), __fps)) - (_width / 2)));
			}
			
			did_draw = Boolean(_scrollTo(true, new_pos));
			return did_draw;
		}
		private function __setCursor(cursor : Number):void
		{
			try
			{
				_changeCursor(__rollCursors[1 + cursor]);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.setCursor', e);
			}
		}
		private function __setSelection(select:String):void
		{
			// supported: '', 'clips', 'audio', 'effect', 'video'
			var types:Array;
			var type:String;
			var new_selection:Array = new Array();
			
			var i_clip:IClip;
			if (select.length) 
			{
				types = new Array();
				if (select == 'clips') 
				{
					types.push(ClipType.AUDIO);
					types.push(ClipType.EFFECT);
					types.push(ClipType.VIDEO);
					
				}
				else types.push(select);
				for each(type in types)
				{
					for each (i_clip in _mash.tracks[type])
					{
						new_selection.push(i_clip);
					}
				}
			}
			_selection.items = new_selection;
		}
		private function __snapMouse(x_pos : Number):Number
		{
			try
			{
				var matches:Array = new Array();
				var x : Number;
				var d : Number;
				var snapto:Number = getValue('snapto').number;
				var back_mc:Rectangle;
				var ipreview:IPreview;
				var item_start:Number;
				var ob:Object;
				for (var k:* in _visibleClips)
				{
					ipreview = _visibleClips[k];
					if (__trimInfo.clip == ipreview.clip)
					{
						continue;
					}
					if ((! __trimInfo.not_visual) && ipreview.clip.isVisual())
					{
						continue;
					}
					back_mc = ipreview.backBounds;
					x = (ipreview.displayObject.x + back_mc.x);
					d = Math.abs(x_pos - x);
					item_start = ipreview.clip.startFrame;
					if (snapto > d)
					{
						ob = new Object();
						ob.d = d;
						ob.t = item_start + ipreview.clip.getValue(ClipProperty.TIMELINESTARTFRAME).number;
						matches.push(ob);
					}
					x += back_mc.width;
					d = Math.abs(x_pos - x);
					if (snapto > d)
					{
						ob = new Object();
						ob.d = d;
						ob.t = item_start + ipreview.clip.lengthFrame - ipreview.clip.getValue(ClipProperty.TIMELINEENDFRAME).number;
						matches.push(ob);
					}
				}
				if (matches.length)
				{
					
					matches.sortOn('d', Array.NUMERIC);
					ob = matches[0];
					x_pos = frame2Pixels(ob.t) - _scroll.x;
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__snapMouse', e);
			}
			return x_pos;
		}
		private function __track2Pixels(track:Number, type:String):Number
		{
			var pixels:Number = 0;
			switch (type)
			{
				case ClipType.EFFECT :

					pixels += (__tracks.effect - track) * typeHeight(ClipType.EFFECT);
					break;

				case ClipType.AUDIO :

					if (__tracks.video)
					{
						pixels += typeHeight(ClipType.VIDEO);
					}

					pixels += (track + ((__tracks.video && RunClass.Media['multitrackVideo'] && (! getValue('novisualaudio').boolean)) ? 0 : -1) ) * typeHeight(ClipType.AUDIO);
					// intentional fallthrough to default

				default :

					pixels += __tracks.effect * typeHeight(ClipType.EFFECT);


			}
			return pixels;
		}
		private function __trimStart(event:MouseEvent, direction : Number, clip : IClip):Boolean
		{
			var do_press:Boolean = (clip.editableProperties() == null);
			if (! do_press)
			{
				var i : Number;
				var items;
				__trimInfo = new Object();
				__trimInfo.direction = direction;
				__trimInfo.clip = clip;
				
				__trimInfo.orig_data = new Object();
				__trimInfo.orig_data.start = clip.startFrame;
				__trimInfo.orig_data.length = clip.lengthFrame;
				
				// set the mouse to the first or last pixel of clip
				if (direction < 0) __trimInfo.clipX = frame2Pixels(clip.startFrame + clip.getValue(ClipProperty.TIMELINESTARTFRAME).number) - _scroll.x;
				else __trimInfo.clipX = frame2Pixels(clip.startFrame + clip.lengthFrame - clip.getValue(ClipProperty.TIMELINEENDFRAME).number) - _scroll.x;
				
				__trimInfo.not_visual = false;
				var clip_type:String = clip.getValue(CommonWords.TYPE).string;
				var clip_track:int = clip.getValue(ClipProperty.TRACK).number;
				var clip_length:Number = clip.lengthFrame;
				var item:IClip;
				if (clip_type == ClipType.EFFECT)
				{
					__trimInfo.not_visual = true;
					if (direction < 0)
					{
						__trimInfo.end_time = (__trimInfo.orig_data.start + clip_length);
						__trimInfo.max_start =(__trimInfo.end_time - 1);
						items = _mash.clipsInOuterTracks(0, __trimInfo.orig_data.start, [clip], clip_track, 1, clip_type);
						__trimInfo.min_start = 0;
	
						for (i = 0; i < items.length; i++)
						{
							item = items[i];
							__trimInfo.min_start = Math.max(__trimInfo.min_start, item.startFrame + item.lengthFrame);
						}
					}
				}
				else if ((clip_type == ClipType.AUDIO) || (clip_type == ClipType.VIDEO) || (clip_type == ClipType.MASH))
				{
					__trimStartAV();
				}
				RunClass.MouseUtility['drag'](this, event, __trimTimed, __trimUp);
			}
			return do_press;
			
		}
		private function __trimStartAV():void
		{
			var clip:IClip = __trimInfo.clip;
			var clip_type:String = clip.getValue(CommonWords.TYPE).string;
			
			__trimInfo.orig_data.trimstartframe = clip.getValue('trimstartframe').number;
			__trimInfo.orig_data.trimendframe = clip.getValue('trimendframe').number;
			if (clip_type == ClipType.AUDIO)
			{
				__trimInfo.not_visual = true;
			}
		}
		private function __trimmash(dif_time : Number):Object
		{
			return __trimvideo(dif_time);
		}
		private function __trimvideo(dif_time : Number):Object
		{
			var ob:Object = new Object();
			try
			{
				if (__trimInfo.direction < 0)
				{
					ob.trimstartframe = new Value(__trimInfo.orig_data.trimstartframe + dif_time);
				}
				else
				{
					ob.trimendframe = new Value(__trimInfo.orig_data.trimendframe - dif_time);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__trimvideo', e);
			}
			return ob;
		}
		private function __trimaudio(dif_time : Number):Object
		{
			return __trimvideo(dif_time);
			
		}
		private function __trimeffect(dif_time : Number):Object
		{
			var data:Object = new Object();

			if (__trimInfo.direction < 0)
			{
				// decrease start while increasing length
				var data_start:Number = __trimInfo.orig_data.start + dif_time;
				data_start = (Math.max(__trimInfo.min_start, Math.min(__trimInfo.max_start, data_start)));
				data.length = new Value(__trimInfo.end_time - data_start);
				data.start = new Value(data_start);
			}
			else
			{
				// no need to validate, or worry about collision (clip takes care of this)
				data.length = new Value(__trimInfo.orig_data.length + dif_time);
				
			}
			return data;
		}
		private function __trimimage(dif_time : Number):Object
		{
			var data:Object = new Object();
			if (__trimInfo.direction < 0)
			{
				data.length = new Value(__trimInfo.orig_data.length - dif_time);
			}
			else data.length = new Value(__trimInfo.orig_data.length + dif_time);
			return data;
		}
		private function __trimTimed():void
		{
			var point:Point = new Point(RunClass.MouseUtility['x'], RunClass.MouseUtility['y']);
			point = globalToLocal(point);
			
			var mouse_x:Number = point.x;//__trimInfo.localX;
			var snap:Number = getValue('snap').number;
			var autoscroll:Number = (__zoom == 1) ? 0 : getValue('autoscroll').number;
			var iconwidth:Number = getValue('iconwidth').number;
			var x_mouse:Number = Math.min(_viewSize.width, Math.max(0, Math.round(mouse_x - iconwidth)));
			var scrolling:Number = 0;
			var iclip:IClip = __trimInfo.clip;
			
			var do_snap:Boolean;
			var clip_type:String = iclip.getValue(CommonWords.TYPE).string;
			try
			{
				
				__trimInfo.time = null;
				if (x_mouse < autoscroll)
				{
					scrolling = -1;
				}
				else if (x_mouse > (_viewSize.width - autoscroll))
				{
					scrolling = 1;
				}
				if (scrolling)
				{
					__trimInfo.clipX -= __doScroll(scrolling, true);
				}
				
				do_snap = (snap > 0);
				if (RunClass.MouseUtility['shiftIsDown'])
				{
					do_snap = ! do_snap;
				}
				if (do_snap && (clip_type != ClipType.TRANSITION) && (__trimInfo.not_visual || (__trimInfo.direction > 0)))
				{
					x_mouse = __snapMouse(x_mouse);
				}
				
				var dif:Number = x_mouse - __trimInfo.clipX;
				var dif_time:Number = pixels2Frame(dif);
				try
				{
					__trimInfo.data = this['__trim' + clip_type](dif_time);
				}
				catch(e:*)
				{
					RunClass.MovieMasher['msg'](this + '.__trimMove data', e);
				}
				try
				{
					if (__action == null)
					{
						__action = new ClipValuesAction(iclip, __trimInfo.data);
					}
					else
					{
						__action.values = __trimInfo.data;
					}
				}
				catch(e:*)
				{
					RunClass.MovieMasher['msg'](this + '.__trimMove values', e);
				}
				if (scrolling)
				{
					
					_drawClips();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__trimMove', e);
			}
			
		}
		private function __trimUp()
		{
			try
			{
				__action = null;
				__trimInfo = null;
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__trimUp', e);
			}

		}
		private function __viewableClips():Array
		{
			var first : Number = 0;
			var last : Number = 0;
			var viewable_clips:Array = [];
			if (_mash != null)
			{
				
				first = pixels2Frame(_scroll.x);
				last = pixels2Frame(_scroll.x + _viewSize.width);

				var highs:Object = new Object();
				highs.effect = 0;
				highs.audio = 0;
				highs.video = 0;
				var lows:Object = new Object();
				lows.effect = 0;
				lows.audio = 0;
				lows.video = 0;
				
				var invisible_space:Number = _scroll.y;

				var visible_space:Number = _height;
				var type : String;
				var typeheight : Number;
				var displayed : Boolean;
				var i : Number;
				var inc : Number;

				var types : Array = [ClipType.EFFECT, ClipType.VIDEO, ClipType.AUDIO];
				for (var j:int = 0; j < 3; j++)
				{
					displayed = false;
					type = types[j];
					typeheight = typeHeight(type);
					if ((type == types[1]) && RunClass.Media['multitrackVideo'] && (! getValue('novisualaudio').boolean))
					{
						typeheight += typeHeight(ClipType.AUDIO);
					}
					i = ((type == types[0]) ? __tracks[type] - 1 : 0);
					inc = ((type == types[0]) ? -1 : 1);
					
					for (; ((i > -1) && (i < __tracks[type])); i += inc)
					{
						if (invisible_space > 0)
						{
							invisible_space -= typeheight;
							if (invisible_space <= 0)
							{
								visible_space += typeheight + invisible_space;
							}
						}
						if (invisible_space <= 0)
						{
							if (visible_space >= 0)
							{
								visible_space -= typeheight;
								if (i < _mash.getValue(type).number)
								{
									displayed = true;
									highs[type] = Math.max(highs[type], i + 1);
									lows[type] = Math.min((lows[type] ? lows[type] : i + 1), i + 1);
								}
							}
						}
					}
					if (displayed)
					{
						viewable_clips = viewable_clips.concat(_mash.clipsInTracks(first, first + last, type, (type == ClipType.VIDEO), lows[type], highs[type] - lows[type]));
					}
				}
			//	RunClass.MovieMasher['msg'](this + '.__viewableClips ' + viewable_clips);
			}
			return viewable_clips;
		}
		private function __vScrollReset():Boolean
		{
			var did_draw:Boolean = false;
			if (_mash)
			{
				did_draw = _setScrollDimension('height', __contentHeight + getValue('vscrollpadding').number);
			}
			return did_draw;
		}
		private static var __rollCursors:Array = ['trimleft', 'hover', 'trimright'];
		private static var __trackKeys : Array = ['clip', ClipType.EFFECT, ClipType.VIDEO, ClipType.AUDIO];
		private var __action:ClipValuesAction;
		private var __clipboard : Array = new Array();
		private var __contentHeight : Number = 0;
		private var __dragOffset:Point;
		private var __drawClipsTimer:Timer;
		private var __enabledControls : Object;
		private var __enabledProperties : Object;
		private var __icons_mask_mc : Sprite;// matte
		private var __icons_mc : Sprite;// holds track icons
		private var __previewWidth : Number = 0;
		private var __tracks : Object;
		private var __trimInfo : Object;
		private var __trimtheme : Function = __trimimage;
		private var __trimtransition : Function = __trimimage;
		private var _heights : Object;
		private var __fps:int = 0;
		private var __zoom:Number;
	}
}

