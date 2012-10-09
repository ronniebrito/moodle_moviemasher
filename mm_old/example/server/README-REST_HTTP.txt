

REST-HTTP Example Read Me
-------------------------

Please see the README.txt file in the same directory as this file for prerequisite information and
installation steps. Addtional explanation is also available in the online documentation:

http://www.moviemasher.com/doc/?page=mmserver&sub=rest_http

To install for REST HTTP deployments:

* Server should be launched in a security group that allows access on port 80 and 443
* Server should be launched with a keypair, and the private key is needed to sign REST requests
* Copy the private key to your server, and make sure it's readable by the web server process
* Set the Client and File options in private/MovieMasher.xml to REST and HTTP
* Set the RESTKeyPrivate option in private/MovieMasher.xml to the path to the private key
* Set the RESTEndPoint option in private/MovieMasher.xml to the Public DNS Name of your EC2 instance
* Configure PHP5 upload related options - see http://php.net/file_upload
* Make sure you have an allowing crossdomain.xml file at the top tier of your web root directory
* Install the following PHP modules, if not already installed:
	curl
	openssl
If this is impractical, the following scripts can be rewritten to utilize other libraries:
	/private/MovieMasher/lib/cryptutils.php
	/private/MovieMasher/lib/urlutils.php
* Install the following PEAR module, if not already installed:
	Archive_Tar
If this is impractical, the following script can be rewritten to utilize other libraries:
	/private/MovieMasher/lib/archiveutils.php

