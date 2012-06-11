<?php 

echo '<?xml version="1.0"  encoding="utf-8" ?>';
require_once(dirname( dirname( dirname(dirname(dirname(dirname(dirname(dirname(__FILE__)))))))).'/config.php');

  // require_once(dirname( dirname( dirname(dirname(dirname(dirname(dirname(dirname(__FILE__)))))))).'/config.php');
//require_once(dirname(__FILE__).'/lib.php');

$cmid = optional_param('cmid', 0, PARAM_INT);
$userid = optional_param('userid', 0, PARAM_INT);  	 
$mash_id = optional_param('mashid', 0, PARAM_INT);  


$params = optional_param('params', 0, PARAM_RAW);  


$parametros = explode("__",$params);

//var_dump($params);
$userid = $parametros[0];
$cmid = $parametros[1];
$mash_id = $parametros[2];


//echo 'dddd'.$mash_id ;
?>
    <?php
//	$db->debug = true;


ob_start();

  	if ($cmid) {
		
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


 
<moviemasher>
	
	<!-- DEFAULT MASH -->
	<!--moviemasher config='media/xml/mash.xml' /-->
    
       
    
    
    <?php  echo  stripslashes($mash->mash); ?>
    
	

	<panels>
	
		<!-- PLAYER PANEL -->
		<panel 
			curve='8' shadow='4' shadowcolor='9F9F9F' shadowblur='3' shadowstrength='1'  
			width='320' height='264' x='20' y='20'
		>
		
			<!-- PLAYER -->
			<bar color='0' grad='0' size='*'>
				<control 
					 symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Player' 
					 fps='20' width="*" height="*" 
				/>
			</bar>
			
			<!-- PLAYER CONTROL BAR -->
			<bar color='333333' grad='40' size='24' align='bottom' padding='4' spacing='6'>
				
				<!-- PLAY/PAUSE TOGGLE -->
				<control tooltip='Play/Pause' bind="player.play" symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Toggle' toggleicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#PauseOff' toggleovericon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#PauseOn' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#PlayOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#PlayOn' />
				<!-- SCRUBBER SLIDER -->
				<control tooltip='Change Playhead Position' width='80' symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider' bind='player.completed' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#ScrubBtnOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#ScrubBtnOn' back='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrubBackOff' reveal='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrubBackOn' />
				
				<!-- POSITION FIELD -->
				<control tooltip='Current Position / Duration' fill='stretch' width='105' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@Curve' textalign='center' forecolor='FFFFFF' textsize="10" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" tie="player.position,player.duration" pattern="{position}/{duration}" />
				
				<!-- VOLUME ICON AND SLIDER -->
				
				<control symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#Volume' />				
				<control tooltip='Change Playback Volume' bind='player.volume' width='40' symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn' back='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff' reveal='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn' />
				
				<!-- FULLSCREEN ICON -->
				<control tooltip='Enter Full Screen Mode' 
					bind='player.fullscreen' value='1'
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' 
					icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@FullscreenOff' 
					overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@FullscreenOn' 
				/>
				
			</bar>
			
		</panel>
	
	</panels>	
    
	<source id='SL'  url='media/php/media.php?group={group}&amp;label={terms}&amp;index={index}&amp;count={count}' symbol='../../moviemasher/com/moviemasher/source/RecorderSource/stable.swf@RecorderSource' /> 
   
   <!--source id='SW'   fields="entry[media:group/yt:duration/@seconds&lt;=960]" symbol='../../moviemasher/com/moviemasher/source/SignWritingSource/stable.swf@SignWritingSource' /--> 
	
   <source id='youtube'  fields="entry[media:group/yt:duration/@seconds&lt;=960]" symbol='../../moviemasher/com/moviemasher/source/YouTubeSource/stable.swf@YouTubeSource' />
    
    
    <!--source id='effect' config='media/xml/media_effect.xml' /-->
    
    
    
	<!-- HANDLERS FOR ALL MEDIA EXCEPT IMAGES -->
	<moviemasher config='media/xml/handler.xml' />

</moviemasher>

<?php

ob_end_flush();
?>
