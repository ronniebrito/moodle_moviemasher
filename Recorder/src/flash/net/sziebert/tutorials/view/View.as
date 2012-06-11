package net.sziebert.tutorials.view {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import net.sziebert.tutorials.Runtime;
	
	public class View extends Sprite {
		
		private var runtime:Runtime;
		private var video:Video;
		private var fileName:String;
		
		public function View():void {
			trace("Starting View application...");
			fileName= new String();
			fileName = root.loaderInfo.parameters.userid + "/" + root.loaderInfo.parameters.taskid;

			//trace("abacata"+ fileName);
			fileName = "fixo2";



			runtime = Runtime.getInstance();
			stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onResize);
			createChildren();
			initConnection();
		}
		
		/* ----- Utility functions ----- */
		
		private function createChildren():void {
			// Setup the video playback.
			video = new Video();
			addChild(video);
			// Remove the avatar.
			removeChildAt(0);
			// Size the elements.
			setSize(stage.stageWidth, stage.stageHeight);
		}
		
		private function setSize(w:Number, h:Number):void {
			// Position the video element.
			video.x = 18;
			video.y = 18;
			video.width = 320;
			video.height = 240;
		}
		
		private function initConnection():void {
			// Create the new connection object.
			runtime.conn = new NetConnection();
			runtime.conn.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            runtime.conn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			trace("Connecting to Red5...");
            runtime.conn.connect("rtmp://rocha.ava.ufsc.br/recorder/", true );
		}
		
		private function subscribe():void {
			if (runtime.conn.connected) {
				runtime.stream = new NetStream(runtime.conn);
				runtime.stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            	runtime.stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
				//runtime.stream.play("hostStream");
				runtime.stream.play("fixo2", 0, -1, true);
			}
		}
		
		/* ----- Event handlers ----- */
		
		private function onResize(event:Event):void {
			setSize(stage.stageWidth, stage.stageHeight);
		}
		
		private function onNetStatus(event:NetStatusEvent):void {
			trace("onNetStatus: " + event.info.code);
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
					trace("Connection attempt successful.");
					subscribe();
					break;
				case "NetConnection.Connect.Rejected":
					trace("Connection attempt rejected.");
					break;
				case "NetConnection.Connect.Closed":
					trace("Connection closed.");
					break;
				case "NetConnection.Connect.Failed":
					trace("Connection failure.");
					break;					
				case "NetStream.Play.Start":
					trace("Subscribed to stream.");
					video.attachNetStream(runtime.stream);
					break;
				case "NetStream.Buffer.Full":
					trace("Buffer cheio.");
					break;					
				case "NetStream.Buffer.Empty":
					trace("Buffer vazio.");
					break;
            }
        }

        private function onSecurityError(event:SecurityErrorEvent):void {
            trace("onSecurityError: " + event);
        }
		
		private function onAsyncError(event:AsyncErrorEvent):void {
			trace("onAsyncError: " + event);
		}
	}
}