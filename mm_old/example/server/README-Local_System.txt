
Local-System Example Read Me
----------------------------

Please see the README.txt file in the same directory as this file for prerequisite information and
installation steps. Addtional explanation is also available in the online documentation:

http://www.moviemasher.com/doc/?page=mmserver&sub=local_system

To install for Local System deployments:

* Launch the Movie Masher Server AMI in Amazon's EC2, to see a working example
* Server should be launched with user data setting the following option:
	PasswordFTP
* Server should be launched in a Security Group with Port 21 and 22 open (12000-12100 if using PASV)
* Access the server instance at its Public DNS Name via FTP using username 'moviemasher'
* See the options that have been automatically set in private/MovieMasher.xml
* Explore the software installed on the server in the following directories:
	www/installed (archives)
	installed/ (actual builds)
* Explore the CGI scripts in api/
* Explore the shell scripts in scripts/
* Access the server instance at its Public DNS Name via FTP using username 'ubuntu' to access root
* Explore the web server configuration to see how CGI scripts are called:
	/etc/apache2/sites-available/default
	/etc/apache2/sites-available/ssl
* Explore the links in /etc/init.d/ to see how shell scripts are launched
* Install the following applications and library dependencies or their equivalents for your OS:
	convert and required libraries
	ecasound and required libraries
	ffmpeg and required libraries
	flashplayer and required libraries
	xvfb-run and an X Windows implementation
* Create a daemon like script/init.d/moviemasher that launches script/moviemasher
* Copy and adjust scripts in api/ to handle posting of frames and errors from flashplayer
* Post questions to the Movie Masher Forums on SourceForge