<html>
<head>
<script type="text/javascript">

var bsw = "new bsw";

var content = '<moviemasher><clip type="effect" id="signboxeffect" track="1" start="93" backcolor="FFFFFF" fade="" scale="25,100"  bsw="0fb32a38c3924f54f5" label="Escrita de Sinais" forecolor="" lengthseconds="5" position="100,90" fill="" length="50" size="" padding="" backalpha="100">    <clip type="image" id="0fb32a38c3924f54f5"swimagebsw="0fb32a38c3924f54f5" track="-1" audio="0" fill="stretch" length="50" label="Logo" lengthseconds="5"/>  </clip><media group="image" type="image" id="0fb32a38c3924f54f5" label="SW" url="../../../temp/0fb32a38c3924f54f5.png" fill="crop"/>  <clip type="video" id="SL6" label="videoPrevisaoTempo.flv" volume="0,70,100,70" trimstart="0" audio="http://localhost/moodle/file.php/2/moddata/moviemasher/6/2/6.flv" fill="scale" trimend="0" track="0" length="572"/></mash></moviemasher>';


var oldBSW = "";
var search = '.*?<clip(.*?)bsw="'+oldBSW+'"(.*?)>(.*?)<clip(.*?)id="(.*?)"(.*?)>(.*?)</clip>.*?';
//var search = '.*?<clip.*?bsw="'+oldBSW+'".*?>.*?<clip.*?id=".*?".*?bsw="'+oldBSW+'".*?>.*?</clip>.*?';
var re = new RegExp(search);
var matches = re.exec(content);

alert(matches);
// creates new media with posted BSW 
var image = '<media group="image" type="image" id="0fb32b38d3924bb4bb2df38e3964e64dc19a38e3934ea4b826538c3924ec4a70fb34738c3924bb4bb30e38c3924bb4bc14c3913924e34c422b38c3964e64ec0f" label="SW" url="http://localhost/moodle/mod/moviemasher/temp/0fb32b38d3924bb4bb2df38e3964e64dc19a38e3934ea4b826538c3924ec4a70fb34738c3924bb4bb30e38c3924bb4bc14c3913924e34c422b38c3964e64ec0f.png" fill="crop"/>';

var newContent = content.replace(matches,"novo clip");
//alert(newContent);

</script>
</head>
<body>
teste
</body>
</html>
