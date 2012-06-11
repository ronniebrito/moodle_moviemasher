package net.sziebert.tutorials.broadcast {
	
	import fl.controls.Button;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import net.sziebert.tutorials.Runtime;
	
	public class Broadcast extends Sprite {
		
		private var button:Button;
		private var cam:Camera;
		private var runtime:Runtime;
		private var video:Video;
		private var fileName:String;
		
		public function Broadcast():void {
			trace("Starting Broadcast application...");
			
			fileName= new String();
			fileName = root.loaderInfo.parameters.userid + "/" + root.loaderInfo.parameters.taskid;

			//trace("abacata"+ fileName);
			fileName = "fixo";



			
			runtime = Runtime.getInstance();
			stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onResize);
			createChildren();
			initConnection();
		}
		
		/* ----- Utility functions ----- */
		
		private function createChildren():void {
			// Configure the user's camera.
			cam = Camera.getCamera();
			cam.setQuality(144000, 85);
			cam.setMode(320, 240, 15);
			cam.setKeyFrameInterval(60);
			// Setup the video loopback.
			video = new Video();
			video.attachCamera(cam);
			addChild(video);
			// Create the 'Record' button.
			button = new Button();
			button.label = "Record";
			button.addEventListener(MouseEvent.CLICK, onClick);
			addChild(button);
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
			// Position the button.
			button.move(18, 268);
			button.setSize(320, 22);
			button.enabled = false;
		}
		
		private function initConnection():void {
			// Create the new connection object.
			runtime.conn = new NetConnection();
			runtime.conn.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            runtime.conn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			trace("Connecting to Red5...");
            runtime.conn.connect("rtmp://rocha.ava.ufsc.br/recorder/"+fileName, true );

		}
		
		private function publish():void {
			if (runtime.conn.connected) {
				runtime.stream = new NetStream(runtime.conn);
				runtime.stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            	runtime.stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
				runtime.stream.attachCamera(cam);
				runtime.stream.publish("hostStream", "live");
			}
		}
		
		/* ----- Event handlers ----- */
		
		private function onResize(event:Event):void {
			setSize(stage.stageWidth, stage.stageHeight);
		}
		
		private function onClick(event:MouseEvent):void {
			var button:Button = event.target as Button;
			 

			// Record the stream by triggering a server event.
			if (button.label == "Record") {
				// Tell the remote server to start recording.
				runtime.conn.call("streamManager.recordShow", null);
				// Re-label the button.
				button.label = "Stop";
			// Stop recording the stream.
			} else if (button.label == "Stop") {
				// Tell the remote server to stop recording.
				runtime.conn.call("streamManager.stopRecordingShow", null);
				// Re-label the button.
				button.label = "Record";
			}
		}
		
		private function onNetStatus(event:NetStatusEvent):void {
			trace("onNetStatus: " + event.info.code);
			//trace( event.info.application );
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
					trace("Connection attempt successful.");
					publish();
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
				case "NetStream.Publish.Start":
					trace("Publishing");
					button.enabled = true;
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