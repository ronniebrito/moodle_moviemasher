
REST-S3 Example Read Me
-----------------------

Please see the README.txt file in the same directory as this file for prerequisite information and
installation steps. Addtional explanation is also available in the online documentation:

http://www.moviemasher.com/doc/?page=mmserver&sub=rest_s3

To install for REST S3 deployments:

* Make sure your Amazon account is signed up for S3
* Create the S3 bucket (referenced below as MY_BUCKET_NAME)
* Place a crossdomain.xml file in the bucket and make its permissions 'public read'
* Make the following adjustments to options within the private/moviemasher.ini file:
	Set Client and File to REST and S3
	Set RESTEndPoint to the Transcoder instance Public DNS Name 
	Set S3Bucket to MY_BUCKET_NAME
	Set HostMedia to MY_BUCKET_NAME.s3.amazonaws.com
	
* Transcoder must be launched in a security group that allows access on port 80 or 443
* Transcoder must be launched with user data including the following (see README-Transcoder.txt):
	AWS Access Key ID
	AWS Secret Access Key
