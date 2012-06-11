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

package com.moviemasher.core
{
	import com.moviemasher.control.*;
	import com.moviemasher.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.stage.PlayerStage;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.system.*;
	import flash.utils.*;
/**
* Class represents a collection of clips (edit decision list).
*
* @see IClip
* @see IMash
*/
	public class Mash extends Propertied implements IMash
	{
		public static function fromURL(source: String):IMash
		{
			var x:XML = <mash />;
			x.@source = source;
			return fromXML(x);
		}
		public static function fromXML(node: XML):IMash
		{
			var mash : IMash = null;
			try 
			{
				mash = new Mash();
				mash.tag = node;
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](Mash, e);
			}
			return mash;
		}
		public function Mash()
		{
			_defaults.effects = '';
			_defaults.kind = 'Mash';
			_defaults.fullscreen = '0';
			_defaults.label = '';
			_defaults.quantize = '0';
			
			__initClips();
			
			__lengths = new Object();
			__lengths.audio = 0;
			__lengths.effect = 0;
			__lengths.video = 0;
			
			__highest = new Object();
			__highest.audio = 0;
			__highest.effect = 0;
			__highest.video = 0;
			
			__tracks = new Object();
			__tracks.audio = new Array();
			__tracks.effect = new Array();
			__tracks.video = new Array();
			
		}
		public function buffer(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):void
		{
			var range:Object = __limitRange(first, last);
				
			__mute = mute;
		
		
			var clip:IClip;
			var clips:Dictionary;
			var clip_buffered:Object;
			
			
			var was_buffering:Dictionary = __bufferingClips;
			var clip_range:Object;

			__bufferingClips = new Dictionary();
			clips = __clipRanges(range.start, range.end);
			for (var ob:* in clips)
			{
				clip = ob;
				
				if (__mute && clip.getValue(CommonWords.TYPE).equals(ClipType.AUDIO))
				{
					continue;
				}
				__activeClips[clip] = clip;
				
				clip_range = clips[ob];
				
				clip_buffered = null;
				var is_rebuffer:Boolean = rebuffer && (__playingClips[clip] != null);
				
				if (! clip.buffered(clip_range.start, clip_range.end, __mute, is_rebuffer))
				{
					if (was_buffering[clip] == null)
					{
						clip.addEventListener(EventType.BUFFER, __clipBuffer);
						clip.addEventListener(EventType.STALL, __clipStall);
					}	
			
					clip.buffer(clip_range.start, clip_range.end, __mute, is_rebuffer);
					if (! clip.buffered(clip_range.start, clip_range.end, __mute, is_rebuffer))
					{
						
						clip_buffered = range;
					}
					
				}
				
				
						
				__bufferingClips[clip] = clip_buffered;
			
			
			}
		}
		public function buffered(first:Number, last:Number, mute:Boolean, rebuffer:Boolean):Boolean
		{
			var is_buffered:Boolean = true;
			try
			{
				var range:Object = __limitRange(first, last);
				
				var clip:IClip;
				var clip_range:Object;
				
				var clips:Dictionary = __clipRanges(range.start, range.end);
				for (var ob:* in clips)
				{
					clip = ob;
					if (mute && clip.getValue(CommonWords.TYPE).equals(ClipType.AUDIO))
					{
						continue;
					}
					clip_range = clips[ob];
					is_buffered = clip.buffered(clip_range.start, clip_range.end, mute, rebuffer);
					
					if (! is_buffered) break;
				}
				//if (! is_buffered) RunClass.MovieMasher['msg'](this + '.buffered ' + first + '->' + last + ' ' + rebuffer + ' waiting for ' + clip);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.buffered', e);
			}			
			return is_buffered;
		}
		public function clipsInRange(first:Number, last:Number):Array
		{
			var clips:Array = new Array();
			
			var track:Array;
			var y:uint;
			var j:uint;
			var clip:IClip;
			var z:uint = __trackTypes.length;
			var effects:Array;
			var type:String;
			for (var i:uint = 0; i < z; i++)
			{
				type = __trackTypes[i];
				track = __tracks[type];
				y = track.length;
				for (j = 0; j < y; j++)
				{
					clip = track[j];
					
					if (clip == null) continue;
					
					if (__clipInRange(clip, first, last, (i == 2)))
					{
						clips.push(clip);
						// add embedded effects for non audio clips
						if (i) 
						{
							var effects_vector:Array = clip.getValue(ClipProperty.EFFECTS).array;
							
							clips = clips.concat(effects_vector);
						}
					}
				}
			}
			return clips;
		}
		public function clipsInTracks(first:Number, last:Number, type:String, transitions:Boolean = false, track:int = 0, count:int = 0):Array
		{
			var last_track:int = track + count;
			var atTime:Number = first;
			var for_duration:Number = last - first;
			
			var time_clips:Array = new Array();

			var clip:IClip;
			var end_time:Number = last;
			var av_clips:Array = __tracks[type];
			var clip_start:Number;
			var clip_end:Number;
			var z:int = av_clips.length;
			var clip_track:int;
			var clip_length:Number;
			for (var i:int = 0; i < z; i++)
			{
				clip = av_clips[i];
				clip_start = clip.startFrame;
				clip_start -= clip.startPadFrame;
				if (transitions)
				{
					clip_start += clip.getValue(ClipProperty.TIMELINESTARTFRAME).number;
				}
				if (clip_start > end_time)
				{
					break;
				}
				clip_length = clip.lengthFrame;
				clip_end = clip_start + clip_length + clip.startPadFrame;
				if (transitions)
				{
					clip_end -= clip.getValue(ClipProperty.TIMELINEENDFRAME).number;
				}

				if (clip_end > atTime)
				{
					if (type != ClipType.VIDEO)
					{
						// see if track is valid
						clip_track = clip.getValue(ClipProperty.TRACK).number;
						if ((track && (clip_track < track)) || (last_track && (clip_track > last_track)))
						{
							continue;
						}
					}
					time_clips.push(clip);
				}
			}
			if (track) time_clips.sort(sortByTrack);
			return time_clips;
		}
		public function clipsInOuterTracks(first:Number, last:Number, ignore:Array = null, track:int = 0, count:int = 0, type:String = ''):Array
		{
			var atTime:Number = first;
			var for_duration:Number = last - first;
			var z:int;
			var ignore_ids:Dictionary = new Dictionary();
			var i:int;
			if (ignore != null)
			{
				z = ignore.length;
				for (i = 0; i < z; i++)
				{
					ignore_ids[ignore[i]] = true;
				}
			}
			var items:Array = new Array();
			var clip:IClip;
			var end_time:Number = atTime + for_duration;
			z = __tracks[type].length;
			var start_range:int = ((type == ClipType.EFFECT) ? (track - count) + 1 : (track));
			var end_range:int = ((type == ClipType.EFFECT) ? track : (track + count - 1));
			var clip_start:Number;
			var clip_track:int;
			for (i = 0; i < z; i++)
			{
				clip = __tracks[type][i];
				if (ignore_ids[clip] != null)
				{
					continue;
				}
				clip_track = clip.getValue(ClipProperty.TRACK).number;
				if ((clip_track < start_range) || (clip_track > end_range))
				{
					continue;
				}
				clip_start = clip.startFrame;
				if (clip_start >= end_time)
				{
					break;
				}
				if ((clip_start + (clip.lengthFrame ? clip.lengthFrame : 1)) > atTime)
				{
					items.push(clip);
				}
			}
			return items;
		}
		public function editableProperties():Array
		{
			var a:Array = new Array();
			for (var property:String in _defaults)
			{
				a.push(property);
			}
			return a;
		}
		public function freeTime(first:Number, last:Number, type:String = '', ignore:Array = null, track:int = 0, count:int = 0):Number
		{
			var atTime:Number = first;
			var for_duration:Number = last - first;
			
			if (atTime < 0)
			{
				return atTime;
			}
			var fTracks:Array = clipsInOuterTracks(atTime, atTime + for_duration, ignore, track, count, type);
			var z:int = fTracks.length;

			var clip:IClip;
			var clip_start:Number;
			var best_time:Number = -1;
			var n:Number;
			if (z)
			{
				for (var i:int = 0; i < z; i++)
				{
					clip = fTracks[i];
					clip_start = clip.startFrame;
					n = clip_start + clip.lengthFrame;

					if (clip_start < atTime)
					{
						// try to put it to the right
						fTracks = clipsInOuterTracks(n, n + for_duration, ignore, track, count, type);
						if (! fTracks.length)
						{
							best_time = n;
						}
						break;
					}
					if (n > (atTime + for_duration))
					{
						n = clip_start - for_duration;
						if (n >= 0)
						{
							fTracks = clipsInOuterTracks(n, n + for_duration, ignore, track, count, type);
							if (! fTracks.length)
							{
								best_time = n;
							}
						}
						break;
					}
				}
			}
			else
			{
				best_time = atTime;
			}
			return best_time;
		}
		public function freeTrack(first:Number, last:Number, type:String, count:uint):uint
		{
			var a_clips:Array = clipsInTracks(first, last, type);
			a_clips.sort(sortByTrack);
			var z:uint = a_clips.length;
			var defined_tracks:Object = new Object();
			for (var i:uint = 0; i < z; i++)
			{
				defined_tracks['t' + a_clips[i].track] = true;
			}
			var track:uint = 0;
			var track_ok:Boolean = false;
			while (! track_ok)
			{
				track_ok = true;
				track ++;
				z = track + count;
				for (i = track; i < z; i++)
				{
					if (defined_tracks['t' + i])
					{
						track_ok = false;
						break;
					}
				}
			}
			return track;
		}
		public function getFrame():Number
		{
			return __frame;
		}
		override public function getValue(property:String):Value
		{
			var value:Value;
			switch (property)
			{
				
				case 'clip':
				case ModuleProperty.FONT:
				case ClipProperty.MEDIA:
					// so _tag[property] isn't returned
					value = new Value();
					break;
				case ClipProperty.VOLUME:
					value = new Value(__volume);
					break;
				case MashProperty.STALLING:
					value = new Value(__stalling ? 1 : 0);
					break;
				case ClipProperty.MASH: // needed to support selection of mash in timeline
					value = new Value(this);
					break;
				case ClipProperty.EFFECTS:
					var effects:Array = clipsInOuterTracks(0, 1, null, -1, int.MIN_VALUE, ClipType.EFFECT);
					if (effects.length) effects.sort(sortByTrack);
					value = new Value(effects);
					break;
				case ClipProperty.XML:
					value = new Value(__xml());
					break;
				case PlayerProperty.DIRTY:
					value = new Value(__needsSave ? 1 : 0);
					break;
				case PlayerProperty.PLAY:
					value = new Value(__paused ? 0 : 1);
					break;
				case MediaProperty.DURATION:
					value = new Value(RunClass.TimeUtility['timeFromFrame'](__lengthFrame, getValue(MashProperty.QUANTIZE).number));
					break;
				case ClipProperty.LENGTHFRAME:
				case ClipProperty.LENGTH:
					value = new Value(__lengthFrame);
					break;
				case 'ratio':
					var dims:Size = dimensions;
					value = new Value(dims.width / dims.height);
					break;
				case 'displaysize':
					value = new Value(__bitmapSize);
					break;
					
				case ClipType.VIDEO:
				case ClipType.AUDIO:
				case ClipType.EFFECT:
					value = new Value(__highest[property]);
					break;
				default:
					value = super.getValue(property);
			}
			return value;
		}
		public function gotoFrame(n:Number):Boolean
		{
			if (isNaN(__lengthFrame)) return false; // makes sure we've had a chance to parse our tag
			__clipsChanged = true;
			var went_to:Boolean = false;
			try
			{
				if (n == -1) n = __displayFrame;
				n = Math.max(0, Math.min(__lengthFrame - 1, n));
				var was_moving:Boolean = __moving;
				if (__moving)
				{
					//RunClass.MovieMasher['msg'](this + '.gotoFrame __setMoving false');
				
					__setMoving(false);
				}
				went_to = buffered(n, n, __paused, false);
				if (! went_to)
				{
					buffer(n, n, __paused, false);
					went_to = buffered(n, n, __paused, false);
				}
				if (went_to)
				{
					__goingFrame = -1;
					setFrame(n);
					if (was_moving) 
					{
						//RunClass.MovieMasher['msg'](this + '.gotoFrame __setMoving true');
						__setMoving(true);
					}
					else
					{
						__unbuffer(n, n);
					}
				}
				else
				{
					__goingFrame = n;
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.gotoFrame', e);
			}
			return went_to;
		}
		public function invalidateLength(type:String, dont_dirty:Boolean = false):void
		{
			try
			{
				switch (type)
				{
					case ClipType.AUDIO:
					case ClipType.EFFECT:
						__recalculateTrackLength(type);
						break;
					default:
						type = ClipType.VIDEO;
						__recalculateVideoLength();
				}
				__playingClipsRecalculate();
				__dispatchEvent(ClipProperty.TRACK);
				if (! dont_dirty)
				{
					setValue(new Value('1'), PlayerProperty.DIRTY);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}			

		}
		public function invalidateLengths():void
		{
			invalidateLength(ClipType.VIDEO, true);
			invalidateLength(ClipType.AUDIO, true);
			invalidateLength(ClipType.EFFECT, true);
		}
		public function isVisual():Boolean
		{
			return Boolean(__highest.video);
		}
		public function propertyDefined(property:String):Boolean
		{
			return (_defaults[property] != null);
		}
		public function referencedMedia():Object
		{
			
			var dictionary:Object = new Object();
			var y:uint;
			var j:uint;
			var z:uint = __trackTypes.length;
			var type:String;
			for (var i:uint = 0; i < z; i++)
			{
				type = __trackTypes[i];
				y = __tracks[type].length;
				for (j = 0; j < y; j++)
				{
					__tracks[type][j].referencedMedia(dictionary);
				}
			}
			return dictionary;
		}
		public function setFrame(clip_frame:Number):Boolean
		{
			if (isNaN(clip_frame)) return false;
			
			try
			{
				if (__moving) 
				{
					//RunClass.MovieMasher['msg'](this + '.setFrame __setMoving false');
					__setMoving(false);
				}
				if (! __displayBufferedFrame(clip_frame))
				{
					
				}
				__movingFrameReset();
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.setFrame', e);
			}
			return true;
		}
		override public function setValue(value:Value, property:String):Boolean
		{
			try
			{
				var do_super:Boolean = false;
				var changed_timing:Boolean = false;
				switch (property)
				{
					case MashProperty.QUANTIZE:
						__setQuantize(value.number);
						break;
					case ClipProperty.EFFECTS:
						__changeEffects(value.array);
						__setDirty(true);
						break;
						
						
					case PlayerProperty.UNBUFFERTIME:
					case PlayerProperty.MINBUFFERTIME:
					case PlayerProperty.BUFFERTIME:
						this['__'  + property.toLowerCase()] = RunClass.TimeUtility['frameFromTime'](value.number, getValue(MashProperty.QUANTIZE).number);
						changed_timing = true;
						break;	
					case PlayerProperty.DIRTY: 
						__setDirty(value.boolean);
						break;
					case 'fullscreen':
						__fullScreen = value.boolean;
						PlayerStage.instance.addEventListener(FullScreenEvent.FULL_SCREEN, __moviemasherFullscreen);
						if (value.boolean) 
						{
							PlayerStage.instance.fullScreen(this);
							paused = false;
						}
						else PlayerStage.instance.fullScreenExit();
						break;
					case ClipProperty.VOLUME:
						__volume = value.number;
						__mute = ! value.boolean;
						break;
					case PlayerProperty.PLAY:
						if (value.boolean)
						{
							__mute = ! __volume;
						}
						paused = ! value.boolean;
						do_super = true;
						break;
					default:
						if (__originalKeys.indexOf(property) != -1)
						{
							__setDirty(true);
						}
						do_super = true;
				}
				if (do_super)
				{
					super.setValue(value, property);
					if (changed_timing &&  (! __paused)) __setMoving(false);
					dispatchEvent(new ChangeEvent(value, property));
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.setValue ' + property, e);
			}
			return false;
		}
		public function sortByTimeTrack(a:IClip, b:IClip):Number
		{
			var a_start:Number = a.startFrame;
			var b_start:Number = b.startFrame;
			if (a_start < b_start)
			{
				return -1;
			}
			if (a_start > b_start)
			{
				return 1;
			}
			return sortByTrack(a,b);

		}
		public function sortByTimeTrans(a:IClip, b:IClip):Number
		{
			var a_start:Number = a.startFrame;
			var b_start:Number = b.startFrame;
			if (a_start < b_start)
			{
				return -1;
			}
			if (a_start > b_start)
			{
				return 1;
			}
			return sortByTrans(a,b);

		}
		public function sortByTrack(a:IClip, b:IClip):Number
		{
			var a_track:Number = a.getValue(ClipProperty.TRACK).number;
			var b_track:Number = b.getValue(ClipProperty.TRACK).number;
			if (a_track < 0) a_track += int.MAX_VALUE;
			if (b_track < 0) b_track += int.MAX_VALUE;
			
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
		public function sortByTrans(a:IClip, b:IClip):Number
		{
			if (a.getValue(CommonWords.TYPE).equals(ClipType.TRANSITION))
			{
				return -1;
			}
			if (b.getValue(CommonWords.TYPE).equals(ClipType.TRANSITION))
			{
				return 1;
			}
			return 0;
		}
		public function timeLeft():Number
		{
			var time_left:Number;
			if (__moving)
			{
				time_left = Math.max(0, (1 / RunClass.TimeUtility['fps']) - (((new Date()).getTime()) - __movingTimeSampled));
			}
			else
			{
				time_left = Infinity;
			}
			return time_left;
		}
		override public function toString():String
		{
			var s:String = '[Mash';
			var value:Value = getValue(MediaProperty.LABEL);
			if (value.empty)
			{
				value = getValue(CommonWords.ID);
			}	
			if (! value.empty)
			{
				s += ' ' + value.string;
			}
			s += ']';
			return s;
		}
		public function unbuffer(first:Number = -1, last:Number = -1):void
		{
			var range:Object = __limitRange(first, last);
			__unbuffer(range.start, range.end);
		}
		public function unload():void
		{
			playing = false;
			
			if (__canvas_mc != null)
			{
				__clearContainers();
				__canvas_mc.removeChild(__backcolor_mc);
				__backcolor_mc = null;
				__canvas_mc = null;
			}
			
			__initClips();
			
		}
		public function set animating(tf:Boolean):void
		{
			// called by Preview, as part of IModule
		}
		public function set clip(iClip:IClip):void
		{
			// for IModule interface
		}
		public function get dimensions():Size
		{
			var s:Size = new Size();
			s.width = getValue(MediaProperty.WIDTH).number;
			s.height = getValue(MediaProperty.HEIGHT).number;
			if (! (s.width && s.height))
			{
				s.width = RunClass.MovieMasher['getOptionNumber'](ClipProperty.MASH, MediaProperty.WIDTH);
				s.height = RunClass.MovieMasher['getOptionNumber'](ClipProperty.MASH, MediaProperty.HEIGHT);
			
				
				if (! (s.width && s.height))
				{
					var player:IPropertied = RunClass.MovieMasher['getByID'](ReservedID.PLAYER) as IPropertied;
					if (player != null)
					{
						s.width = player.getValue('displaywidth').number;
						s.height = player.getValue('displayheight').number;
						
					}
				}
				if (s.width && s.height)
				{
					setValue(new Value(s.width), MediaProperty.WIDTH);
					setValue(new Value(s.height), MediaProperty.HEIGHT);
				}
			}
			return s;
		}
		public function get displayObject():DisplayObjectContainer
		{
			if (__canvas_mc == null)
			{
				try
				{
					// first time this mash is being displayed
					
					__canvas_mc = new Sprite();
					//__canvas_mc.name = 'Canvas';
					__backcolor_mc = new Sprite();
					//__backcolor_mc.name = 'Backcolor';
					
					__canvas_mc.addChild(__backcolor_mc);
					__positionCanvas();
					
				}
				catch(e:*)
				{
					RunClass.MovieMasher['msg'](this, e);
				}
			}
			
			//if (__canvas_mc.numChildren > 1) RunClass.MovieMasher['msg'](this + '.displayObject ' + __canvas_mc + ' ' + (__canvas_mc.getChildAt(0) as DisplayObjectContainer).numChildren + ' ' + (__canvas_mc.getChildAt(1) as DisplayObjectContainer).numChildren);
			return __canvas_mc;
		}
		public function get keepsTime():Boolean
		{
			return true;
		}
		public function get lengthFrame():Number
		{ 
			return __lengthFrame; 
		}
		public function get metrics():Size
		{
			return __metrics;
		}
		public function set metrics(iMetrics:Size):void
		{
			__metrics = iMetrics;
			var dims:Size = dimensions;
				
			if (! (dims.width && dims.height))
			{
				dims.width = iMetrics.width;
				dims.height = iMetrics.height;
			}
			var per:Number = Math[getValue(MashProperty.CROP).boolean ? 'max' : 'min'](iMetrics.width / dims.width, iMetrics.height / dims.height);
			__bitmapSize = new Size(Math.ceil((per * dims.width) /2) * 2, Math.ceil((per * dims.height)/2) * 2);
			
			if (__canvas_mc != null)
			{
				__positionCanvas();
			}
		}
		public function set paused(tf:Boolean):void
		{
			if (__paused != tf)
			{
				__paused = tf;
				if (! __paused)
				{
					__mute = ! __volume;
				}
				var d:Date = new Date();
				if (__paused) 
				{
					PlayerStage.instance.stopPlaying();
					__setMoving(false);
					
					__bufferTimer.removeEventListener(TimerEvent.TIMER, __bufferTimed);
					__bufferTimer.stop();
					__bufferTimer = null;
					
					
				}
				else 
				{
					if ((__displayFrame + 1) >= __lengthFrame)
					{
						gotoFrame(0);
					}
					
					PlayerStage.instance.startPlaying(this);
					__bufferTimer = new Timer(1000);
					__bufferTimer.addEventListener(TimerEvent.TIMER, __bufferTimed);
					__bufferTimer.start();
					__bufferTimed(null);
					
				}
				
				if (! __fullScreen) 
				{
					dispatchEvent(new ChangeEvent(getValue(PlayerProperty.PLAY), PlayerProperty.PLAY));
				}
				
				__setStalling((! __moving) && (! __paused));

			}
		}
		public function set playing(iBoolean:Boolean):void
		{
			
			__setMoving(iBoolean);
		}
		public function set preview(iBoolean:Boolean):void
		{
			setValue(new Value(! iBoolean), 'ignorepreviews');
		}
		public function set runningAsPreview(options:IPreview):void
		{
			// called by Preview, as part of IModule
		}
		public function get tracks():Object
		{
			return __tracks;
		}
		public function set volume(iNumber:Number):void
		{
			__volume = iNumber;
		}
		override protected function _parseTag():void
		{
			var source:String = getValue(MashProperty.SOURCE).string;
			if (source.length)
			{
			
				if ((source.indexOf('/') + source.indexOf('.')) == -2) // it's not a URI
				{
					var listener:IPropertied = RunClass.MovieMasher['getByID'](source) as IPropertied;
					
					if (listener != null)
					{
						source = '';
					}
				}
				if (source.length)
				{
					__dataFetcher = RunClass.MovieMasher['dataFetcher'](source);
					__dataFetcher.addEventListener(Event.COMPLETE, __completeFetch);
				}
			}
			else
			{
				__parseTag();
			}
		}
		private function __adjustEffectsLength():void
		{
			var mash_effects:Array = clipsInOuterTracks(0, 1, null, -1, int.MIN_VALUE, ClipType.EFFECT);
			var z:uint = mash_effects.length;
			var effect_clip:IClip;
			var value:Value = new Value(__lengthFrame);
			for (var i:uint = 0; i < z; i++)
			{
				effect_clip = mash_effects[i];
				effect_clip.setValue(value, ClipProperty.LENGTHFRAME);
			}
		}
		private function __applyBackground(container:DisplayObjectContainer, contained:DisplayObjectContainer, back_color:String):Boolean
		{
			var did_draw:Boolean = false;
			if ((__canvas_mc != null) && (__bitmapSize != null))
			{
				try
				{
					var color:Number = RunClass.DrawUtility['colorFromHex'](back_color);
					if (__clipsChanged && (container != null) && (! __canvas_mc.contains(container) ) )
					{
						__canvas_mc.addChild(container);
					}
					__backcolor_mc.graphics.clear();
					RunClass.DrawUtility['fillBox'](__backcolor_mc.graphics, -__bitmapSize.width/2, -__bitmapSize.height/2, __bitmapSize.width, __bitmapSize.height, color);
					
					if (contained != null)
					{
						did_draw = true;
						__backcolor_mc.transform.colorTransform = contained.transform.concatenatedColorTransform;
						var concat_filters:Array = new Array();
						var ob:DisplayObjectContainer = contained.parent;
						while ((ob != null) && (ob != __canvas_mc))
						{
							concat_filters = concat_filters.concat(ob.filters);
							ob = ob.parent;
						}
						__backcolor_mc.filters = concat_filters;
					}
				}
				catch(e:*)
				{
					RunClass.MovieMasher['msg'](this, e);
				}
			}
			return did_draw;
		}
		private function __applyClip(clip:IClip):Boolean
		{
			var did_draw:Boolean = true;
			var back_color = '';
			var container:DisplayObjectContainer = null;
			var contained:DisplayObjectContainer = null;
			try
			{
				
				if (clip == null)
				{
					// there are no clips to display
						
					if (__clipsChanged)
					{
						container = new Sprite();
						//container.name = 'NoClips';
						__containers.push(container);
					}
				}
				else 
				{
					container = __applyModule(clip);
					if (clip.module != null)
					{
						back_color = clip.module.getValue(ModuleProperty.BACKCOLOR).string;
					}
					else
					{
						did_draw = false;
					}
				}
			
				if (did_draw)
				{
					contained = container;
					
					var effects:Array = __playingEffectClips();
					if (effects.length)
					{
						
						container = __applyEffects(effects, container);
					}
				
				}
			
				if (! back_color.length) 
				{
					back_color = getValue(MashProperty.BGCOLOR).string;
				}
				if (did_draw)
				{
					__applyBackground(container, contained, back_color);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return did_draw;
		}
		private function __applyClips(v_clips:Array):Boolean
		{
			var did_draw: Boolean = false;
			try
			{
				var transition_clip:IClip = v_clips[1];
				var transition_module:IModule = transition_clip.module;
				var changed:Boolean = true;
				
				if (transition_module != null)
				{
					// one or the other of these could be null
					var from_clip:IClip = v_clips[0]; 
					var to_clip:IClip = v_clips[2];
					
					var container:DisplayObjectContainer = null; 
					var contained:DisplayObjectContainer = null;
					
					var back_color:String = '';
					var test_color:String = '';
					var color_target:DisplayObjectContainer = null;
					
					if (to_clip != null)
					{
						contained = __applyModule(to_clip);
						if (contained != null)
						{
							
							contained.name = 'to_sprite';
							if (! (transition_module.displayObject.contains(contained)))
							{
								transition_module.displayObject.addChildAt(contained, 0);
							}
							else transition_module.displayObject.setChildIndex(contained, 0);
							test_color = to_clip.module.getValue(ModuleProperty.BACKCOLOR).string;
							if (test_color.length)
							{
								back_color = test_color;
								color_target = contained;
							}
						}
					}
					if (from_clip != null)
					{
						contained = __applyModule(from_clip);
						if (contained != null)
						{
							contained.name = 'from_sprite';
							if (! (transition_module.displayObject.contains( contained)))
							{
								transition_module.displayObject.addChildAt(contained, 0);
							}
							else transition_module.displayObject.setChildIndex(contained, 0);
							if (! back_color.length)
							{
								test_color = from_clip.module.getValue(ModuleProperty.BACKCOLOR).string;
								if (test_color.length)
								{
									back_color = test_color;
									color_target = contained;
								}
							}
						}
					}
					container = __applyModule(transition_clip);
					if (container != null)
					{
						
						var effects:Array = __playingEffectClips();
						if (effects.length)
						{
							container = __applyEffects(effects, container);
						}
						if (! back_color.length) 
						{
							back_color = getValue(MashProperty.BGCOLOR).string;
							color_target = contained;
						}
						did_draw = __applyBackground(container, color_target, back_color);

					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return did_draw;
		}
		private function __applyEffects(effects:Array, contained:DisplayObjectContainer, clip:IClip = null):DisplayObjectContainer
		{
			var container:DisplayObjectContainer;
			try
			{
				var effects_count:uint = effects.length;
				if (effects_count)
				{
					var effect_clip:IClip;
					var module:IModule;
					var i:uint;
					var changed:Boolean = true;
					effects.sort(sortByTrack);
					for (i = 0; i < effects_count; i++)
					{
						effect_clip = effects[i];
						if (__appliedEffects[effect_clip] == null)
						{
							__appliedEffects[effect_clip] = true;
							module = effect_clip.module;
							if (module != null)
							{
								if (__clipsChanged)
								{
									container = __createContainer();//'Effect' + i);
									
									container.addChildAt(module.displayObject, 0);
									if (contained != null)
									{
										module.displayObject.addChildAt(contained, 0);
									}
								}
								else 
								{
									container = module.displayObject.parent;
								}
								try
								{
									effect_clip.metrics = __bitmapSize;
									changed = effect_clip.setFrame(__displayFrame - ((clip == null) ? 0 : clip.startFrame));
									var effects_effects:Array = effect_clip.getValue(ClipProperty.EFFECTS).array;
									if (effects_effects.length)
									{
										container = __applyEffects(effects_effects, container);
									}



								}
								catch(e:*)
								{
									RunClass.MovieMasher['msg'](this, e);
								}
								contained = container;
							}
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return contained;
		}
		private function __applyModule(clip:IClip):DisplayObjectContainer
		{
			var module:IModule;
			var clip_time:Number;
			var clip_start:Number;
			var changed:Boolean;
			var container:DisplayObjectContainer;
			try
			{
				module = clip.module;
				if (module != null)
				{
					clip_time = __displayFrame;
					clip.metrics = __bitmapSize;
					changed = clip.setFrame(clip_time);
					
					if (__clipsChanged || (module.displayObject.parent == null))
					{
						container = __createContainer();
						container.addChildAt(module.displayObject, 0);
					}
					else
					{
						container = module.displayObject.parent;
						
					}
					// apply effects attached to clip 
					var effects:Array = clip.getValue(ClipProperty.EFFECTS).array;
					if (effects.length)
					{
						container = __applyEffects(effects, container, clip);
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			
			return container;
			
		}
		private function __bufferTimed(event:TimerEvent):void
		{
			// only called while playing 
			
			try
			{
				var first1:Number = Math.max(0, ((__goingFrame == -1) ? __displayFrame : __goingFrame));
				var last1:Number = first1 + __buffertime;
				var first2:Number = -1;
				var last2:Number = -1;
				var clip_is_buffered:Boolean;
				var offset:Number = Math.max(0, last1 - (__lengthFrame - 1));
				
				// see if we need to buffer begining again (audio looping)
				if ((! __paused) && offset && (! getValue(PlayerProperty.AUTOSTOP).boolean))
				{
					first2 = 0;
					last2 = offset;
					last1 -= offset;
				}
				
				var am_ready:Boolean;
				
				// unbuffer everything outside of buffering area(s)
				__unbuffer(first1 - __unbuffertime, last1, ((first2 == -1) ? first2 : Math.min(0, first2 - __unbuffertime)), last2);
				
				// see if first range is buffered
				clip_is_buffered = buffered(first1, last1, __mute, false);
				
				am_ready = clip_is_buffered;// || ((__goingFrame == -1) && (first1 == last1));
				
				if (am_ready)
				{
					if (first2 == 0)
					{
						// see if second range is buffered
						
						am_ready = buffered(first2, last2, __mute, true);
						if (! am_ready)
						{
							// second range is not all buffered so do so
							buffer(first2, last2, __mute, true);
						}
					}
				}
				else
				{
					// first range is not all buffered, so do so
					buffer(first1, last1, __mute, false);
				}
				
				
				if (! am_ready)
				{
					// if playing, make sure at least the minimum in first range is buffered
					if (__moving)
					{
						last1 = first1 + __minbuffertime;
						am_ready = buffered(first1, last1, __mute, false);
					}
				}
					
				if (__moving != am_ready)
				{
					if (__moving || (! getValue('dontbufferstart').boolean))
					{
						var gf:Number = -1;
						if (! __moving) 
						{
							gf = __goingFrame;
							__clipBuffer(null); // if __goingFrame != -1 this goes to it, which will call __setMoving
						}
						if (gf == -1) __setMoving(am_ready);
					}
				}
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __changeEffects(new_effects:Array):void
		{
			try
			{
			
				var effects:Array = clipsInOuterTracks(0, 1, null, -1, int.MIN_VALUE, ClipType.EFFECT);
				var z:uint = effects.length;
				var i:uint;
				var effect_clip:IClip;
				var value:Value = new Value(__lengthFrame);
				var new_effects_length:uint = new_effects.length;
				var pos:uint;
				for (i = 0; i < z; i++)
				{
					effect_clip = effects[i];
					if ((! new_effects_length) || (new_effects.indexOf(effect_clip) == -1))
					{
						pos = tracks.effect.indexOf(effect_clip);
						tracks.effect.splice(pos, 1);
						effect_clip.unload();
					}
				}
				for (i = 0; i < new_effects_length; i++)
				{
					effect_clip = new_effects[i];
					effect_clip.setValue(new Value(i - new_effects_length), ClipProperty.TRACK);
					effect_clip.setValue(new Value(this), ClipType.MASH);
					if ((! z) || (effects.indexOf(effect_clip) == -1))
					{
						
						tracks.effect.unshift(effect_clip);
						effect_clip.setValue(value, ClipProperty.LENGTHFRAME);
					}
				}
			}	
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__changeEffects', e);
			}	
		}
		private function __clipAudioFrame():Number
		{
			var video_time:Number = -1;
			var audio_clips:Array = __playingAudioClips();
			audio_clips.sort(sortByTimeTrack);
			var z:uint = audio_clips.length;
			var had:Number = 0;
			var time:Number = 0;
			if (z)
			{
				var clip:IClip;
				var test_time:Number = -1;
				for (var i:uint = 0; i < z; i++)
				{
					clip = audio_clips[i];
					test_time = clip.getFrame();
					if (test_time != -1)
					{
						//RunClass.MovieMasher['msg'](this + '.__clipAudioFrame ' + test_time);
						had++;
						time += test_time;
						if (clip.type == ClipType.VIDEO) //|| (clip.type == ClipType.AUDIO))
						{
							video_time = test_time;
						}
					}
				}
				if (had)
				{
					if (video_time == -1)
					{
						video_time = Math.ceil(time / had);
					}
				}
			}
			if (__moving)
			{
				if (video_time == -1)
				{
					video_time = __movingFrame();
				}
				else
				{
					__movingFrameReset();
				}
			}
			
			return video_time;
		}
		private function __clipBuffer(event:Event):void
		{
			try
			{
				if (__paused || (! __moving))
				{
					if (__goingFrame != -1)
					{
						gotoFrame(__goingFrame);
					}
				}
				dispatchEvent(new Event(EventType.BUFFER));
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __clipInRange(clip:IClip, first:Number, last:Number, visual:Boolean):Boolean
		{
			var clip_range:Boolean = false;
			
			var visual:Boolean = clip.isVisual();
			
			var clip_start:Number = clip.startFrame;
			var clip_pad_start:Number = (visual ? clip.startPadFrame : 0);
			var test_start:Number = clip_start - clip_pad_start;
			
			if (test_start <= last)
			{

				var clip_end:Number = clip_start + clip.lengthFrame;
				var clip_pad_end:Number = (visual ? clip.endPadFrame : 0);
				var test_end:Number = clip_end + clip_pad_end;
				
				if (test_end > first)
				{
					
					clip_range = true;
				}
			
			}
			return clip_range;
		}
		private function __clipRange(clip:IClip, first:Number, last:Number, visual:Boolean):Object
		{
			var clip_range:Object = null;
			
			
			var clip_start:Number = clip.startFrame;
			var clip_pad_start:Number = (visual ? clip.startPadFrame : 0);
			var test_start:Number = clip_start - clip_pad_start;
			
			if (test_start <= last)
			{

				var clip_end:Number = clip_start + clip.lengthFrame;
				var clip_pad_end:Number = (visual ? clip.endPadFrame : 0);
				var test_end:Number = clip_end + clip_pad_end;
				
				// shouldn't this be >= ???!!!
				if (test_end >= first)
				{
					test_start = Math.max(first, clip_start);
					test_end = Math.min(last, clip_end);
					if (test_start > test_end) 
					{
						test_start = test_end;
					}
					clip_range = new Object();
					clip_range.start = test_start;
					clip_range.end = test_end;
				}
			
			}
			return clip_range;
		}
		private function __clipRanges(first:Number, last:Number):Dictionary
		{
			
			var dict:Dictionary = new Dictionary();
			
			var track:Array;
			var y:uint;
			var j:uint;
			var clip:IClip;
			var z:uint = __trackTypes.length;
			var type:String;
			var clip_range:Object;
			for (var i:uint = 0; i < z; i++)
			{
				type = __trackTypes[i];
				track = __tracks[type];
				y = track.length;
				for (j = 0; j < y; j++)
				{
					clip = track[j];
					
					if (clip == null) continue;
					
					clip_range = __clipRange(clip, first, last, (i == 2));
					if (clip_range != null)
					{
						dict[clip] = clip_range;
					}
					
				}
			}
			return dict;
		}
		private function __clipStall(event:Event):void
		{
			try
			{
				var clip:IClip = event.target as IClip;
				if (clip != null)
				{
					if (__moving && (__playingClips[clip] != null))
					{
						__bufferTimed(null);
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__clipStall', e);
			}
		}
		private function __clearContainers():void
		{
			var z:uint = __containers.length;
			var i:uint;
			var container:DisplayObjectContainer;
			var child:DisplayObject;
			for (i = 0; i < z; i++)
			{
				container = __containers[i];
				container.mask = null;
				if (container.parent != null)
				{
					container.parent.removeChild(container);
				}
				if (container.numChildren > 0)
				{
					child = container.getChildAt(0);
					container.removeChild(child);
				}
			}
			__containers = new Array();
		}
		private function __completeFetch(event:Event):void
		{
			try
			{
				var mash_tag:XML;
				var x:XML = __dataFetcher.xmlObject();
				__dataFetcher.removeEventListener(Event.COMPLETE, __completeFetch);
				__dataFetcher = null;
				var list:XMLList;
				
				
				list = x.mash;
				if (list.length())
				{
					mash_tag = list[0];
					RunClass.MovieMasher['parseConfig'](x);
					
					tag = mash_tag;
					__clipBuffer(null);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __createContainer():DisplayObjectContainer
		{
			var container:Sprite = new Sprite();
			//container.name = name;
			__containers.push(container);
			return container;
		}
		private function __dispatchEvent(property:String):void
		{
			if (hasEventListener(property))
			{
				dispatchEvent(new ChangeEvent(getValue(property), property));
			}
		}
		private function __displayBufferedFrame(now:Number):Boolean
		{
			var did_draw:Boolean = false;
			
			try
			{
				now = Math.max(0, Math.min(__lengthFrame, now));
				if (__paused || (__frame != now))
				{
					
					__frame = now;
					
					__displayFrame = ((__frame == __lengthFrame) ? Math.max(0, __lengthFrame - 1) : __frame);
					
					
					__playingClipsRecalculate();
					
					if (__bitmapSize != null)
					{
						if (__clipsChanged) 
						{
							__clearContainers();
						}
						if (__lengthFrame)
						{
						
							var v_clips:Array = __playingVideoClips();
							
							__appliedEffects = new Dictionary();
							if (v_clips.length == 3)
							{
								 did_draw = __applyClips(v_clips);
							}
							else
							{
								did_draw = __applyClip(v_clips[0]);
							}
						
							if ((! did_draw) && __moving)
							{
								RunClass.MovieMasher['msg'](this + '.__displayBufferedFrame could not draw ' + __frame);
								__bufferTimed(null);
							}
						}
						
					}		
					if (__moving)
					{
						var clips:Array = __playingAudioClips();
						
						for each (var clip:IClip in clips)
						{
							__setClipVolume(clip);
						}
					} 
					



					__clipsChanged = false;
					if (hasEventListener(PlayerProperty.LOCATION)) 
					{
						dispatchEvent(new ChangeEvent(new Value(__frame), PlayerProperty.LOCATION));
					}
					

					if (! __moving)
					{
						var audio_frame:Number = __clipAudioFrame();
						audio_frame = Math.min(__lengthFrame - 1, audio_frame);
				
						if ((audio_frame != -1) && (audio_frame != __displayFrame))
						{
							gotoFrame(audio_frame);
						}
					}

				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__displayBufferedFrame', e);
			}			
			
			return did_draw;
		}
		private function __initClips():void
		{
			__playingClips = new Dictionary();
			__bufferingClips = new Dictionary();
			__activeClips = new Dictionary();
			__containers = new Array();
		}
		private function __limitRange(first:Number, last:Number):Object
		{
			var range:Object = new Object();
			range.start = first;
			range.end = last;
			var limit:Number = (__lengthFrame - 1);
			if (range.end > limit) 
			{
				range.end = limit;
				if (range.start > limit)
				{
					range.start = limit;
				}
			}
			return range;
		}
		private function __loadTimed(event:TimerEvent):void
		{
		//	event.updateAfterEvent();
			var now:Number = __clipAudioFrame();
			
			if (now < __lengthFrame)
			{
				__displayBufferedFrame(now);
			}
			else
			{
				if (getValue(PlayerProperty.AUTOSTOP).boolean) 
				{
					paused = true;
				}
				else
				{
					//RunClass.MovieMasher['msg'](this + '.__loadTimed __setMoving false');

					__setMoving(false);
					 if (__lengthFrame) 
					 {
						// reposition to begining, but treat it as a seek since rebuffering may have 
						// caused true video clips to errantly report they are buffered
						 gotoFrame(0);
					}
				}
			}
		}
		private function __moviemasherFullscreen(event:FullScreenEvent):void
		{
			if (! event.fullScreen)
			{
				__fullScreen = false;
				// broadcast state, since we didn't if play was initiated by fullscreen
				dispatchEvent(new ChangeEvent(getValue(PlayerProperty.PLAY), PlayerProperty.PLAY));
			}
		}		
		private function __movingFrame():Number
		{
			var now:Number = (new Date()).getTime();
			return __movingTimeFrame + RunClass.TimeUtility['convertFrame'](RunClass.TimeUtility['frameFromTime']((now - __movingTimeSampled) / 1000), 0, getValue(MashProperty.QUANTIZE).number, '');
		}
		private function __movingFrameReset():void
		{
			__movingTimeFrame = __frame;
			__movingTimeSampled = (new Date()).getTime();
		}
		private function __newLengthFrame(cur_time:Number):void
		{
			if (__lengthFrame != cur_time)
			{
				__lengthFrame = cur_time;
				__adjustEffectsLength();
				
		
				__dispatchEvent(ClipProperty.LENGTH);
			}
		}
		private function __parseTag():void
		{
			try
			{
				
				__originalKeys = new Array();
				var key:String;
				for (key in _attributes)
				{
					__originalKeys.push(key);
				}
				
				if (getValue(CommonWords.ID).empty) _tag.@id = RunClass.MD5['hash'](Capabilities.serverString + String((new Date()).getTime()) + String(Math.random()));

				var quantize:Number = getValue(MashProperty.QUANTIZE).number;
				var needs_requantization:Boolean = ! quantize;
				if (needs_requantization) 
				{
					// it wasn't specified, so assume time values are fractional seconds
					super.setValue(new Value(1), MashProperty.QUANTIZE);
				}
				
				var clip : IClip;
				var children:XMLList = _tag.clip;
				var type:String;
				for each (var clip_node:XML in children)
				{
					clip = Clip.fromXML(clip_node, this);
					if (clip != null)
					{
						type = (clip.isVisual() ? ClipType.VIDEO : clip.getValue(CommonWords.TYPE).string);
						__tracks[type].push(clip);
					}
					else
					{
						RunClass.MovieMasher['msg'](this + '.__parseTag could not create clip: '  + clip_node.toXMLString());
					}
				}
				invalidateLengths();
				if (needs_requantization) 
				{
					// see if the old fps property is set
					quantize = super.getValue(MediaProperty.FPS).number;
					// otherwise use default rate (see ConfigManager)
					if (! quantize) quantize = RunClass.MovieMasher['getOption']('mash', MashProperty.QUANTIZE);
					setValue(new Value(quantize), MashProperty.QUANTIZE);
				}			
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + _tag.toXMLString(), e);
			}
		}
		private function __playingAudioClips():Array
		{
			var array:Array = new Array();
			for each (var clip:IClip in __playingClips)
			{
				if (clip.keepsTime)
				{
					array.push(clip);
				}
			}
			return array;
		}
		private function __playingClipsRecalculate():void
		{
			var clip:IClip;
			var clips:Array;
			try
			{
				var was_playing:Dictionary;
				var i:uint;
				var changed:Boolean = true;
				was_playing = __playingClips;
				__playingClips = new Dictionary();
				
				
				clips = clipsInRange(__displayFrame, __displayFrame); 
				
				
				for each (clip in clips)
				{
				
					
					if ((clip.type == ClipType.AUDIO) && ((! __volume) || (! clip.getValue(ClipProperty.HASAUDIO).boolean)))
					{
						// audio clips are ignored if either I or they have no volume
						continue;
					}
					
					
					if (was_playing[clip] == null)
					{
						__clipsChanged = true;
						clip.addEventListener(EventType.STALL, __clipStall);
						
						if (__moving && clip.getValue(ClipProperty.HASAUDIO).boolean)
						{
							clip.metrics = __bitmapSize;
							changed = clip.setFrame(__displayFrame);
							__setClipVolume(clip);
						}
						clip.playing = __moving;
						
					}
					__playingClips[clip] = clip;
				}
				
				for each (clip in was_playing)
				{
					if (__playingClips[clip] == null)
					{
						__clipsChanged = true;
						clip.removeEventListener(EventType.STALL, __clipStall);
						clip.playing = false;
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}			
			
		}
		private function __playingEffectClips():Array
		{
			var array:Array = new Array();
			for each (var clip:IClip in __playingClips)
			{
				if (clip.getValue(CommonWords.TYPE).equals(ClipType.EFFECT))
				{
					array.push(clip);
				}
			}
			return array;
		}
		private function __playingVideoClips():Array
		{
			var array:Array = new Array();
			var clip:IClip;
			var z:int
			try
			{
				for each (clip in __playingClips)
				{
					if (clip.isVisual())
					{
						array.push(clip);
					}
				}
				z = array.length;
				if (z > 1) 
				{
					array.sort(sortByTimeTrans);
				}
				if (z == 1)
				{
					clip = array[0];
					if (clip.getValue(CommonWords.TYPE).equals(ClipType.TRANSITION))
					{
						array.length = 0;
					}
				}
				else if (z == 2)
				{
					z = 3;
					clip = array[0];
					if (clip.getValue(CommonWords.TYPE).equals(ClipType.TRANSITION))
					{
						array.unshift(null);
					}
					else
					{
						clip = array[1];
						if (clip.getValue(CommonWords.TYPE).equals(ClipType.TRANSITION))
						{
							array.push(null);
						}
						else
						{
							// no transition? clips must be overlapping :(
							array.pop();
							z = 1;
						}
					}
				}
				if (z == 3)
				{
					clip = array[1];
					if (! clip.getValue(CommonWords.TYPE).equals(ClipType.TRANSITION))
					{
						array.splice(1,1);
						array.push(clip);
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			
			return array;
		}
		private function __positionCanvas():void
		{
			if ((__metrics != null) && (! getValue('dontreposition').boolean))
			{
				var first_time:Boolean = ! (__canvas_mc.x || __canvas_mc.y);
				
				__canvas_mc.x =  (__metrics.width / 2);
				__canvas_mc.y =  (__metrics.height / 2);
				if (! first_time)
				{
					if (__goingFrame == -1)	
					{
						gotoFrame(__frame);
					}
				}
			}
		}
		private function __recalculateTrackLength(type:String):void
		{

			var a:Array = __tracks[type];

			a.sort(sortByTimeTrack);
			var cur_time:Number = 0;
			var z:int = a.length;
			var highest_track:int = 0;
			var clip_track:int;
			var clip:IClip;
			for (var i = 0; i < z; i++)
			{
				clip = a[i];
				clip_track = clip.getValue(ClipProperty.TRACK).number;
				// don't include mash effects (track -1)
				if (clip_track > -1)
				{
					cur_time = Math.max(cur_time, clip.lengthFrame + clip.startFrame);
					highest_track = Math.max(highest_track, clip_track);
				}
			}
			if (__lengths[type] != cur_time)
			{
				__lengths[type] = cur_time;
				cur_time = Math.max(__lengths.effect, Math.max(__lengths.audio, __lengths.video));
				__newLengthFrame(cur_time);			
			}
			if (__highest[type] != highest_track)
			{
				__highest[type] = highest_track;
				__dispatchEvent(MashProperty.TRACKS);
			}
		}
		private function __recalculateVideoLength():void
		{
			var z:int = __tracks.video.length;
			var cur_time:Number = 0;
			
			var clip:IClip;
			var left_clip:IClip;
			var right_clip:IClip;
			var transitions:Array = [];
			
			var last_type:String = '';
			var type:String;
			var left_padding:Number = 0;
			var right_padding:Number = 0;
			var trans_offset:Number = 0;
			var left_offset:Number = 0;
			var right_offset:Number = 0;
			var last_transition:Object;
			var clip_length:Number;
			var transition_length:Number;
			var freeze:Boolean;
			var y:Number;
			for (var i:int = 0; i < z; i++)
			{
				clip = __tracks.video[i];
				clip.index = i;
				
				type = clip.getValue(CommonWords.TYPE).string;
				switch (type)
				{
					case ClipType.TRANSITION :
						// this is the first transition
						last_transition = clip;
						break;
					default :
						// non transition clip
						clip.startPadFrame = 0;
						clip.endPadFrame = 0;
						
						if (last_transition)
						{
							// cur_time = the end time of last non trans clip
							transition_length = last_transition.lengthFrame;
							if (left_clip)
							{
								clip_length = left_clip.lengthFrame;
								freeze = last_transition.getValue(ClipProperty.FREEZESTART).boolean || left_clip.getValue(ClipProperty.FREEZEEND).boolean;
								left_padding = __transitionBuffer(clip_length, transition_length, freeze);
								left_clip.endPadFrame = left_padding;
							}
							else
							{
								left_padding = last_transition.lengthFrame;
							}
							right_clip = clip;
							clip_length = right_clip.lengthFrame;
							freeze = last_transition.getValue(ClipProperty.FREEZEEND).boolean || right_clip.getValue(ClipProperty.FREEZESTART).boolean;
							right_padding = __transitionBuffer(clip_length, transition_length, freeze);
							right_clip.startPadFrame = right_padding;
								
							cur_time -= transition_length;
							cur_time += left_padding;
							
							last_transition.startFrame = cur_time;
							last_transition = null;
							cur_time += right_padding;
						}
						clip.startFrame = cur_time;
						cur_time += clip.lengthFrame;
						left_clip = clip;
				}
				last_type = type;
			}
			if (last_transition)
			{
				// mash ends with transitions
				transition_length = last_transition.lengthFrame;
				if (left_clip)
				{
					clip_length = left_clip.lengthFrame;
					freeze = last_transition.getValue(ClipProperty.FREEZESTART).boolean;
					left_padding = __transitionBuffer(clip_length, transition_length, freeze)
					left_clip.endPadFrame = left_padding;
				}
				else
				{
					left_padding = transition_length;
				}
				cur_time += left_padding;
				last_transition.startFrame = cur_time - transition_length;
			}
			if (__lengths.video != cur_time)
			{
				__lengths.video = cur_time;
				cur_time = Math.max(__lengths.effect, Math.max(__lengths.audio, __lengths.video));
				__newLengthFrame(cur_time);
			}
			if (Boolean(__highest.video) != Boolean(z))
			{
				__highest.video = (z ? 1 : 0);
				__dispatchEvent(MashProperty.TRACKS);
			}
		}
		private function __setClipVolume(clip:IClip):void
		{
			var clip_volume:Number = clip.volumeFromTime(__displayFrame, __volume);
			clip.module.volume = clip_volume;
		}
		private function __setDirty(tf:Boolean):void
		{
			
			if (! getValue(MashProperty.READONLY).boolean)
			{
				if (__moving) 
				{
					gotoFrame(-1);
				}
				if (__needsSave != tf)
				{
					__needsSave = tf;
					
					dispatchEvent(new ChangeEvent(new Value(tf ? '1' : '0'), PlayerProperty.DIRTY));
				}
			}
		}
		private function __setMoving(tf:Boolean):Boolean
		{
			var changed:Boolean = false; // whether or not displayed clips changed
			try
			{
					
				if (__moving != tf)
				{
					__moving = tf;
					
					//RunClass.MovieMasher['msg'](this + '.__setMoving ' + __moving);
					if (__moving)
					{
						__movingFrameReset();	
			
						__loadTimer = new Timer(Math.max(50, 500 / RunClass.TimeUtility['fps']));
						__loadTimer.addEventListener(TimerEvent.TIMER, __loadTimed);
						__loadTimer.start();
					}
					else
					{
						__loadTimer.removeEventListener(TimerEvent.TIMER, __loadTimed);
						__loadTimer.stop();
						__loadTimer = null;
					}
					var the_frame:Number = ((__goingFrame == -1) ? __displayFrame : __goingFrame)
					for each (var clip:IClip in __playingClips)
					{
						if (clip == null) continue;
						if (__moving && clip.getValue(ClipProperty.HASAUDIO).boolean)
						{
							clip.metrics = __bitmapSize;
							changed = (clip.setFrame(__displayFrame) || changed);
							__setClipVolume(clip);
						}
						clip.playing = __moving;
					}
					__setStalling((! __moving) && (! __paused));
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
			return changed;
		}
		private function __setQuantize(n:int):void
		{
			var quantize:int = getValue(MashProperty.QUANTIZE).number;
			if (n != quantize)
			{
				// change quantization for all clip times
				var z:uint = __trackTypes.length;
				var type:String;
				var y:uint;
				var j:uint;
				var clips:Array;
				var clip:Clip;
				for (var i:uint = 0; i < z; i++)
				{
					type = __trackTypes[i];
					clips = __tracks[type];
					y = clips.length;
					for (j = 0; j < y; j++)
					{
						clip = clips[j];
						clip.changeQuantization(quantize, n);
					}
			
				}
				// so this function isn't called recursively
				super.setValue(new Value(n), MashProperty.QUANTIZE);
				
				invalidateLengths();
			}
			
		}
		private function __setStalling(tf:Boolean):Boolean
		{
			var changed:Boolean = false; // whether or not __stalling changed
			if (__stalling != tf)
			{
				__stalling = tf;
				if (__bufferTimer != null) __bufferTimer.delay = (tf ? 10 : 1000);
				//RunClass.MovieMasher['msg'](this + '.__setStalling ' + __stalling);
				changed = true;
				if (hasEventListener(MashProperty.STALLING)) dispatchEvent(new ChangeEvent(new Value(__stalling), MashProperty.STALLING));
			}
			return changed;
		}
		private function __transitionBuffer(clip_time:Number, trans_time:Number, is_stopped:Boolean):Number
		{
			if (is_stopped)
			{
				return trans_time;
			}
			var target_time:Number = trans_time + Math.ceil(clip_time / 2);
			target_time -= clip_time;
			return Math.max(target_time,0);
		}
		private function __unbuffer(first:Number = -1, last:Number = -1, first2:Number = -1, last2:Number = -1):void
		{
			try
			{
				first = Math.round(first);
				last = Math.round(last);
				first2 = Math.round(first2);
				last2 = Math.round(last2);
				if (first <= last2) return;
				
				
				
				last = Math.min(last, Math.max(0, __lengthFrame - 1));
				last2 = Math.min(last2, Math.max(0, __lengthFrame - 1));
				
				var range:Object = __limitRange(first, last);
				
				var unbuffer:Boolean = false;
				var clip_start:Number;
				var clip_end:Number;
				var keep_buffered:Object;
				var keep_start:Number;
				var keep_end:Number;
				var outside_range1:Boolean;
				var outside_range2:Boolean;
				
				var clip_length:Number;
				
				for each (var clip:IClip in __activeClips)
				{
					if (clip == null) continue;
					
					keep_start = -1;
					keep_end = -1;
					
					clip_length = clip.lengthFrame;
					clip_start = clip.startFrame;
					clip_end = clip_start + clip_length;
					clip_start -= clip.startPadFrame;
					clip_end += clip.endPadFrame;
					
					outside_range1 =  (clip_start > last) || (clip_end < first)
					outside_range2 =  (first2 == -1) || (clip_start > last2) || (clip_end < first2)
					
					if (outside_range1 && outside_range2)
					{
					//	RunClass.MovieMasher['msg'](this + '.__unbuffer unloading ' + clip + ' ' + clip_start + ' ' + clip_end + ' ' + first + ' ' + last);
						
						clip.unload();
						clip.removeEventListener(EventType.BUFFER, __clipBuffer);
						clip.removeEventListener(EventType.STALL, __clipStall);
						delete __activeClips[clip];
						delete __bufferingClips[clip];
					
					}
					else
					{
						keep_start = clip_start;
						keep_end = clip_end;
						if (outside_range1 || outside_range2)
						{
							// we can trim it down a bit
							if (outside_range1)
							{
								// rebuffering the begining of mash, clip is in begining
								if (keep_start < first2)
								{
									keep_start = first2;
								}
								if (keep_end > last2)
								{
									keep_end = last2;
								}
							}
							else
							{
								if (keep_start < first)
								{
									keep_start = first;
								}
								if (keep_end > last)
								{
									keep_end = last;
								}
							}
							clip.unbuffer(keep_start, keep_end);
						}
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}

								
		
		}
		private function __xml():XML
		{
			//__adjustEffectsLength();
			var mash_tag:XML = <mash />;
			var attr_list:XMLList = _tag.@*;
			var name:String;
			for each (var attribute:XML in attr_list)
			{
				name = attribute.name();
				switch(name)
				{
					case PlayerProperty.BUFFERTIME:
					case PlayerProperty.UNBUFFERTIME:
					case PlayerProperty.MINBUFFERTIME:
					case PlayerProperty.AUTOSTOP:
					case PlayerProperty.PLAY:
						break;		
					default: mash_tag.@[name] = getValue(name).string;
				}
			}
			mash_tag.@quantize = getValue(MashProperty.QUANTIZE).number;
			
			var z:uint = __trackTypes.length;
			var type:String;
			var y:uint;
			var j:uint;
			var clips:Array;
			var clip:IClip;
			for (var i:uint = 0; i < z; i++)
			{
				type = __trackTypes[i];
				clips = __tracks[type];
				if (type == ClipType.EFFECT) clips.sortOn(ClipProperty.TRACK, Array.NUMERIC);
			//	RunClass.MovieMasher['msg'](this + '.__xml ' + type + ' ' + clips);
				y = clips.length;
				for (j = 0; j < y; j++)
				{
					clip = clips[j];
					mash_tag.appendChild(clip.getValue(ClipProperty.XML).object as XML);
				}
			}
			return mash_tag;
		}
		private const BLOCK_SIZE: int = 8192;
		private static var __trackTypes:Array = [ClipType.EFFECT, ClipType.AUDIO, ClipType.VIDEO];
		private var __activeClips:Dictionary;
		private var __appliedEffects:Dictionary;
		private var __backcolor_mc:Sprite;
		private var __bitmapSize:Size;
		private var __bufferingClips:Dictionary;
		private var __buffertime:Number;
		private var __bufferTimer:Timer;
		private var __canvas_mc:Sprite;
		private var __clipsChanged:Boolean = true;
		private var __containers:Array;
		private var __displayFrame:Number = -1;
		private var __drawFrameTime:Number = 2000;
		private var __frame:Number = -1;	
		private var __fullScreen:Boolean = false;
		private var __goingFrame:Number = -1; // the frame we are trying to load
		private var __highest:Object;// holds highest track created for audio and effects
		private var __lengthFrame:Number = 0; // the total number of frames in mash
		private var __lengths:Object; // video, audio and effect keys with max frame length
		private var __loadTimer:Timer; // runs while video is actually playing back (not stalled)
		private var __metrics:Size; // the size of displayObject (actual dimensions could differ)
		private var __minbuffertime:Number; 
		private var __moving:Boolean = false;
		private var __movingTimeFrame:Number;
		private var __movingTimeSampled:Number;
		private var __mute:Boolean;
		private var __needsSave:Boolean = false;
		private var __originalKeys:Array;
		private var __paused:Boolean = true;
		private var __playingClips:Dictionary;
		private var __stalling:Boolean = false;
		private var __tracks:Object;
		private var __unbuffertime:Number;
		private var __dataFetcher:IDataFetcher;
		private var __volume:uint = 75;
	}
}


