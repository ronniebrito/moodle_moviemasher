<?php 


require_once(  dirname(dirname(dirname(dirname(dirname(dirname(__FILE__)))))).'/config.php');

  // require_once(dirname( dirname( dirname(dirname(dirname(dirname(dirname(dirname(__FILE__)))))))).'/config.php');
//require_once(dirname(__FILE__).'/lib.php');

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
?>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script src="jquery-1.6.2.min.js" type="text/javascript"></script>
<script src="jquery.aautoscroll.2.4.js" type="text/javascript"></script>
<script type="text/javascript">
//ControlsHandler

function play() {
		pause = false;
		$(".velocidade").html(velocidade);
		$("#tela").autoscroll({
			direction : "down",
			step : velocidade
		});
	}
	
function pausar() {
		pause = true;
		$(".velocidade").html(velocidade + " (pause)");
		$("#tela").autoscroll({
			direction : "up",
			step : 0
		});
	}
	
var velocidade = 16;
var pause = true;
(function($) {
	$(document).ready(function() {
		$(".velocidade").html(velocidade + " (pause)");
		$("a.controles").click(function() {
			var action = $.trim($(this).html());
			if (action == "Iniciar/Pausar" && pause) {
				play();
			} else if (action == "Iniciar/Pausar" && !pause) {
				pausar();
			} else if (action == "[ + ]") {
				plus();
			} else if (action == "[ - ]") {
				minus();
			} else if (action == "Reiniciar") {
				restart();
			}
			$(".controles").autoscroll(action);
		});
	});
	
	function play() {
		pause = false;
		$(".velocidade").html(velocidade);
		$("#tela").autoscroll({
			direction : "down",
			step : velocidade
		});
	}
	function pausar() {
		pause = true;
		$(".velocidade").html(velocidade + " (pause)");
		$("#tela").autoscroll({
			direction : "up",
			step : 0
		});
	}
	function plus() {
		velocidade += 8;
		pause = false;
		$(".velocidade").html(velocidade);
		$("#tela").autoscroll({
			direction : "down",
			step : velocidade
		});
	}
	function minus() {
		velocidade -= 8;
		pause = false;
		$(".velocidade").html(velocidade);
		$("#tela").autoscroll({
			direction : "down",
			step : velocidade
		});
	}
	function restart() {
		pause = true;
		$(".velocidade").html(velocidade + " (pause)");
		$("#tela").autoscroll({
			direction : "up",
			step : 10000000
		});
	}
})(jQuery);
</script>
<style type="text/css">
body{
	background-color:white;
	margin:0px;
	}
#tela {
	width: 100%;
	height: 340px;
	overflow: auto;
	line-height: 200%;
	font-size: 25px;
}
a {
	margin: 0 5px 0 0;
	cursor: pointer;
	color: blue;
	text-decoration: underline;
}
</style>
<title>Auto Scroll Text</title>
</head>
<body>
	<div id="tela">
		<?php 
		
		echo $moviemasher->teleprompttext;
		?>
	</div>
	<div id="menu">
		<!--a class="controles">Iniciar/Pausar</a--> <a class="controles">[ + ]</a>
		<a class="controles">[ - ]</a> <a
			style="text-decoration: none; color: black;" class="velocidade"></a>
		<a class="controles">Reiniciar</a>
	</div>
</body>
</html>