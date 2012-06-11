	<!-- TOOLTIP OPTIONS -->
	<option wordwrap='0' type="tooltip" symbol="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@com.moviemasher.display.Tooltip" font="default" color="FEFEC9" shadowcolor="000000" shadow="1" />
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