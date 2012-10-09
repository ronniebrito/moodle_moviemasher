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
	import com.moviemasher.events.*;
	import com.moviemasher.interfaces.*;
	import com.moviemasher.type.*;
	import com.moviemasher.constant.*;
	import com.moviemasher.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import s3.flash.*;

/**
* Implimentation class represents a control for interacting with CGI scripts
*/
	public class CGI extends Text
	{
		
		public function CGI()
		{
			_defaults.id = 'cgi';
			_defaults[CGIProperty.UPLOADNAME] = 'Filedata';
			_defaults[CGIProperty.DOWNLOADNAME] = 'mash.mp4';
			_allowFlexibility = false;
			
		}
		override public function initialize():void 
		{
			super.initialize();
			__cgiStop();
			var n:Number = super.getValue(CGIProperty.PROGRESS).number;
			if (n) __cgiSetProgress(n);
			if (getValue(CGIProperty.AUTOLOAD).boolean) 
			{
				__cgiStart();
				__cgiTask();
			}
		}
		override public function getValue(property:String):Value
		{
			var value:Value;
			switch (property)
			{
				case CGIProperty.PROGRESS:
					value = new Value(__progress ? __progress:Value.UNDEFINED);
					break;
				case CGIProperty.STATUS:
					value = new Value(__status.length ? __status : '');
					break;
				case 'filename':
					value = new Value(((__fileReference == null) ? '' : __fileReference.name));
					break;
				case 'filesize':
					value = new Value(((__fileReference == null) ? '' : __fileReference.size));
					break;
				default:
					if (__sessionHasKey(property))
					{
						value = new Value(__cgiSession[property]);
					}
					else
					{
						value = super.getValue(property);
					}
			}
			return value;
		}
		override public function setValue(value:Value, property:String):Boolean
		{
			
			switch(property)
			{
				case CGIProperty.MASH:
					__mash = value.object as IMash;
					break;
				case CGIProperty.STATUS:
				case CGIProperty.PROGRESS:
					break;
				default: 
					//RunClass.MovieMasher['msg'](this + '.setValue ' + property + ' ' + value.string + ' ' + __setting);
					if (! __setting)
					{
						__setting = true;
						super.setValue(value, property);
						dispatchEvent(new ChangeEvent(value, property));
						__setting = false;
					}
			}
			return false;
		}
 		override protected function _release():void
		{
			try
			{
			//	RunClass.MovieMasher['msg'](this + '._release ' + _disabled);
					
				if (! _disabled)
				{
					
					__cgiStart();
					__choosing = __sessionHasKey(CGIProperty.CHOOSE);
					
					if (__sessionHasKey(CGIProperty.UPLOAD) || __choosing) 
					{
						// upload or choose file
						__fileReference = new FileReference();
						__addListeners(__fileReference, true);
						
						var filetype_list:XMLList = _tag.filetype;
						var z:int = filetype_list.length();
						var file_types:Array = new Array();
						var file_type:XML;
						for (var i:int = 0; i < z; i++)
						{
							file_type = filetype_list[i];
							file_types.push(new FileFilter(String(file_type.@description), String(file_type.@extension)));
						}
						if (file_types.length) 
						{
							__fileReference.browse(file_types);
						}
						else __fileReference.browse();

					}
					else if (__sessionHasKey(CGIProperty.DOWNLOAD)) 
					{
						// download file
						__fileReference = new FileReference();
						__addListeners(__fileReference, false);
						var url_string:String = __cgiSession[CGIProperty.DOWNLOAD]
						url_string = RunClass.ParseUtility['brackets'](url_string);
						
						var url:Object = new RunClass.URL(url_string);
						
						__fileReference.download(new URLRequest(url.absoluteURL), __cgiSession[CGIProperty.DOWNLOADNAME]);
						__cgiSetProgress(1);

					}
					else 
					{
						__cgiTask();
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__xmlLoaded', e);
			}
		}
        private function __addListeners(dispatcher:IEventDispatcher, uploading:Boolean = false):void 
		{
            dispatcher.addEventListener(Event.CANCEL, __errorCancel);
            if (! __choosing) dispatcher.addEventListener(IOErrorEvent.IO_ERROR, __errorIO);
            //dispatcher.addEventListener(Event.OPEN, openHandler);
			
            dispatcher.addEventListener(ProgressEvent.PROGRESS, __didProgress);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __errorSecurity);
            if (uploading)
			{
         		dispatcher.addEventListener(Event.SELECT, __completeSelect);
            	if (! __choosing) dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, __errorHTTP);
              	dispatcher.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,__completeUpload);
			}
			else
			{
				dispatcher.addEventListener(Event.COMPLETE, __completeDownload);
			}
        }
		private function __appendReferencedMediaXML(node:XML):XML
		{
			if (__mash != null)
			{
				
				var dictionary:Object = __mash.referencedMedia();
				for each (var node_xml:XML in dictionary)
				{
					node.appendChild(node_xml);
				}
			}
			return node;
		}
		private function __cgiRequestClear()
		{
			
			if (__sessionHasKey(CGIProperty.UPLOAD)) // just uploaded file
			{
				__cgiSession[CGIProperty.UPLOAD] = '';
			}
			else if (__sessionHasKey(CGIProperty.URL))
			{
				__cgiSession[CGIProperty.URL] = '';
				if (__sessionHasKey(CGIProperty.MEDIA)) __cgiSession[CGIProperty.MEDIA] = '';
				if (__sessionHasKey(CGIProperty.MASH) && (__mash != null)) 
				{
					__cgiSession[CGIProperty.MASH] = '';
					//__mash.setValue(new Value('0'), PlayerProperty.DIRTY);
				}
			}
		}
		private function __cgiSetProgress(n:Number):void
		{
			__progress = n;
			dispatchEvent(new ChangeEvent(getValue(CGIProperty.PROGRESS), CGIProperty.PROGRESS));
		}
		private function __cgiSetStatus(s:String):void
		{
			__status = s;
			dispatchEvent(new ChangeEvent(getValue(CGIProperty.STATUS), CGIProperty.STATUS));
		}
		private function __cgiStart()
		{
			try
			{
				if (__cgiSession == null)
				{
					__cgiSession = XMLUtility.attributeData(_tag);
					
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__cgiStart', e);
			}
		}
		private function __cgiStartURL(event:TimerEvent, url_string:String = null):void
		{
			if (url_string == null) url_string = __cgiSession[CGIProperty.URL];
			var url:String;
			try
			{
				if (__delayInterval != null) 
				{
					__delayInterval.stop();
					__delayInterval.removeEventListener(TimerEvent.TIMER, __cgiStartURL);
					__delayInterval = null;
				}
				if ((__cgiSession[CGIProperty.MASH] != null) && __cgiSession[CGIProperty.MASH])
				{
					__cgiSession[CGIProperty.MASH] = null;
					delete(__cgiSession[CGIProperty.MASH]);
					__cgiSession[CGIProperty.MASH] = __mash;
				}
			
				url = RunClass.ParseUtility['brackets'](url_string);
				if (url.indexOf('{') > -1) url = RunClass.ParseUtility['optionBrackets'](url);
				
				var node:XML = null;
				
				if (__cgiSession[CGIProperty.MEDIA] || __cgiSession[CGIProperty.MASH])
				{
					node = <moviemasher />;
					var container:XML = node;
					if (__sessionHasKey(CGIProperty.MASH) && (__mash != null))
					{
						container = __mash.getValue(ClipProperty.XML).object as XML;
						
						node.appendChild(container);
					}
					if (__sessionHasKey(CGIProperty.MEDIA)) __appendReferencedMediaXML(container);
					
				}
				__loader = RunClass.MovieMasher['dataFetcher'](url, node);
				__loader.addEventListener(Event.COMPLETE, __cgiURLDidLoad);
				
				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__cgiStartURL', e);
			}
		}
		private function __cgiStop(error:String = '')
		{
			try
			{
				__cgiSession = null;
				__fileReference = null;
				__choosing = false;
				__cgiSetStatus(error);
				__cgiSetProgress(0);
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__cgiStop', e);
			}
		}
		private function __cgiTask(dont_url:Boolean = false):void
		{
			try
			{
				var url_string:String;
				var url:Object;
				if (__sessionHasKey(CGIProperty.GET))
				{
					
					url_string = __cgiSession[CGIProperty.GET];
					if (url_string.length)
					{
						url_string = RunClass.ParseUtility['brackets'](url_string);
							
						url = new RunClass.URL(url_string);
						var target:String = '_self';
						if (__sessionHasKey(CGIProperty.TARGET)) 
						{
							target = __cgiSession[CGIProperty.TARGET];
						}
						navigateToURL(new URLRequest(url.absoluteURL), target);
						__cgiSession[CGIProperty.GET] = '';
					}
				}
				
				if (__sessionHasKey(CGIProperty.TRIGGER)) // setting a value for a control
				{
					RunClass.MovieMasher['evaluate'](__cgiSession[CGIProperty.TRIGGER], __cgiSession);
					
					__cgiSession[CGIProperty.TRIGGER] = '';
				}

				if ((! dont_url) && __sessionHasKey(CGIProperty.URL)) 
				{
					// request url
					if (! __doDelay(__cgiSession[CGIProperty.DELAY]))
					{
						__cgiStartURL(null);
					}
				}
				else __cgiStop();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__cgiTask ' + url_string, e);
			}
		}
		private function __cgiURLDidLoad(event:Event):void
		{
			try
			{
				if (__loader != null)
				{
				
					var xml_object:XML = __loader.xmlObject();
					__loader.removeEventListener(Event.COMPLETE, __cgiURLDidLoad);
					__loader = null;
					__xmlLoaded(xml_object);
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__cgiURLDidLoad', e);
			}
		}
		private function __completeDownload(event:Event):void
		{
			try
			{
				__cgiSetProgress(100);
				// only called for downloads
				__removeListeners(__fileReference, false);
				__fileReference = null;
				__cgiSession[CGIProperty.DOWNLOAD] = '';
				
				__cgiStart();
				
				__cgiTask();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__completeDownload', e);
			}
		}
		private function __completeUpload(event:DataEvent):void
		{
			// only sent for uploads
			var xml:XML = null;
			try
			{
				if ((event != null) && (event.data != null) && event.data.length) xml = new XML(event.data);
				if (__fileReference != null) 
				{
					__removeListeners(__fileReference, true);
					__fileReference = null;
				}
				__cgiSetProgress(100);
				__choosing = false;
				__xmlLoaded(xml, true);				
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__completeUpload ' + __fileReference + ' ' + (xml == null), e);
			}
		}
		private function __completeSelect(event:Event):void
		{
			try
			{
				var maxbytes:Number = getValue(CGIProperty.MAXBYTES).number;
				if (maxbytes)
				{
					if (__fileReference.size > maxbytes)
					{
						__cgiStop(StringUtility.byteString(__fileReference.size) + ' > ' + StringUtility.byteString(maxbytes) + ' maximum');
					}
					else
					{
						maxbytes = 0;
					}
				}
				if (! maxbytes)
				{
					
					if (__choosing)
					{
						__cgiStartURL(null, __cgiSession[CGIProperty.CHOOSE]);
					}
					else
					{
						__cgiUploadTransfer();
					}
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__completeSelect', e);
			}
		}
		private function __cgiUploadTransfer(url_string:String = null):void
		{
			if (url_string == null) url_string = __cgiSession[CGIProperty.UPLOAD];
			
			if (url_string.length && (__fileReference != null))
			{
			
				var url:Object = new RunClass.URL(url_string);
				__fileReference.upload(new URLRequest(url.absoluteURL), getValue(CGIProperty.UPLOADNAME).string);
				__cgiSetProgress(1);
			}
			else __cgiStop();
		}
		private function __didProgress(event:ProgressEvent):void
		{
			try
			{
				//__cgiSetStatus('Transfering');
				if (event.bytesTotal)
				{
					__cgiSetProgress(Math.round((event.bytesLoaded * 100) / event.bytesTotal));
				}	
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__didProgress', e);
			}
		}
		private function __doDelay(delay_secs:Number):Boolean
		{
			var do_delay:Boolean = ((! isNaN(delay_secs)) && delay_secs);
			if (do_delay)
			{
				if (__delayInterval == null)
				{
					__delayInterval = new Timer(1000 * delay_secs, 1);
					__delayInterval.addEventListener(TimerEvent.TIMER, __cgiStartURL);
					__delayInterval.start();
				}
			}
			return do_delay;
		}
		private function __errorCancel(event:Event):void
		{
			try
			{
				__cgiStop();
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __errorHTTP(event:Event):void
		{
			try
			{
				__cgiStop(String(event));
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __errorIO(event:Event):void
		{
		//	RunClass.MovieMasher['msg'](this + '.__errorIO');
			
			try
			{
				__cgiStop(String(event));
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __errorSecurity(event:SecurityErrorEvent):void
		{
		//	RunClass.MovieMasher['msg'](this + '.__errorSecurity');
			
			try
			{
				__cgiStop(String(event));
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this, e);
			}
		}
		private function __removeListeners(dispatcher:IEventDispatcher, uploading:Boolean = false):void 
		{
            dispatcher.removeEventListener(Event.CANCEL, __errorCancel);
            dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, __errorIO);
           // dispatcher.removeEventListener(Event.OPEN, openHandler);
            dispatcher.removeEventListener(ProgressEvent.PROGRESS, __didProgress);
            dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, __errorSecurity);
            if (uploading)
			{
				dispatcher.removeEventListener(Event.SELECT, __completeSelect);
           		dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, __errorHTTP);
            	dispatcher.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA,__completeUpload);
			}
			else
			{
				dispatcher.removeEventListener(Event.COMPLETE, __completeDownload);
			}
        }
		private function __sessionHasKey(key:String):Boolean
		{
			
			var has_key:Boolean = false;
			if ((__cgiSession != null) && (__cgiSession[key] != null))
			{
				if (String(__cgiSession[key]).length)
				{
					has_key = true;
				}
			}
			return has_key;
		}
		private function __xmlLoaded(xml:XML, dont_clear:Boolean = false):void
		{
			try
			{
				var choosing:Boolean = __choosing;
				
				//RunClass.MovieMasher['msg'](this + '.__xmlLoaded ' + xml.toXMLString());
				if (! dont_clear) __cgiRequestClear();
				
				XMLUtility.attributeData(xml, __cgiSession);
			
				if (__cgiSession[CGIProperty.PROGRESS] == -1) __cgiStop(__cgiSession[CGIProperty.STATUS]);
				else
				{
					
					if (__sessionHasKey(CGIProperty.STATUS)) 
					{
						__cgiSetStatus(__cgiSession[CGIProperty.STATUS]);
						__cgiSession[CGIProperty.STATUS] = '';
					}
					if (__sessionHasKey(CGIProperty.PROGRESS))
					{
						__cgiSetProgress(__cgiSession[CGIProperty.PROGRESS]);
						__cgiSession[CGIProperty.PROGRESS] = '0';
					}
					if (choosing)
					{
						var acl:String = String(xml.@['acl']);
						var policy:String = String(xml.@['policy']);
						var signature:String = String(xml.@['signature']);
						var mime:String = String(xml.@['mime']);
						var bucket:String = String(xml.@['bucket']);
						var key:String = String(xml.@['key']);
						var keyid:String = String(xml.@['keyid']);
						
						
						
						if (acl.length && policy.length && signature.length && mime.length && bucket.length && key.length && keyid.length)
						{
						
							var options:S3PostOptions = new S3PostOptions()
							options.acl = acl;
							options.contentType = mime;
							options.policy = policy;
							options.signature = signature;
							options.secure = false;
							
						//	RunClass.MovieMasher['msg'](this + '.__xmlLoaded ' + __fileReference);
							
							__request = new S3PostRequest(keyid, bucket, key, options);
							__request.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, __completeUpload);
							//__request.addEventListener(IOErrorEvent.IO_ERROR, __errorIO);
				
							__request.addEventListener(ProgressEvent.PROGRESS, __didProgress);
							__request.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __errorSecurity);
				
							//__request.addEventListener(HTTPStatusEvent.HTTP_STATUS, __errorHTTP);
							__request.upload(__fileReference);
							
						}
						else
						{
							__cgiUploadTransfer();
						}
					}
					else
					{
						var trigger_url:Boolean = true;
						if (__sessionHasKey(CGIProperty.DOWNLOAD)) trigger_url = false;
						else if (__sessionHasKey(CGIProperty.DELAY) && (__cgiSession[CGIProperty.DELAY] < 0) ) trigger_url = false;
						
						__cgiTask(! trigger_url);
					}
					
				}
			}
			catch(e:*)
			{
				RunClass.MovieMasher['msg'](this + '.__xmlLoaded', e);
			}
		}
		
		private var __request:S3PostRequest;
		private var __cgiSession:Object;
		private var __delayInterval:Timer;
		private var __fileReference:FileReference;
		private var __loader:IDataFetcher;
		private var __mash:IMash;
		private var __progress:Number = 0;
		private var __setting:Boolean = false;
		private var __choosing:Boolean = false;
		private var __status:String = '';
		
		
		
	}
}