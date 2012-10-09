3.1.XX -> 3.2.XX
----------------

* Transcoding functionality moved from distribution to new Movie Masher Transcoder AMI

* 'server' example now known as 'transcode' - updated to work with new Transcoder API

* Configuration file private/MovieMasher.xml replaced by moviemasher.ini

* Only 'REST' or 'SQS' now supported for Client configuration option

* Only 'HTTP' or 'Local' now supported for File configuration option (S3 provided by HTTP)

* Player and Browser controls need to have id specifically set

* Player now requires 'source' attribute - probably 'mash'

* Example index pages now require video_width and video_height keys for flashvarsObj object

* CGI 'mash' attribute should now be 'player.mash' or other mash object

* Bender control tag 'shader' attribute changed to 'source' 

* Moved bender .pbj files to moviemasher/com/moviemasher/pbj

* The following classes have been migrated to the Player SWF file:
	com.moviemasher.handler.MP3Handler
	com.moviemasher.source.RemoteSource
	com.moviemasher.display.Tooltip
	
* The following classes have been migrated to the Editor SWF file:
	com.moviemasher.display.Increment

* 'tie' control attribute removed - use full references in 'pattern' instead, or just 
remove since controls like Scrollbar, Ruler, Timeline no longer need them

* Flash CS5.5 now required to rebuild FLA files

* Previews use over* attributes instead of sel* for selected box properties 

* Curve library item removed from library in skin file - use the following instead:
	color='333333' grad='40' angle='270' curve='5'

* Tooltip class variable on frame one of custom skin SWFs should be removed, if found

* Increment library symbol in skin SWF should be removed

* Fullscreen icons moved from library to timeline in skin file



