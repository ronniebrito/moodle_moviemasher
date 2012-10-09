
File Structure Read Me
----------------------

After running the example and uploading a video, audio and image file the media directory 
would look something like this:

transcoder:
	media:
		user: 
			USER_ID: folder will be named after the username provided during authentication
				0459e2bc2027ef5a2b61a19ca11d8b84: unique ID for this Quicktime video file
					160x120x12: low resolution encodings used in editor (width x height x fps)
						01.jpg
						...
						40.jpg
					audio.mp3: soundtrack
					audio.png: waveform graphic
					original.mov: original asset used by renderer
					meta: information about the asset
						audio.txt: will not be empty() if audio track exists (derived from ffmpeg.txt)
						dimensions.txt: contains width x height of original (derived from ffmpeg.txt)
						duration.txt: contains float representing seconds (derived from ffmpeg.txt)
						extension.txt: file extension of original used to determine path from ID
						label.txt: the original file name when uploaded
						type.txt: audio, image or video (derived from Content-Type.txt)
				5300a90dbb71b7a36da74d98fdb4a713: unique ID for this MP3 audio file
					audio.mp3: low resolution encoding used in editor
					audio.png: waveform graphic
					original.mp3: original asset used by renderer
					meta: information about the asset
						audio.txt: will not be empty() since audio track exists (derived from ffmpeg.txt)
						duration.txt: contains float representing seconds (derived from ffmpeg.txt)
						extension.txt: file extension of original used to determine path from ID
						label.txt: the original file name when uploaded
						type.txt: audio, image or video (derived from Content-Type.txt)
				ebf80bda1d8080028458aa1605eedc4f: unique ID for this PNG image file
					160x120x1: low resolution encodings used in editor
						0.png
					original.png: original asset used by renderer
					meta: information about the asset
						dimensions.txt: contains width x height of original (derived from ffmpeg.txt)
						extension.txt: file extension of original used to determine path from ID
						label.txt: the original file name when uploaded
						type.txt: audio, image or video (derived from Content-Type.txt)
						