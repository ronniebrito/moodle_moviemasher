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

package com.moviemasher.display
{
	import flash.system.ApplicationDomain;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import com.moviemasher.events.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	
	import com.moviemasher.control.*;
	
/**
* Class represents a control within a bar, containing an {@link IControl}
*
* @see BarView
* @see IControl
*/
	public class ControlView extends View
	{
		public function ControlView(panel:PanelView, bar:BarView)
		{
			__panel = panel;
			__bar = bar;
			_defaults = __controlDefaults;
			visible = false;
		}
		public function dimensionsFromBarSize(space:Number):Size
		{
			
			var wh:Size = new Size();
			var wORh:String = (vertical ? 'height' : 'width');
			var hORw:String = (vertical ? 'width' : 'height');
			
			wh[hORw] = control.getValue(hORw).number;
			if ((! wh[hORw]) || (wh[hORw] > space)) wh[hORw] = space;
			wh[wORh] = control.getValue(wORh).number;
			if (! wh[wORh]) 
			{
				if (control.ratio) 
				{
					var defined_space : Number = control.getValue(hORw).number;
					if (! defined_space) defined_space = space;
					wh[wORh] = Math.round(defined_space * control.ratio);//
				}
			}
			return wh;
		}
		override public function callControls(method:String):void
		{
			if (hasOwnProperty(method)) 
			{
				this[method]();
			}
		}
		override public function resize():void
		{
			try
			{
				super.resize();
				if ( ! ((_width < 0) || (_height < 0))) control.metrics = new Size(_width, _height);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.resize', e);
			}
		}
		public function __changeEvent(event:ChangeEvent):void
		{
			try
			{
				if (__controlProperties[event.property] != null) 
				{
					control.setValue(event.value, event.property);		
				}
				//if (event.property == 'sending') 
				if (__visualProperties[event.property] != null)
				{
					__visibleEnable();
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__changeEvent ' + __visualProperties + ' ' + __controlProperties, e); 
			}
		}
		private var __visualProperties:Object;
		private var __controlProperties:Object;
		
		public function initDispatchers():void
		{
			try
			{
				__visualProperties = new Object();
				__controlProperties = new Object();
				var attribute_array:Array = ['bind','tie','select','disable','hide'];
				var attribute:String;
				var b:int = attribute_array.length;
				var expression:String;
				var s:String;
				var targets : Array;
				var z:int;
				var i:int;
				var bits : Array;
				var dispatcher:IValued;
				var property : String;
				var target :String;
				var ob:Object;
				var did_change:Boolean;
				var listeners:Dictionary = new Dictionary();
				var dispatchers:Dictionary = new Dictionary();
				var listener:IPropertied = null;
				var attribute_value:Value;
				var did_set_property:Boolean = false;
				var attribute_index:int;
				for (attribute_index = 0; attribute_index < b; attribute_index++)
				{
					attribute = attribute_array[attribute_index];
					attribute_value = control.getValue(attribute);
					if (! attribute_value.empty)
					{
						if (attribute_index > 1)
						{
							s = attribute_value.string;
							if (s.indexOf('|') != -1)
							{
								attribute_value.delimiter = '|';
							}
							else if (s.indexOf('&') != -1)
							{
								attribute_value.delimiter = '&';
							}
							
						
						}
						targets = attribute_value.array;
						z = targets.length;
					
						did_change = false;
						if ((! attribute_index) && (z > 1))
						{
							// bind can only have one target
							targets = targets.slice(0,1);
							z = 1;
						}
						
						for (i = 0; i < z; i++)
						{
							expression = targets[i];
							if (attribute_index > 0)
							{
								// only concerned with target for all attributes except 'bind'
								bits = expression.split(/([\w\.]+)([><!]?[=]?)/g);
								expression = bits[1];
								
							}
							
							bits = expression.split('.');
							property = bits.pop();
							target = bits.join('.');
							if (target.length)
							{
								dispatcher = RunClass.MovieMasher['getByID'](target) as IValued;
								
								
								if (dispatcher != null)
								{
									
									if (attribute_index > 1) __visualProperties[property] = true;
									else __controlProperties[property] = true;
									
									
									if (dispatchers[dispatcher] == null)
									{
										dispatchers[dispatcher] = new Object();
									}
									dispatchers[dispatcher][property] = dispatcher;
									
										
									if (! attribute_index)
									{
										if (dispatcher is IPropertied)
										{
											listener = dispatcher as IPropertied
											//if (property == 'dirty') RunClass.MovieMasher['msg'](this + '.initDispatchers listener = ' + listener + ' ' + control);
											listener.addEventBroadcaster(property, control);
											control.property = property;
											did_set_property = true;
										}
									}
									else 
									{
										if ((attribute == 'tie') && (! did_set_property))
										{
											control.property = property;
										}
									}
								}
								else
								{
									RunClass.MovieMasher['msg']("Target not found " + target + ' ' + _tag.toXMLString());
								}
							}
						}
					}
				}
			
				var did:Dictionary = new Dictionary();
				for each (var object:Object in dispatchers)
				{
						
					for (property in object)
					{
						//
						dispatcher = object[property];
						if (did[dispatcher] == null)
						{
							did[dispatcher] = new Object();
						}
						if (did[dispatcher][property] == null)
						{
							did[dispatcher][property] = true;
							//if (property == 'dirty') RunClass.MovieMasher['msg'](this + '.initDispatchers property = ' + property + ' dispatcher = ' + dispatcher + ' control = ' + control);
							dispatcher.addEventListener(property, __changeEvent);
							try
							{
								__changeEvent(new ChangeEvent(dispatcher.getValue(property), property));
							}
							catch(e:*)
							{
								RunClass.MovieMasher['msg'](this + '.initDispatchers', e); 
							}
						}
									
					}
				}
				__visibleEnable();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.initDispatchers', e); 
			}
		}
		public function initListeners():void
		{}
		public function makeConnections():void
		{
			try
			{
				control.initialize();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.makeConnections', e);
			}
		}
		public function finalize():void
		{
			try
			{
				control.finalize();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.finalize', e);
			}
		}
		public function get flexible():Number
		{
			var n:Number = 0;
			var value:Value = control.getValue(vertical ? 'height' : 'width');
			if (! value.empty)
			{
				if (value.NaN)
				{
					n = value.string.length;
				}
			}
			return n;
		}
		override protected function _parseTag():void
		{
			vertical = __bar.vertical;
			_tag.@vertical = (vertical ? '1' : '0');
			
			super._parseTag();
				
			var symbol:String = getValue('symbol').string;
			if (symbol.length)
			{
				var loader:IAssetFetcher = RunClass.MovieMasher['assetFetcher'](symbol, 'swf');
				var c:Class = loader.classObject(symbol, 'control');
				if (c != null)
				{
					control = new c() as IControl;
				}
				if (control != null)
				{
					addChild(control.displayObject);
					try
					{
						control.tag = _tag;
					}
					catch(e:*)
					{
						RunClass.MovieMasher['msg'](this + '._parseTag', e);
					}
					var id:String = control.getValue(CommonWords.ID).string;
					if (id.length)
					{
						RunClass.MovieMasher['setByID'](id, control);
					}				
					if (control.isLoading)
					{
						_loadingThings++;
						control.addEventListener(Event.COMPLETE, _tagCompleted);
					}
				}
			}
		}
		private function __visibleEnable():Boolean
		{
			var should_be_visible:Boolean = false;
			var should_be_disabled:Boolean = false;
			var should_be_selected:Boolean = false;
			var msg:String = 'hide';
			try
			{
				
				should_be_visible = ! __evaluateProperty('hide');
				msg = 'disable';
				
				if (should_be_visible)
				{
					should_be_disabled = __evaluateProperty('disable');
					msg = 'select';
				
					if (! should_be_disabled)
					{
						should_be_selected = __evaluateProperty('select');
						if (__controlSelected != should_be_selected)
						{
							__controlSelected = should_be_selected;
							msg = 'selected';
				
							control.selected = __controlSelected;
						}
					}
					
					if (__controlDisabled != should_be_disabled)
					{
						__controlDisabled = should_be_disabled;
						msg = 'disabled';
				
						control.disabled = __controlDisabled;
					}
				}
				if (visible != should_be_visible)
				{
					visible = should_be_visible;
					msg = 'hidden';
				
					control.hidden = ! should_be_visible;
					msg = 'inval';
				
					invalidateUp();
					
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__visibleEnable ' + msg, e);
			}
			return ((! should_be_disabled) && should_be_visible);
		}
		public function invalidateUp():void
		{
			invalidate();
			__bar.invalidate();
			__panel.invalidate();
			__panel.delayedDraw();
		}
		private function __evaluateExpression(expression:String):Boolean
		{
			var elements:Array = new Array();
			var property:String = '';
			var value:Value = null;
			
			var ok = false;
			try
			{
				if (expression.length)
				{
					elements = expression.split(/([\w\.]+)([><!]?[=]?)([\w\,\.]+)/g);
					var z:uint = elements.length;
					if (z == 5)
					{
						var bits:Array = elements[1].split('.');
						if (bits.length > 1)
						{
							property = bits.pop();
							if (property.length)
							{
								var ob:IValued = null;
								try
								{
									ob = RunClass.MovieMasher['getByID'](bits.join('.')) as IValued;
								}
								catch(e:*)
								{
									RunClass.MovieMasher['msg'](this + '.__evaluateExpression ob = ' + bits.join('.'), e);
								}

								if (ob != null)
								{
									var test_value:String = elements[3];
									if ( (test_value == 'undefined') || (test_value == 'null')  || (test_value == 'empty') )
									{
										value = ob.getValue(property);
										
										var is_undefined:Boolean = value[((test_value == 'empty') ? 'empty' : 'undefined')];
										
										switch (elements[2])
										{
											case '=' :
												ok = is_undefined;
												break;
											case '!=' :
											case '>' :
											case '>=' :
												ok = ! is_undefined;
												break;
											
										}
									}
									else
									{
										try
										{
											value = ob.getValue(property);
											property = value.string;
										}
										catch(e:*)
										{
											RunClass.MovieMasher['msg'](this + '.__evaluateExpression getValue ' + property, e);
										}
										switch (elements[2])
										{
											case '>' :
												ok = (Number(property) > Number(test_value));
												break;
											case '>=' :
												ok = (Number(property) >= Number(test_value));
												break;
											case '<' :
												ok = (Number(property) < Number(test_value));
												break;
											case '<=' :
												ok = (Number(property) <= Number(test_value));
												break;
											case '!=' :
												ok = (property != test_value);
												break;
											case '=' :
												ok = (property == test_value);
												break;
											
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
				RunClass.MovieMasher['msg'](this + '.__evaluateExpression ' + expression + ' ' + elements + ' ' + property, e);
			}
			return ok;
		}
		private function __evaluateProperty(property:String):Boolean
		{
			var should:Boolean = false;
			var i:uint = 0;
			var expressions:Array = new Array();
			try
			{
				var value:Value = control.getValue(property);
				if (! value.empty)
				{
					var and_search:Boolean = (value.string.indexOf('|') == -1);
				
					//value.delimiter = ;
					expressions = value.string.split((and_search ? '&' : '|'));
					//RunClass.MovieMasher['msg'](this + '.__evaluateProperty ' + property + ' ' + value.string + ' ' + expressions);
					var z:uint = expressions.length;
					for (; i < z; i++)
					{
						should = __evaluateExpression(expressions[i]);
						if (should && (! and_search))
						{
							break;
						}
						if ((! should) && and_search)
						{
							break;
						}
						
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__evaluateProperty ' + property + ' ' + expressions + ' ' + i, e);
			}

			return should;
		}
		override public function toString():String
		{
			var s:String = super.toString();
			s += ' ' + control;
			if (control != null) s += ' ' + control.getValue(CommonWords.ID).string;
			else s += _tag.toXMLString();
			return s;
		}
		public var vertical:Boolean;
		public var control:IControl;
		private var __controlDisabled:Boolean = false;
		private var __controlSelected:Boolean = false;
		private static var __controlDefaults : Object = {align: 'center', angle: '90', color: '', curve: '0', grad: '0', padding: '0', spacing: '0', alpha:'100'};
		private var __panel:PanelView;
		private var __bar:BarView;
		
	}
}