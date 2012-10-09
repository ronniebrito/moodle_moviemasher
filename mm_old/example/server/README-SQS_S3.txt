
SQS-S3 Example Read Me
----------------------

Please see the README.txt file in the same directory as this file for prerequisite information and
installation steps. Addtional explanation is also available in the online documentation:

http://www.moviemasher.com/doc/?page=mmserver&sub=sqs_s3

To install for SQS S3 deployments:

* Make sure your Amazon account is signed up for S3 and SQS
* Create the SQS queue URL (referenced below as MY_QUEUE_URL)
* Create the S3 bucket (referenced below as MY_BUCKET_NAME)
* Place a crossdomain.xml file in the bucket and make its permissions 'public read'
* Servers should be launched with user data setting the following options:
	AWSAccessKeyID
	AWSSecretAccessKey
	SQSQueueURLReceive (MY_QUEUE_URL)
* Set the Client and File options in private/MovieMasher.xml to SQS and S3
* Set the S3Bucket option in private/MovieMasher.xml to MY_BUCKET_NAME
* Set the HostMedia option in private/MovieMasher.xml to MY_BUCKET_NAME.s3.amazonaws.com
* Set the AWSAccessKeyID and AWSSecretAccessKey options in private/MovieMasher.xml 
* Set the SQSQueueURLSend option in private/MovieMasher.xml to MY_QUEUE_URL

* Install the following PHP module, if not already installed:
	openssl
If this is impractical, the following script can be rewritten to utilize other libraries:
	/private/MovieMasher/lib/cryptutils.php
* Install the following PHP library to private/, if not already installed:
	Zend 
If this is impractical, the following scripts can be rewritten to utilize other libraries:
	/private/MovieMasher/lib/s3utils.php
	/private/MovieMasher/lib/sqsutils.php
