<?php 


require_once(  dirname(dirname(dirname(dirname(dirname(dirname(__FILE__)))))).'/config.php');
$cmid = optional_param('cm_id', 0, PARAM_INT);
$userid = optional_param('userid', 0, PARAM_INT);  	 
$mash_id = optional_param('mashid', 0, PARAM_INT);  
$params = optional_param('params', 0, PARAM_RAW);  


if ($cmid){		
		if (! $cm = get_coursemodule_from_id('moviemasher', $cmid)) {
            error('Course Module ID was incorrect');
        }
    
        if (! $course = get_record('course', 'id', $cm->course)) {
            error('Course is misconfigured');
        }
    
        if (! $moviemasher = get_record('moviemasher', 'id', $cm->instance)) {
            error('Course module is incorrect');
        }
	}
		
		$mash = get_record('moviemasher_mash', 'user_id', $userid, 'moviemasher_id', $moviemasher->id);
?><!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
         <style type="text/css">
            body{
                margin:0;
                margin-top:400px;
            }
            #tela {
                margin-top:20px;
                width: 100%;
                line-height: 200%;
                font-size: 25px;
				background-color:#CCC;
            }
            #menu{
                position: fixed;
                bottom:0;
                left:0;
                background-color: white;
                border: black groove;
            }
            a {
                color: white;
                text-decoration: none;
            }
            p{
                font-size: 20px;
            }
            #fim{
                color:white;
                text-align: center;
                background-color: red;
            }
        </style>
    </head>
    <body bgcolor="#CCCCCC">
        <div id="tela">
        
            	<?php 
		
		echo $mash->text;
		?>
        </div>
      <div id="menu">
            <!--input type="button" class="controles" onclick="iniciarPausarClicked();return false;" value="Iniciar/Pausar"/-->
            <input type="button" class="controles" onclick="plus();return false;" value="+"/>
            <input type="button" class="controles" onclick="minus();return false;" value="-"/>
            <a href="#"><!--input type="button" class="controles" onclick="pausar();return true;" value="Reiniciar" /--></a>
            <a style="text-decoration: none; color: black;" id="velocidade"></a>
            <a href="javascript:increaseFontSize();"><input type="button" style="font-size: 11pt;" class="controles"value="A+"/></a>
            <a href="javascript:decreaseFontSize();"><input type="button" style="font-size: 9pt;" class="controles"value="A-"/></a> 

        </div>
        <div id="fim">
            FIM
        </div>

        <script type="text/javascript">
            var velocidade = 10;
            var pause = true;

            window.onload=function(){
                document.getElementById("velocidade").innerHTML=velocidade + " (pause)";
            }
            
            function iniciarPausarClicked(){
                if (pause) {
                    play();
                }else{
                    pausar();
                }
            }
            
            function move(){
                window.scrollBy(0,1);
            }
            var scrollTimer;
            function play() {
                pause = false;
                document.getElementById("velocidade").innerHTML=velocidade;
                scrollTimer = window.setInterval(move,calcIntervalo(velocidade));
            }
                
            function pausar() {
                pause = true;
                document.getElementById("velocidade").innerHTML=velocidade + " (pause)";
                clearTimeout(scrollTimer);
            }
            function plus() {
                if(velocidade<50){
                    velocidade += 1;
                    document.getElementById("velocidade").innerHTML=velocidade + " (pause)";
					saveParameter('telepromptspeed', velocidade);
                    if(!pause){
                        pausar();
                        play();
                    }
                }
            }
            function minus() {
                if(velocidade>1){
                    velocidade -= 1;
                    document.getElementById("velocidade").innerHTML=velocidade + " (pause)";
					saveParameter('telepromptspeed', velocidade);					
                    if(!pause){
                        pausar();
                        play();
                    }
                }
            }
            function calcIntervalo(velo){
                var resp = (1/velo)*1000;
                return resp;
            }
            
            
            var fontMin=12;
            var fontMax=60;
            function increaseFontSize() {

                var p = document.getElementsByTagName('div');
                for(i=0;i<p.length;i++) {
 
                    if(p[i].style.fontSize) {
                        var s = parseInt(p[i].style.fontSize.replace("px",""));
                    } else {
 
                        var s = 20;
                    }
                    if(s!=fontMax) {
 
                        s += 1;
                    }
                    p[i].style.fontSize = s+"px"
					saveParameter('telepromptfontsize', s);
 
                }
            }
            function decreaseFontSize() {
                var p = document.getElementsByTagName('p');
                for(i=0;i<p.length;i++) {
 
                    if(p[i].style.fontSize) {
                        var s = parseInt(p[i].style.fontSize.replace("px",""));
                    } else {
 
                        var s = 20;
                    }
                    if(s!=fontMin) {
 
                        s -= 1;
                    }
                    p[i].style.fontSize = s+"px"
					saveParameter('telepromptfontsize', s);
                }
            }
			
			
			
function saveParameter(name, value){	
 	dummyimage = new Image();
	dummyimage.src = '../../saveParameter.php?id=<?php echo $mash->id;?>&name='+ name +'&value='+ velocidade;
	alert('saveParameter.php?id=<?php echo $mash->id;?>&name='+ name +'&value='+ velocidade);
	return true;
}
			
				
					 
        </script>
    </body>
</html>