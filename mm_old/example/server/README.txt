
Server Example Read Me
----------------------

This example deployment is qualitatively different from the others in that it utilizes the PHP
classes in private/MovieMasher to preprocess uploaded assets and render the edited mash back into a
true video file available for download. It builds extensively on the 'save' and 'upload' examples,
adding an authentication mechanism and maintaining different content for each user. Any username and
password combination is accepted. 

A 'Mash' tab has been added above the media browser to display previously created mashes, and
buttons have been added below it to enable loading of a selected mash and downloading of uploaded
assets or rendered videos. The timeline has new buttons for reverting, rendering and creating a new
mash. Progress bars are now attached to the upload and render buttons, to track their transcoding
operations. Note the more complex implementation of control_search.xml and control_save.xml, as well
as the many scripts added to the media/php directory.

The PHP classes used by the scripts in this example behave differently depending on the options set
in the private/MovieMasher.xml configuration file. The two most crucial options are 'Client' and
'File' which determine which one of the implementation classes under private/MovieMasher are
instanced in order to handle transcoding operations and media storage functions. The four supported
combinations of these two options are described in the online documentation, along with the network
architectures they enable:

http://www.moviemasher.com/doc/?page=mmserver

Please also see additional installation notes in the README-[Client]_[File].txt file that
corresponds to the desired network architecture. Note that it's expected that at least one instance
of the Movie Masher Server AMI is running in Amazon's Elastic Compute Cloud (EC2) web service. It is
possible (but quite difficult!) to build your own server like the one available in EC2. This task is
made significantly easier by first exploring a running server though, so EC2 is still the best
starting point:

http://www.moviemasher.com/server/

Extend this example by building a more complete content management system around it. Start by
rewritting the three functions in the private/MovieMasher/lib/authutils.php file, perhaps utilizing
sessions instead of HTTP authentication. 

server:
	index.php: authenticates and uses swfobject to pull in Movie Masher applet
	media:
		php:
			addmedia.php: adds tag for stored media to media.xml
			choose.php: handles initial screening of uploads
			decode.php: initiates mash decoding (rendering) job
			decoded.php: receives decoded file from server
			decoding.php: monitors a decoding job
			done.php: receives notice when decode job completed successfully by server
			encode.php: initiates media encoding (preprocessing) job
			encoded.php: receives encoded file from server
			encoding.php: monitors an encoding job
			error.php: receives notice when server encounters an error while processing job
			media.php: searches through media*.xml files for media tags
			progress.php: receives progress data for SQS jobs
			save.php: receives posted mash XML which is written as is to mash.xml
			upload.php: handles initial transfer of media file
		user: empty at first, see below for example of structure after uploading
		xml:
			config.xml: loads the rest of the XML files
			control_nav_module.xml: contains control tags for modular media tabs
			control_nav.xml: contains control tags for media tabs and embeds control_nav_module.php
			control_save.xml: contains the control tag for the Movie Masher logo
			control_search.xml: contains the control tags for the browser search field
			handler.xml: contains handler tags for media types
			mash.xml: contains mash tag with default aspect ratio and label
			media_effect.xml: contains media tags of type effect
			media_transition.xml: contains media tags of type transition
			media.xml: contains media tags of other types
			option_font.xml: contains option tags specifying fonts
			panel.xml: contains panels tags defining interface layout
			source.xml: contains source tag pointing to media.php
	README.txt: this file
	VERSION.txt: specifies the version of Movie Masher this example was bundled with

This example deployment requires the installation steps outlined in the INSTALL.txt file, plus the
following:

* Get an Account at Amazon.com, and sign up for their EC2 service:
	http://aws.amazon.com/ec2/
* Use ElasticFox, command line tools or Amazon's console to launch a server instance:
	https://console.aws.amazon.com/
* You should launch the version of the server that is indicated in private/VERSION.txt
* Copy the /private directory to a directory OUTSIDE your web server root
* Place this directory path into PHP's include_path configuration option somehow
* Change the file permissions for the following paths such that the web server process can write:
	/private/MovieMasherLog/
	media/user/
	media/xml/mash.xml
	media/xml/media.xml
* Follow steps in README-[Client]_[File].txt file that corresponds to desired network architecture
* Install the following PEAR modules, if not already installed:
	HTTP
	MIME_Type
If this is impractical, the following utility scripts can be rewritten to utilize other libraries:
	/private/MovieMasher/lib/dateutils.php
	/private/MovieMasher/lib/mimeutils.php
	
After running the example and uploading a video, audio and image file the media directory would
look something like this:

server:
	media:
		user: 
			USER_ID: folder will be named after the username provided during authentication
				0459e2bc2027ef5a2b61a19ca11d8b84: unique ID for this Quicktime video file
					media: low resolution encodings used in editor
						160x120x12: width x height x fps
							01.jpg
							...
							40.jpg
						audio.mp3: soundtrack
						audio.png: waveform graphic
					media.mov: original asset used by renderer
					meta: information about the asset
						audio.txt: will not be empty() if audio track exists (derived from ffmpeg.txt)
						cached.txt: contains date/time the asset was cached
						Content-Type.txt: contains the MIME type of the original (derived from http.txt)
						dimensions.txt: contains width x height of original (derived from ffmpeg.txt)
						duration.txt: contains float representing seconds (derived from ffmpeg.txt)
						extension.txt: file extension of original used to determine path from ID
						ffmpeg.txt: the output of ffmpeg -i original
						fps.txt: the frames per second of original (derived from ffmpeg.txt)
						http.txt: HTTP Response headers retrieved when fetching url
						label.txt: the original file name when uploaded
						type.txt: audio, image or video (derived from Content-Type.txt)
						url.txt: the location of the original asset when fetched
				5300a90dbb71b7a36da74d98fdb4a713: unique ID for this MP3 audio file
					media: low resolution encodings used in editor
						audio.mp3: 
						audio.png: waveform graphic
					media.mp3: original asset used by renderer
					meta: information about the asset
						audio.txt: will not be empty() since audio track exists (derived from ffmpeg.txt)
						cached.txt: contains date/time the asset was cached
						duration.txt: contains float representing seconds (derived from ffmpeg.txt)
						extension.txt: file extension of original used to determine path from ID
						ffmpeg.txt: the output of ffmpeg -i original
						http.txt: HTTP Response headers retrieved when fetching url
						label.txt: the original file name when uploaded
						type.txt: audio, image or video (derived from Content-Type.txt)
						url.txt: the location of the original asset when fetched
				ebf80bda1d8080028458aa1605eedc4f: unique ID for this PNG image file
					media: low resolution encodings used in editor
						160x120x1:
							0.png
					media.png: original asset used by renderer
					meta: information about the asset
						cached.txt: contains date/time the asset was cached
						Content-Type.txt: contains the MIME type of the original (derived from http.txt)
						dimensions.txt: contains width x height of original (derived from ffmpeg.txt)
						extension.txt: file extension of original used to determine path from ID
						http.txt: HTTP Response headers retrieved when fetching url
						label.txt: the original file name when uploaded
						type.txt: audio, image or video (derived from Content-Type.txt)
						url.txt: the location of the original asset when fetched
						