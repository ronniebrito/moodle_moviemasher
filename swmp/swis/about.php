<?php
//setup language
//needs to be refactored...
$lang='en';
include 'iswa.i18n.php';
include 'iswa.i18n.sym.php';
$msg = array_merge($messages[$lang],$symNames[$lang]);
include 'swis.i18n.php';
$msg = array_merge($messages[$lang],$msg);

//add libraries
include "bsw.php";

//get input
$bsw = bsw2spaced($_REQUEST['bsw']);

//start page
?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link href="index.css" rel="stylesheet" type="text/css" media="all">

<?php
echo '<title>' . $msg['swis_desc'] . '</title></head>' . "\n";
echo '<body>';

include 'command.php';
echo '<div class="detail">';
$subhead = $msg['swis_about'];
include 'header.php';
//page header

?>

<h1>The Open Standards of SignWriting</h1>
<p>There is an emerging open standard for SignWriting that will reach an international group. A new standard will empower people throughout the world, in all countries, for all sign languages. As the groups are enabled, they will grow and their culture will continue to flourish, but in new and amazing ways.

<p>Video is not text. The open standards of SignWriting establish sign language as text. The open standards cover the alphabet, data model, and user interface. Neither the individual sign languages, nor their respective text corpora are covered by the open standards.

<p>The creator of the SignWriting script, Valerie Sutton, started her 501c3 non-profit over 30 years ago.  In 2003, Stephen Slevinski became interested in SignWriting.  The Sutton-Slevinski Collaboration started in 2004.  

<p>In 2007, Valerie and Steve decided to develop open standards based on their work in 3 areas: alphabet, data model, and user interface. The International SignWriting Alphabet was initially completed in 2008. The ISWA was updated in 2010 and is available under the Open Font License.

<p>The data model is documented with a downloadable HTML reference guide. The data can be encoded in BSW (open standard) or UTF-8(compatible with Unicode). The user interface is illustrated in this SignWriting Image Server. The software is released under the GPL 3. The standards documents are released under Creative Commons (by-sa).

<p>Sign language is vastly different than spoken language. Instead of the sequential sounds of the voice, there is a 3 dimensional space with simultaneous action. The SignWriting script captures the essence of sign language as text. It is very easy to start reading and writing with paper.

<p>Bringing the SignWriting script to the computer is entirely different. Sign language to text is the first step. Text to binary character data is the next. Binary SignWriting established the x-ISWA-2010 as a 12 bit character set which can be represented with 3 bytes of BSW or 4 bytes of UTF-8 data per character.

<p>SignWriting is a spatial writing system that combines a limited number of symbols on a 2 dimensional canvas. Each word is a cluster of symbols that are read as a single unit and represented by characters with coordinate data.

<p>Currently, Unicode can only simulate a spatial nature with superscripts and subscripts and complicated rules for combining sequential characters.

<p>We are encoding the script and not the specific language. SignWriting can be used for all sign languages without modification.

<p>Our standards are used today and they are practical. 

<h2>About</h2>
<p>The primary purpose of the SignWriting Image Server is to display and edit SignWriting images fast with a simple installation.  
The secondary purpose is to document and demonstrate sign language as text.  
SWIS requires a web server with PHP and the GD graphics library.
<p>The vision of the SignWriting Image Server is to provide tools to view and edit Binary SignWriting.  
SWIS can and should be used to generate test data, verify image display, and model behavior for implementations with other programming languages on any platform. 

<h2>ISWA</h2>
<p>The International SignWriting Alphabet 2010 is the latest symbol set for SignWriting.  It is documented in this package.

<h2>BSW</h2>
<p>Binary SignWriting is a script encoding model for SignWriting.  It is documented in this package.

<br><br><hr>
<h1>Images</h1>
<h2>Symbols</h2>
The individual symbols of SignWriting can be viewed.  The size and color can be changed.

<h2>Signs</h2>
Separate images for each sign can be viewed.  The size, color, and background can be changed.

<h2>Columns</h2>
Entire column images can be viewed.  The size, color, and background can be changed.

<br><br><hr>
<h1>Editors</h1>

<h2>SignMaker</h2>
SignMaker is used for editing individual signs.

<h2>SignText</h2>
SignText is used for editing entire sign texts.

</div>
<br clear="all"><br>
<hr>
<?php include 'footer.php';?>
<hr><br>
<center>
Dedicated to my wife Sonia, to Valerie Sutton and to the entire
<a href="http://www.signwriting.org/forums/swlist/">SignWriting List</a>:<br>
their support and encouragement has always been there.<br>
Dedicated to all lovers of the written word,<br>
especially Mortimer J. Adler who taught me how to read a book.<br>
There have been too many other teachers and friends to name them all.
</center>
</body>
</html>﻿﻿﻿﻿﻿﻿
