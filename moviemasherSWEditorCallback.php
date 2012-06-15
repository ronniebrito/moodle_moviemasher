<?php  
//this file receives SWEditor BSW , parse BSW image  and sets Moviemasher timeline.selection.bsw

require_once(dirname(dirname(dirname(__FILE__))).'/config.php');
$bsw = (empty($_REQUEST['bsw']) ? "" : $_REQUEST['bsw']);

file_get_contents($CFG->wwwroot."/mod/moviemasher/binarySignWriting.php?palavra=".$bsw );		

?>
<script>

function clearnl(text){
	text = escape(text);
	if(text.indexOf('%0D%0A') > -1){
		re_nlchar = /%0D%0A/g ;
	}else if(text.indexOf('%0A') > -1){
		re_nlchar = /%0A/g ;
	}else if(text.indexOf('%0D') > -1){
		re_nlchar = /%0D/g ;
	}
	return unescape( text.replace(re_nlchar,'') );
}



// gets mash
var mash = window.parent.moviemasher("editor_frame","moviemasher_editor").evaluate("mash.xml");

mash = clearnl(mash);
//mash = mash.replace(/\r/,"");
var oldBSW = window.parent.moviemasher("editor_frame","moviemasher_editor").evaluate("timeline.selection.bsw");
//alert(xmash);
var theSearch = '(.*?)<clip(.*?)bsw="'+oldBSW+'"(.*?)>(.*?)<clip(.*?)id="(.*?)"(.*?)>(.*?)</clip>(.*?)';


var re = new RegExp(theSearch);
var matches = re.exec(mash);

var oldID = matches[6];
var newID = "<?php echo md5(substr($bsw,0, 128))?>";

var newBSW="<?php echo $bsw ?>";

var newClip = matches[1]+'<clip'+matches[2]+' bsw="'+newBSW+'"'+matches[3]+'>'+matches[4]+'<clip'+matches[5]+'id="'+newID+'"'+matches[7]+'>'+matches[8]+'</clip>'+matches[9];

newClip = newClip + '<media group="image" type="image" id="'+newID+'" label="SW" url="../../../temp/'+newID+'.png" fill="crop"/>';

var newMash = mash.replace(matches[0],newClip);



var position = window.parent.moviemasher("editor_frame","moviemasher_editor").evaluate("player.position");

window.parent.moviemasher("editor_frame","moviemasher_editor").evaluate(newMash);

window.parent.moviemasher("editor_frame","moviemasher_editor").evaluate("player.position="+position);

//window.parent.moviemasher("editor_frame","moviemasher_editor").evaluate("mash.xml="+newMash);

//alert(newMash);
// replace selected clip with new one into mash
	
// sets new mash
//window.parent.moviemasher("editor_frame","moviemasher_editor").evaluate("timeline.selection.bsw=<?php echo $bsw; ?>"); 
	
	window.parent.closeSWEditor();
</script>
<?php


?>
