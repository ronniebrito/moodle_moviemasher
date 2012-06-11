
YouTube Example Read Me
-----------------------

This example deployment is essentially the same as the 'static' example, except the browser control
contains a YouTube tab instead of tabs for video, audio and images. Note the difference in the
control_nav.xml and source.xml files. The later references a custom source module called
YouTubeSource which makes requests directly to the YouTube API. There is also a custom handler
called YouTubeHandler defined in handler.xml, which pulls in YouTube's chromelss player for display
of the video.

Extend this example by including your YouTube API ID and changing or adding attributes of the source
tag in source.xml, using their parameter naming conventions in most cases. One might also subclass
YouTubeSource or its parent, RemoteSource, to develop a custom module that accesses another public
API. Or subclass YouTubeHandler or its parent, FLVHandler, to develop a custom module that displays
a different player.

Warning: this example is just barely functional, especially with longer videos. And attempts to
render YouTube content will produce an error, since this seems to step outside the limits of their
terms of service. 

youtube:
	index.html: uses swfobject to pull in Movie Masher applet
	media:
		xml:
			config.xml: loads the rest of the XML files
			control_nav_module.xml: contains control tags for modular media tabs
			control_nav.xml: contains control tags for YouTube tab and embeds control_nav_module.php
			control_save.xml: contains the control tag for the Movie Masher logo
			control_search.xml: contains the control tags for the browser search field
			handler.xml: contains handler tags for media types, including YouTubeHandler
			mash.xml: contains mash tag with default aspect ratio and label
			media_effect.xml: contains media tags of type effect
			media_theme.xml: contains media tags of type theme
			media_transition.xml: contains media tags of type transition
			option_font.xml: contains option tags specifying fonts
			panel.xml: contains panels tags defining interface layout
			source_module.xml: contains source tags for modular media
			source.xml: contains source tag for YouTubeSource
	README.txt: this file
	VERSION.txt: specifies the version of Movie Masher this example was bundled with

This example deployment requires no installation steps beyond those that are outlined in the
INSTALL.txt file, and does NOT require PHP. 
