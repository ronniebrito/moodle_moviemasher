Server-side stream recording with Red5 by Carl Sziebert
http://sziebert.net/posts/server-side-stream-recording-updated/

-----

This simple application demonstrates the server-side stream recording feature built into Red5. It utilizes the latest
Red5 build direct from their continuous build server. In order to run the application, you'll need to have Ant
(http://ant.apache.org) and Red5 (http://code.google.com/p/red5) installed. To get started, run the default ant command
(ant or ant compile) and deploy the application to Red5.

-----

What's new in this version

1. Updated to use the latest Red5 (0.9.1) build. JDK6 is now required.
2. Refactored the StreamManager class to align with the correct API.
3. Simplified the Ant/Ivy configuration files.