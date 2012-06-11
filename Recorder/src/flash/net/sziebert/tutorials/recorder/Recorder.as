package net.sziebert.tutorials.recorder {
	
	import fl.controls.Button;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.LoaderInfo
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
	import flash.net.*;
	
	import flash.external.ExternalInterface;

	
	import net.sziebert.tutorials.Runtime;
	import fl.motion.Color;
	
	public class Recorder extends Sprite {
		
		private var button:Button;
		private var cam:Camera;
		private var runtime:Runtime;
		private var video:Video;
		private var video2:Video;
		private var id:String;
		private var tf:TextField  = new TextField();
		
		public function Recorder():void {
			trace("Starting Recorder application...");
			id= new String();
			//id = root.loaderInfo.parameters.userid + "/" + root.loaderInfo.parameters.taskid;
			id = root.loaderInfo.parameters.id;			
			runtime = Runtime.getInstance();			
			stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
			createChildren();
			ExternalInterface.addCallback("startRecording", startRecording);
			ExternalInterface.addCallback("stopRecording", stopRecording);

			this.btnRecorte.addEventListener(MouseEvent.CLICK,makeVideoRecorte);
			this.btnInteiro.addEventListener(MouseEvent.CLICK, makeVideoInteiro);
			this.btnWide.addEventListener(MouseEvent.CLICK, makeVideoWide);


var myFormat:TextFormat = new TextFormat();
myFormat.size = 15;
myFormat.align = TextFormatAlign.CENTER;
myFormat.color = 0xFF00FF;
tf.defaultTextFormat = myFormat;
//myText.embedFonts = true;
//myText.antiAliasType = AntiAliasType.ADVANCED;
tf.text = "The quick brown fox jumps over the lazy dog";

tf.border = true;
tf.wordWrap = true;
tf.width = 150;
tf.height = 40;
tf.x = 180;
tf.y = 310;

tf.text = "eh nois";
//addChild(tf);

//var pageURL:String = ExternalInterface.call('window.location.href.toString');
var myUrl:String = unescape(LoaderInfo(this.root.loaderInfo).url);
tf.text = myUrl; 

}
		
		/* ----- Utility functions ----- */
		
		private function createChildren():void {
			// Configure the user's camera.
			
			cam = Camera.getCamera();
			cam.setQuality(0,80);
			cam.setKeyFrameInterval(10);
			
			// Setup the video loopback.
			video = new Video();
			video.attachCamera(cam);
			video.x = 0;
			video.y = 0;
			setVideoSize(640,480);
			addChild(video);
		}
		
		public function makeVideoRecorte(e:Event):void{
			setVideoSize(480,540);
		}
		
		public function makeVideoInteiro(e:Event):void{
			setVideoSize(640,480);			
		}
		
		public function makeVideoWide(e:Event):void{
			setVideoSize(640,360);
		}
		
		public function setVideoSize(w:int, h:int):void{
			this.video.width = w/2;
			this.video.height = h/2;
			this.videoPreviewer.width = w/2;
			this.videoPreviewer.height = h/2; 
			this.video.x = 0;
			this.videoPreviewer.x = 0;
			this.cam.setMode(w,h,25, false);			
		}
		
		public function initConnection():void {
			// Create the new connection object.
			runtime.conn = new NetConnection();
			runtime.conn.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            runtime.conn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			//trace("Connecting to Red5...@"+ "rtmp://rocha.ava.ufsc.br/recorder/"+id);
          //  runtime.conn.connect("rtmp://rocha.ava.ufsc.br/recorder", true );
		    runtime.conn.connect("rtmp://localhost/recorder", true );
		}
		
		public function publish():void {
			if (runtime.conn.connected) {
				runtime.stream = new NetStream(runtime.conn);				
				runtime.stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            	runtime.stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
				
				//runtime.stream.publish(fileName, "record");
				runtime.stream.publish(id, "record");
				runtime.stream.attachCamera(cam);
				
				// Tell the remote server to start recording.
				runtime.conn.call("streamManager.iniciarGravacao", new Responder(CallBackStart),  id);
				
			}
		}
		
		
		public function startRecording(){				
				initConnection();				
		}
		
		public function stopRecording(){
			trace("Stop recording the stream" );				
				// Tell the remote server to stop recording.
				runtime.conn.call("streamManager.pararGravacao", new Responder(CallBackStop), id);
				runtime.stream.close();
		}
		
				
		
public function CallBackStart(result:Array)
{

}

public function CallBackStop(result:Array)
{
	
	var myUrl:String = unescape(LoaderInfo(this.root.loaderInfo).url);

	
	//var url:String = "http://www.libras.ufsc.br/hiperlab/avalibras/moodle/mod/moviemasher/recorderCallback?id=" + this.id;
	
	//http://150.162.41.4/~ronnie/etica/moodle/mod/moviemasher/Recorder/web/recorder.swf
	
	var url:String = myUrl + "/../../../recorderCallback?id=" + this.id;
	tf.text = myUrl; 
	
	// id = mash id 
	 var myURL:URLRequest = new URLRequest(url);
     var myLoader = new URLLoader();	
	myLoader.addEventListener(Event.COMPLETE, onLoaded);
 	myLoader.load(myURL);	 
	
	
		 
}
private function onLoaded(e:Event):void {	
		//this.tf.text = e.target.data+"?nocache=XUNXO"+new Date().getTime()+".flv";				
		this.videoPreviewer.load(e.target.data);		
}

		
		public function onNetStatus(event:NetStatusEvent):void {
			trace("onNetStatus: " + event.info.code);
			tf.text = event.info.code;
			//trace( event.info.application );
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
					trace("Connection attempt successful.");
					tf.text = "Conectado"; 
					publish();		
					break;
				case "NetConnection.Connect.Rejected":
					trace("Connection attempt rejected.");
					tf.text = "Conexao rejeitada"; 
					break;
				case "NetConnection.Connect.Closed":
					trace("Connection closed.");
					tf.text = "Conexao fechada"; 
					break;
				case "NetConnection.Connect.Failed":
					trace("Connection failure.");
					tf.text = "ERRO DE CONEXAO"; 
					break;
				case "NetStream.Publish.Start":
					trace("Publishing");
					tf.text = "Publicando"; 
					//button.enabled = true;
					break;					
				case "NetStream.Record.Start":
					trace("Gravando");
					tf.text = "Gravando"; 
					break;
				case "NetStream.Play.Start":
					trace("Subscribed to stream.");
					tf.text = "Tocando"; 
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