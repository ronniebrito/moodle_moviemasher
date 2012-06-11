package net.sziebert.tutorials.player {
	
	import fl.controls.Button;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.Responder;
	import flash.utils.Timer;
	import flash.text.*;
	
	import net.sziebert.tutorials.Runtime;
	
	public class Player extends Sprite {
		
		private var button:Button;
		private var runtime:Runtime;
		private var video:Video;
		private var fileName:String;
		
		public function Player():void {
			trace("Starting Player application...");
			
			fileName= new String();
			fileName = root.loaderInfo.parameters.userid + "/" + root.loaderInfo.parameters.taskid;
			fileName = "fixo2";
			
			runtime = Runtime.getInstance();
			stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onResize);
			createChildren();			
			initConnection();
		}
		
		/* ----- Utility functions ----- */
		
		public function createChildren():void {			
			// Setup the video loopback.
			video = new Video();
			addChild(video);		
			// Create the 'Play' button.
			button = new Button();
			button.label = "Play";
			button.enabled = false;
			button.addEventListener(MouseEvent.CLICK, onClickPlay);
			addChild(button);
			// Remove the avatar.
			removeChildAt(0);
			// Size the elements.			
			setSize(stage.stageWidth, stage.stageHeight);
		}
		
		public function setSize(w:Number, h:Number):void {
			// Position the video element.
			video.x = 18;
			video.y = 18;
			video.width = 320;
			video.height = 240;
			// Position the button.
			button.move(18, 268);
			button.setSize(320, 22);
		}
		
		public function initConnection():void {
			// Create the new connection object.
			runtime.conn = new NetConnection();
			runtime.conn.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            runtime.conn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			trace("Connecting to Red5...@"+ "rtmp://rocha.ava.ufsc.br/recorder/"+fileName);
            runtime.conn.connect("rtmp://rocha.ava.ufsc.br/recorder", true );

		}
				
		
		public function subscribe():void {
			
				trace("subscribing 0" + fileName);
			if (runtime.conn.connected) {
				trace("subscribing" + fileName);
				runtime.stream = new NetStream(runtime.conn);			
				runtime.stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            	runtime.stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);			
				runtime.stream.play(fileName,0);
				
			}
		}
		
		/* ----- Event handlers ----- */
		
		public function onResize(event:Event):void {
			setSize(stage.stageWidth, stage.stageHeight);
		}
		

		
		public function onClickPlay(event:MouseEvent):void {
			var button:Button = event.target as Button;
			 trace("botao clicado");
			
			// Record the stream by triggering a server event.
			if (button.label == "Play") {						
				subscribe();	
				// Re-label the button.
				button.label = "Stop";				
				
			// Stop recording the stream.
			} else if (button.label == "Stop") {				
				// Re-label the button.
				button.label = "Play";
				runtime.stream.pause();
			}
		}
		
		
		
		public function onNetStatus(event:NetStatusEvent):void {
			trace("onNetStatus: " + event.info.code);
			trace( event.info.application );
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
					trace("Connection attempt successful.");									
					button.enabled = true;
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
            }
        }

        public function onSecurityError(event:SecurityErrorEvent):void {
            trace("onSecurityError: " + event);
        }
		
		public function onAsyncError(event:AsyncErrorEvent):void {
			trace("onAsyncError: " + event);
		}
	}
}