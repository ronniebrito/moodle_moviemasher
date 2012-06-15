<?php echo '<?xml version="1.0" encoding="utf-8"?>'; ?>

	<!-- TOOLTIP OPTIONS -->
	<option wordwrap='0' type="tooltip" symbol="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@com.moviemasher.display.Tooltip" font="default" color="FEFEC9" shadowcolor="000000" shadow="1" />
	<panels>
	
		<!-- PLAYER PANEL -->
		<panel 
			curve='8' shadow='4' shadowcolor='9F9F9F' shadowblur='3' shadowstrength='1'  
			width='640' height='360' x='10' y='10'
		>
		
			<!-- PLAYER -->
			<bar color='0' grad='0' size='*'>
				<control 
					 tie='timeline.refresh'
					 symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Player' 
					 fps='20' width="*" height="*" 
				/>
			</bar>
			
			<!-- PLAYER CONTROL BAR -->
			<bar color='333333' grad='40' size='24' align='bottom' padding='4' spacing='6'>
				
				<!-- PLAY/PAUSE TOGGLE -->
				<control tooltip='Tocar/Parar' bind="player.play" symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Toggle' toggleicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#PauseOff' toggleovericon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#PauseOn' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#PlayOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#PlayOn' />
				<!-- SCRUBBER SLIDER -->
				<control tooltip='Mudar cursos' width='80' symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider' bind='player.completed' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#ScrubBtnOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#ScrubBtnOn' back='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrubBackOff' reveal='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrubBackOn' />
				
				<!-- POSITION FIELD -->
				<control tooltip='Posição atual / Duração' fill='stretch' width='105' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@Curve' textalign='center' forecolor='FFFFFF' textsize="10" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" tie="player.position,player.duration" pattern="{position}/{duration}" />
				
				<!-- VOLUME ICON AND SLIDER -->
				
				<control symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#Volume' />				
				<control tooltip='Mudar volume' bind='player.volume' width='40' symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn' back='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff' reveal='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn' />
				
				<!-- FULLSCREEN ICON -->
				<control tooltip='Tela cheia' 
					bind='player.fullscreen' value='1'
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' 
					icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@FullscreenOff' 
					overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@FullscreenOn' 
				/>
				
			</bar>
			
		</panel>
	
	
		<!-- STALL GRAPHIC PANEL -->
		<panel width='100' height='100' x='230' y='90'>
			<bar size='*'>
				<control hide='player.stalling=0' symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ProgressIndicator' />

			</bar>
		</panel>

			


		<!-- BROWSER PANEL -->
		<panel curve='8' shadow='4' shadowcolor='9F9F9F' shadowblur='3' shadowstrength='1'  
			width='230' height='360' x='655' y='10' 
		>
			<!-- BROWSER NAVIGATION BAR -->
			<bar size='20' config='media/xml/control_nav.xml' />
		
			<!-- BROWSER VERTICAL SCROLLBAR -->
			<bar color='333333' grad='40' angle='270' align='right' size='16'>
				<control height='10' tie='browser.vscrollsize' bind='browser.vscrollunit' value='-10' hide='browser.vscrollsize=0' symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#VertScrollUpOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#VertScrollUpOn' />	
				<control tie='browser.vscrollsize' bind='browser.vscroll' hide='browser.vscrollsize=0' symbol='../../moviemasher/com/moviemasher/control/Editor/stable.swf@Scrollbar' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollVertBtnOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollVertBtnOn' back='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollVertBackOff' />	
				<control height='10' tie='browser.vscrollsize' bind='browser.vscrollunit' value='10' hide='browser.vscrollsize=0' symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#VertScrollDownOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#VertScrollDownOn' />	
			</bar>
		
			<!-- BROWSER BAR -->
			<bar size='*' color='CACACA' grad='40' angle='270' align='right'>
				<control padding='10' spacing='10'
					symbol='../../moviemasher/com/moviemasher/control/Editor/stable.swf@Browser'
					height='*'
					width="*"
					previewwidth='164'  tie='player.mash'
					hovericon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#HandOpen"
					dragicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#HandClose"
					tooltip='{type.toUpperCase}: {label}'
					source='media'
				>
					<preview type="*"
						color="CCCCCC" selcolor='99CCCCCC' grad="30" selgrad='50' angle="90" alpha="50"
						curve="8" border="2" bordercolor="666666" selbordercolor="669999"
						shadow="1" selshadow="2" shadowcolor="333333" shadowblur="2" selshadowblur="3" shadowstrength="1" selshadowstrength='2'
						textbackalpha="50" textbackcolor="FFFFFF"
						blend='multiply' selblend='normal'
					/>
					<preview type="audio" blend="darken" selblend='darken' icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@AudioPreview" />
					<preview type="effect" preview='../media/image/Logo/preview.jpg' icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@EffectPreview" />
					<preview type="image" icon="@com.moviemasher.module.AVImage" />
					<preview type="theme" blend='normal' selblend='multiply' icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ThemePreview" />
					<preview type="mash" blend='normal' selblend='multiply' icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@MashPreview" />
					<preview type="transition" preview='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@PreviewTransitionFrom,../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@PreviewTransitionTo' icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@TransitionPreview" />
					<preview type="video" icon="@com.moviemasher.module.AVSequence" />
				</control>
			</bar>
			
			
		
			<!-- SEARCH BAR -->
			<bar color='333333' grad='40' size='24' align='bottom' padding='4' spacing='0' config='media/xml/control_search.xml' />

			
		</panel>


		<!-- COMANDOS -->
	<panel curve='8' shadow='4' shadowcolor='9F9F9F' shadowblur='3' shadowstrength='1'  
			width='320' height='230' x='890' y='380' color="333333" spacing="5" padding="7"
		>


	<bar size="24" spacing="2" padding="1" >
	
	<!-- UPLOAD SRT CGI CONTROL -->
	<control id="uploaderSubs" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@CGI" 
		tie="player.mash" 
		tooltip="Envie legendas" 
		upload="media/php/uploadSubtitles.php"
		media="1" mash="1" 
		disable="uploader.progress!=null" 
		icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
		overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
		disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
		fill='stretch' pattern='Importar legendas' 
		width='100' textalign='center' textsize="11" textcolor='333333'
	>
		<filetype description="SRT or SWMLT files" extension="*.srt;*.tswml" />
	</control>
    
    
		<control id="uploaderText" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@CGI"
		tooltip="Envie um texto para traduzir" 
		upload="media/php/uploadText.php?id=<?php echo $mash_id; ?>&amp;userid=<?php echo $userid; ?>&amp;cmid=<?php echo $cmid; ?>" 		
		icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
		overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
		disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
		fill='stretch' pattern='Importar texto' 
		width='100' textalign='center' textsize="11" textcolor='333333'
	>		
		<filetype description="Arquivos de texto ou HTML" extension="*.txt;*.html;*.htm" />
	</control>
	<control id="uploader" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@CGI"
		tooltip="Envie um vídeo já gravado" upload="media/php/upload.php?id=<?php echo $mash_id; ?>&amp;userid=<?php echo $userid; ?>&amp;cmid=<?php echo $cmid; ?>"  		
		icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
		overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
		disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
		fill='stretch' pattern='Importar vídeo' 
		width='100' textalign='center' textsize="11" textcolor='333333'
	>		
		<filetype description="Arquivos de vídeo" extension="*.flv;*.mpeg;*.mpeg4;*.avi;*.mpg;*.mp4" />
	</control>
  </bar>
  <bar size="24" spacing="2" padding="1">
	
	

<!-- Edit SW -->
	<control 	
		symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@CGI" 
		id='editSW'		 
        	tooltip="Editar escrita de sinais"
		get='javascript:window.parent.editSW("{timeline.selection.bsw}");'
		icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
		overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
		disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
		fill='stretch' pattern='Editar SW' 
		textalign='center' textsize='11' width='100' textcolor='333333'
	/>	

<!-- Glossario -->
	<control 	
		symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@CGI" 
		id='editGSW'		 
        	tooltip="Editar itens do glossário"
		get='javascript:window.window.open("http://www.signbank.org/signpuddle2.0/searchword.php","glossario");'
		icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
		overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
		disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
		fill='stretch' pattern='Glossário' 
		textalign='center' textsize='11' width='100' textcolor='333333'
	/>

	<!-- Recorder -->
	<control 	
		symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@CGI" 
		tie="player.mash" id='recorder'
        	tooltip="Grave um vídeo"
		get='javascript:window.parent.showRecorder();'
		media="1" mash="1" 
		icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
		overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
		disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
		fill='stretch' pattern='Gravar vídeo' 
		textalign='center' textsize='11' width='100' textcolor='333333'
	/>
  
  </bar>
  <bar size="24" spacing="2" padding="1">
	
	<!-- icon="media/image/f_logo_button.swf"-->
	
	
	<!-- Translate CGI CONTROL -->
	<control pattern='Traduzir legendas' 
		tie="player.mash" id='saver'
		url="media/php/save.php?mash_id={mash.id}" 
		media="1" mash="1" 
		symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@CGI" 
		icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
		overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
		disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
		fill='stretch' width='100' textalign='center' textsize="11" textcolor='333333'
	/>

	<!-- Render CGI CONTROL -->
	<control pattern='Gerar animação' 
		tie="player.mash" id='saver'
		url="media/php/save.php?mash_id={mash.id}" 
		media="1" mash="1" 
		symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@CGI" 
		icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
		overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
		disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
		fill='stretch' width='100' textalign='center' textsize="11" textcolor='333333'
	/>

		    
		    
	</bar>
<bar size="24" spacing="2" padding="1">
<!-- SHARE CGI CONTROL -->
	<control pattern='Compartilhar' 
		tie="player.mash" id='sharer'
		url="media/php/share.php?id={mash.id}&amp;duration={mash.duration}" 
		media="1" mash="1" 


		symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@CGI" 
		icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
		overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
		disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
		fill='stretch' width='100' textalign='center' textsize="11" textcolor='333333'
	/>	
<!-- SAVE CGI CONTROL -->
	<control pattern='Salvar' 
		tie="player.mash" id='saver'
		disable="player.dirty=0" 
		url="media/php/save.php?mash_id={mash.id}" 
		media="1" mash="1" 
		symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@CGI" 
		icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
		overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
		disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
		fill='stretch' width='100' textalign='center' textsize="11" textcolor='333333'
	/>
	
		    
		    
	</bar>

		</panel>

		
		<!-- TIMELINE PANEL --> 
 		<panel 
			color='CACACA' grad='40' angle='270' 
			curve='8' shadow='4' shadowcolor='9F9F9F' shadowblur='3' shadowstrength='1'  
			width='880' height='230' x='10' y='380' 
		>
			<!-- TIMELINE VERTICAL SCROLLBAR -->
			<bar color='333333' grad='40' angle='270' align='right' size='16'>
				<control height='10' tie='timeline.vscrollsize' bind='timeline.vscrollunit' value='-10' hide='timeline.vscrollsize=0' symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#VertScrollUpOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#VertScrollUpOn' />	
				<control tie='timeline.vscrollsize' bind='timeline.vscroll' hide='timeline.vscrollsize=0' symbol='../../moviemasher/com/moviemasher/control/Editor/stable.swf@Scrollbar' height='*' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollVertBtnOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollVertBtnOn' back='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollVertBackOff' />	
				<control height='10' tie='timeline.vscrollsize' bind='timeline.vscrollunit' value='10' hide='timeline.vscrollsize=0' symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#VertScrollDownOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#VertScrollDownOn' />	

			</bar>
			<!-- TIMELINE BAR -->
			<bar align='right' size='*' color='CACACA' grad='40'>
				<control 
					symbol='../../moviemasher/com/moviemasher/control/Editor/stable.swf@Timeline'
					zoom="1"
					width="*"
					height="*"
					trimbothicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#BothTrim"
					trimlefticon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#LeftTrim"
					trimrighticon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#RightTrim"
					hovericon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#HandOpen"
					dragicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#HandClose"
					iconwidth="26"
					videoicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#VideoTrack"
					audioicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#AudioTrack"
					effecticon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#EffectTrack"
					linecolor="CCCCCC" 
					line="1"
					autoselect="mash"
					tooltip='{type.toUpperCase}: {label} {startframe}-{lengthframe}'
				>
					<preview type="*" 
						waveblend='darken'
						color="CCCCCC" selcolor='99CCCCCC' grad="30" selgrad='50' angle="90" alpha="50"
						curve="8" border="2" bordercolor="666666" selbordercolor="669999"
						shadow="1" selshadow="2" shadowcolor="333333" shadowblur="2" selshadowblur="3" shadowstrength="1" selshadowstrength='2'
						textbackalpha="50" textbackcolor="FFFFFF"
						blend='multiply' selblend='normal'
					/>
					<preview type="audio" blend="darken" selblend='darken' icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@AudioPreview" />
					<preview type="effect" preview='../media/image/Logo/preview.jpg' icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@EffectPreview" />
					<preview type="image" icon="@com.moviemasher.module.AVImage" />
					<preview type="theme" blend='normal' selblend='multiply' icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ThemePreview" />
					<preview type="transition" preview='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@PreviewTransitionFrom,../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@PreviewTransitionTo' icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@TransitionPreview" />
					<preview type="video" icon="@com.moviemasher.module.AVSequence" />
				</control>
			</bar>
			<!-- BUTTON BAR -->
			<!--bar color='333333' grad='60' size='26' spacing='6' padding='4' config='media/xml/control_save.xml'-->
			
			<bar color='333333' grad='60' size='26' spacing='6' padding='4'>
				
				
				
				<!--control tooltip='Undo Last Action' pattern='Undo' 
					bind='timeline.undo' disable='timeline.undo=null' 
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Text' 
					icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
					overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
					disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
					fill='stretch' width='45' textalign='center' textsize="11" textcolor='333333'
				/>
				<control tooltip='Redo Last Action' pattern='Redo' 
					bind='timeline.redo' disable='timeline.redo=null' 
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Text' 
					icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
					overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
					disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
					fill='stretch' width='45' textalign='center' textsize="11" textcolor='333333'
				/>
				<control symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#Separator' />
				
				<control tooltip='Cut selected clips to clipboard' pattern='Cut' 
					bind='timeline.cut' disable='timeline.cut=null' 
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Text' 
					icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
					overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
					disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
					fill='stretch' width='45' textalign='center' textsize="11" textcolor='333333'
				/>
				<control tooltip='Copy selected clips to clipboard' pattern='Copy' 
					bind='timeline.copy' disable='timeline.copy=null' 
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Text' 
					icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
					overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
					disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
					fill='stretch' width='45' textalign='center' textsize="11" textcolor='333333'
				/>
				<control tooltip='Paste clipboard at playhead location' pattern='Paste' 
					bind='timeline.paste' disable='timeline.paste=null' 
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Text' 
					icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
					overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
					disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
					fill='stretch' width='45' textalign='center' textsize="11" textcolor='333333'
				/>
				<control symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#Separator' />
				<control tooltip='Split selected clip at {player.position} seconds' pattern='Split' 
					bind='timeline.split' disable='timeline.split=null' 
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Text' 
					icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
					overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
					disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
					fill='stretch' width='45' textalign='center' textsize="11" textcolor='333333'
				/>
				
				<control tooltip='Delete selected clips' pattern='Delete' 
					bind='timeline.remove' disable='timeline.remove=null' 
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Text' 
					icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
					overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
					disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
					fill='stretch' width='45' textalign='center' textsize="11" textcolor='333333'
				/-->
                
                <control tooltip='Desfaz a última ação' pattern='Undo' 
					bind='timeline.undo' disable='timeline.undo=null' 
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Text' 
					icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
					overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
					disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
					fill='stretch' width='45' textalign='center' textsize="11" textcolor='333333'
				/>
				<control tooltip='Refazer última ação' pattern='Redo' 
					bind='timeline.redo' disable='timeline.redo=null' 
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Text' 
					icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
					overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
					disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
					fill='stretch' width='45' textalign='center' textsize="11" textcolor='333333'
				/><control symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#Separator' />
                <control tooltip='Copia o elemento selecionado' pattern='Copiar' 
					bind='timeline.copy' disable='timeline.copy=null' 
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Text' 
					icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
					overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
					disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
					fill='stretch' width='45' textalign='center' textsize="11" textcolor='333333'
				/>
                <control tooltip='Cola na posição atual' pattern='Colar' 
					bind='timeline.paste' disable='timeline.paste=null' 
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Text' 
					icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
					overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
					disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
					fill='stretch' width='45' textalign='center' textsize="11" textcolor='333333'
				/>
				<control symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#Separator' />
				<control tooltip='Split selected clip at {player.position} seconds' pattern='Split' 
					bind='timeline.split' disable='timeline.split=null' 
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Text' 
					icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
					overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
					disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
					fill='stretch' width='45' textalign='center' textsize="11" textcolor='333333'
				/>	
		<control tooltip='Apaga o elemento selecionado' pattern='Apagar' 
					bind='timeline.remove' disable='timeline.remove=null' 
					symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Text' 
					icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
					overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
					disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
					fill='stretch' width='45' textalign='center' textsize="11" textcolor='333333'
				/>
			<control symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#Separator' />

	<?php 
			//	include('control_save.php');
				?>
			
			</bar>
			<!-- BUFFER BAR -->
			<bar grad='20' color='666666' angle='90' align='top' spacing='4' padding='2' size='5' />
			<!-- RULER BAR	-->
			<bar grad='20' dontmask="1" angle='270' size='18' color='666666'>
				<control symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' width='26' fill='stretch' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#RulerBackOn' />
				<control width="*" incrementsymbol="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@Increment" increment="1" textcolor="FFFFFF" pattern="{time}" symbol='../../moviemasher/com/moviemasher/control/Editor/stable.swf@Ruler' back='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#RulerBackOff' ruleicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@RulerLineOff' ruleovericon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@RulerLineOn' reveal='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#RulerBackOn' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#RulerBtnOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#RulerBtnOn' />
				<control hide='timeline.vscrollsize=0' symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' width='16' />
			</bar>
			<!-- ZOOM AND HORIZONTAL SCROLLER BAR -->
			<bar color='333333' grad='40' align='bottom' spacing='2' size='16'>
		<!-- ZOOM SLIDER -->
				<control symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' width='5' />
				<control symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#ZoomOut' />
				<control tooltip='Ver escala' bind='timeline.zoom' width='140' symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider' min='1' max='100' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn' back='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff' reveal='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn' />
				<control symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#ZoomIn' />
		
				<control symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' hide='timeline.hscrollsize=0'  icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#Separator' />
				
		<!-- HSCROLL SLIDER -->
				<control width='10' tie='timeline.hscrollsize' bind='timeline.hscrollunit' value='-10' hide='timeline.hscrollsize=0' symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#HorzScrollLeftOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#HorzScrollLeftOn' />	
				<control width='*' tie='timeline.hscrollsize' bind='timeline.hscroll' hide='timeline.hscrollsize=0' symbol='../../moviemasher/com/moviemasher/control/Editor/stable.swf@Scrollbar' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollHorzBtnOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollHorzBtnOn' back='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollHorzBackOff' />
				<control width='10' tie='timeline.hscrollsize' bind='timeline.hscrollunit' value='10' hide='timeline.hscrollsize=0' symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#HorzScrollRightOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#HorzScrollRightOn' />	
			</bar>
		</panel>



		
		<!-- INSPECTOR PANEL --> 
		<panel 
			color='CACACA' grad='40' angle='270' 
			curve='8' shadow='4' shadowcolor='9F9F9F' shadowblur='3' shadowstrength='1'  
			width='320' height='360' x='890' y='10'
		>
			<!-- TITLE BAR -->
			<bar color='333333' grad='40' padding='0' align='top' spacing='1' size='26'>
				<control pattern="Editando: {label}" tie="timeline.selection.label" hide="timeline.selection.label=null" width='*' symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" forecolor='FFFFFF' textalign="center" textsize="11" wrap="0" />
				<control hide="timeline.selection.label!=null" width='*' symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" forecolor='FFFFFF' textalign="center" textsize="11" pattern="Selecione um clipe e edite suas propriedades aqui" />
			</bar>

			<!-- LABEL FIELD -->			
			<bar size="24" spacing="5" padding="2">
				<control width="45" hide="timeline.selection.label=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" pattern="Rótulo" />
				<control color="FFFFFF" width="*" height="*" multiline="0" wrap="0" hide="timeline.selection.label=null" bind="timeline.selection.label" symbol="../../moviemasher/com/moviemasher/control/Editor/stable.swf@Field" />
			</bar>
			<!-- BSW FIELD -->			
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.bsw=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" pattern="BSW" />
			</bar>
			<bar size="*" spacing="5" padding="2">
				<control color="FFFFFF" width="*" height="*" multiline="1" hide="timeline.selection.bsw=null" bind="timeline.selection.bsw" symbol="../../moviemasher/com/moviemasher/control/Editor/stable.swf@Field" />
			</bar>
					
			<!-- TRIMMER -->
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.trim=null" tie="timeline.selection.trimstart,timeline.selection.trimend" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" pattern="Cortar" />
			</bar>
			<bar size="20" spacing="5" padding="2">
				<control hide="timeline.selection.trim=null" bind="timeline.selection.trim" symbol="../../moviemasher/com/moviemasher/control/Editor/stable.swf@Trimmer" height="14" width="*" overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn" icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff" back="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff" reveal="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn" />
			</bar>
			
			<!-- LENGTH SLIDER -->
			<bar size="24" spacing="5" padding="2">
				<control tie="timeline.selection.lengthseconds" hide="timeline.selection.lengthseconds=null|timeline.selection.track&lt;0" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" pattern="Duração: {lengthseconds} segundos" />
			</bar>
			<bar size="20" spacing="5" padding="2">
				<control width="*" hide="timeline.selection.lengthseconds=null|timeline.selection.track&lt;0" bind="timeline.selection.lengthseconds" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider" height="14" min=".01" max="20" icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff" overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn" back="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff" reveal="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn" />
			</bar>
			
			
			<!-- SPEED SLIDER -->
			<bar size="24" spacing="5" padding="2">
				<control tie="timeline.selection.speed" hide="timeline.selection.speed=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" pattern="Velocidade: {speed}" />
			</bar>
			<bar size="20" spacing="5" padding="2">
				<control width="*" hide="timeline.selection.speed=null" bind="timeline.selection.speed" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider" height="14" min="10" max=".1" icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff" overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn" back="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff" reveal="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn" />
				<control hide="timeline.selection.speed=null|timeline.selection.speed=1" bind="timeline.selection.speed" value="1" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon" icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#CancelX" />
			</bar>
			<!-- INSTANCES SLIDER -->
			<bar size="24" spacing="5" padding="2">
				<control tie="timeline.selection.instances" hide="timeline.selection.instances=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" pattern="Instancias: {instances}" />
			</bar>
			<bar size="20" spacing="5" padding="2">
				<control width="*" hide="timeline.selection.instances=null" bind="timeline.selection.instances" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider" height="14" min="1" increment="1" max="30" icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff" overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn" back="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff" reveal="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn" />
			</bar>
			
			<!-- BRIGHTNESS SLIDER -->
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.brightness=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Brilho" />
			</bar>
			<bar size="20" spacing="5" padding="2">
				<control width="*" hide="timeline.selection.brightness=null" bind="timeline.selection.brightness" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider" height="14" min="-255" max="255" icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff" overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn" back="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff" reveal="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn" />
			</bar>
			
			<!-- CONTRAST SLIDER -->
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.contrast=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Contraste" />
			</bar>
			<bar size="20" spacing="5" padding="2">
				<control width="*" hide="timeline.selection.contrast=null" bind="timeline.selection.contrast" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider" height="14" min="-2" max="5" icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff" overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn" back="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff" reveal="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn" />
			</bar>
			
			<!-- HUE SLIDER -->
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.hue=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Matiz" />
			</bar>
			<bar size="20" spacing="5" padding="2">
				<control width="*" hide="timeline.selection.hue=null" bind="timeline.selection.hue" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider" height="14" min="-180" max="180" icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff" overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn" back="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff" reveal="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn" />
			</bar>
			
			<!-- SATURATION SLIDER -->
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.saturation=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Saturação" />
			</bar>
			<bar size="20" spacing="5" padding="2">
				<control width="*" hide="timeline.selection.saturation=null" bind="timeline.selection.saturation" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider" height="14" min="-2" max="5" icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff" overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn" back="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff" reveal="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn" />
			</bar>
			
 			<!-- FORE AND BACK COLOR PICKER -->
			<bar size="24" spacing="5" padding="2">
				<control width="*" hide="timeline.selection.forecolor=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Cor" />
				<control hide="timeline.selection.forecolor=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon" width="16" />
				<control width="*" hide="timeline.selection.backcolor=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Cor de fundo" />
				<control hide="timeline.selection.backcolor=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon" width="16" />
				<control width="*" hide="timeline.selection.backalpha=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Back Alpha" />
			</bar>
			<bar size="20" spacing="5" padding="2">
				<control hide="timeline.selection.forecolor=null" bind="timeline.selection.forecolor" symbol="../../moviemasher/com/moviemasher/control/Component/stable.swf@MMColorPicker" width="16" />
				<control hide="timeline.selection.forecolor=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon" width="*" />
				<control hide="timeline.selection.backcolor=null" bind="timeline.selection.backcolor" symbol="../../moviemasher/com/moviemasher/control/Component/stable.swf@MMColorPicker" width="16" />
				<control hide="timeline.selection.backcolor=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon" width="*" />
				<control hide="timeline.selection.backalpha=null" bind="timeline.selection.backalpha" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider" height="14" width="*" icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff" overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn" back="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff" reveal="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn" />
			</bar>
 		
			<!--FONT AND TEXTSIZE COMBOBOX -->
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.font=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Fonte" />
				<control hide="timeline.selection.textsize=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Tamanho" />
			</bar>
			
			<bar size="24" spacing="5" padding="2">
				
				<control hide="timeline.selection.font=null" bind="timeline.selection.font" width="*" symbol="../../moviemasher/com/moviemasher/control/Component/stable.swf@MMComboBox" config="media/xml/option_font.xml" />
				<control hide="timeline.selection.textsize=null" bind="timeline.selection.textsize" width="*" symbol="../../moviemasher/com/moviemasher/control/Component/stable.swf@MMComboBox">
					
					<size id="90" label="XXX Large" />
					<size id="40" label="XX Large" />
					<size id="20" label="X Large" />
					<size id="18" label="Large" />
					<size id="14" label="Medium" />
					<size id="12" label="Small" />
					<size id="10" label="X Small" />
					<size id="8" label="XX Small" />
				</control>
			</bar>
			<!--ORIENTATION COMBOBOX -->
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.orientation=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Orientação" />
			</bar>
			<bar size="24" spacing="5" padding="2">
				
				<control hide="timeline.selection.orientation=null" bind="timeline.selection.orientation" width="*" symbol="../../moviemasher/com/moviemasher/control/Component/stable.swf@MMComboBox">
					<orientation id="horizontal" label="Horizontal" />
					<orientation id="vertical" label="Vertical" />
				</control>
			</bar>
			
			<!--FILL COMBOBOX -->
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.fill=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Preenchimento" />
			</bar>
			<bar size="24" spacing="5" padding="2">
				
				<control hide="timeline.selection.fill=null" bind="timeline.selection.fill" width="*" symbol="../../moviemasher/com/moviemasher/control/Component/stable.swf@MMComboBox">
					<fill id="stretch" label="Distorcer" />
					<fill id="crop" label="Cortar para caber" />
					<fill id="scale" label="Sem corte" />
				</control>
			</bar>
			
			<!-- VOLUME PLOTTER -->
			<!--bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.volume=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Volume" />
			</bar>
			<bar size="80" spacing="5" padding="2">
				<control color="666666" angle="270" curve="4" padding="2" grad="40" hide="timeline.selection.volume=null" bind="timeline.selection.volume" symbol="../../moviemasher/com/moviemasher/control/Editor/stable.swf@Plotter" width="*" height="*" />
			</bar-->
			
			<!-- LONGTEXT FIELD -->			
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.longtext=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" pattern="Texto" />
			</bar>
			<bar size="*" spacing="5" padding="2">
				<control color="FFFFFF" width="*" height="*" multiline="1" hide="timeline.selection.longtext=null" bind="timeline.selection.longtext" symbol="../../moviemasher/com/moviemasher/control/Editor/stable.swf@Field" />
			</bar>

			


			<!-- HREF FIELD -->			
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.href=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" pattern="URL" />
			</bar>
			<bar size="*" spacing="5" padding="2">
				<control color="FFFFFF" width="*" height="*" multiline="1" hide="timeline.selection.href=null" bind="timeline.selection.href" symbol="../../moviemasher/com/moviemasher/control/Editor/stable.swf@Field" />
			</bar>

			<!-- MATRIX MENU -->			
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.matrix=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" pattern="Matrix" />
			</bar>
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.matrix=null" bind="timeline.selection.matrix" width="*" symbol="../../moviemasher/com/moviemasher/control/Component/stable.swf@MMComboBox">
					<matrix label="Blur 1" id="0,8,0,8,-19,8,0,8,0" />
					<matrix label="Blur 2" id="8,0,8,0,-21,0,8,0,8" />
					<matrix label="Borders" id="10,10,10,10,10,-10,-10,-10,-10" />
					<matrix label="Carve A" id="10,0,0,0,6,0,0,0,-10" />
					<matrix label="Carve B" id="10,0,0,0,6,0,0,0,-10" />
					<matrix label="Carve B Inv" id="10,10,-10,40,5,-40,10,-10,-10" />
					<matrix label="Cleanup" id="1,-1,-1,1,10,-1,1,1,1" />
					<matrix label="Emboss L" id="10,10,0,10,0,-10,0,-10,-10" />
					<matrix label="Emboss R" id="0,10,10,-10,10,10,-10,-10,-10" />
					<matrix label="Clouds" id="2,7,2,7,-33,7,2,7,2" />
					<matrix label="Chrome 1" id="10,0,-10,20,1,-20,10,0,-10" />
					<matrix label="Outline" id="10,10,10,10,-70,10,10,10,10" />
					<matrix label="Splotch A" id="10,10,-10,40,0,-40,10,-10,-10" />
					<matrix label="Splotch B" id="-10,10,-10,10,10,10,-10,10,-10" />
					<matrix label="Hi Pass A" id="-10,-10,-10,-10,90,-10,-10,-10,-10" />
					<matrix label="Hi Pass B" id="10,10,10,-10,60,10,-10,-10,-10" />
					<matrix label="Lo Pass A" id="1,1,1,1,2,1,1,1,1" />
					<matrix label="Lo Pass B" id="1,1,10,1,2,1,1,1,1" />
					<matrix label="Edge Line" id="0,-10,0,-10,40,-10,0,-10,0" />
					<matrix label="Edge Normal A" id="10,10,10,-10,-5,10,-10,-10,-10" />
					<matrix label="Edge Normal B" id="10,10,10,-10,0,10,-10,-10,-10" />
					<matrix label="Mistery" id="-10,-10,-10,-10,80,-10,-10,-10,-10" />
					<matrix label="Funky" id="10,0,0,0,-15,0,10,0,-10" />
					<matrix label="Ghost Blur" id="16,0,16,0,-55,0,16,0,16" />
				</control>
			</bar>
			
			<!-- BLEND MENU -->			
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.blend=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" pattern="Juntar" />
			</bar>
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.blend=null" bind="timeline.selection.blend" width="*" symbol="../../moviemasher/com/moviemasher/control/Component/stable.swf@MMComboBox">
					<blend label="Normal" id="normal" />
					<blend label="Multiply" id="multiply" />
					<blend label="Screen" id="screen" />
					<blend label="Lighten" id="lighten" />
					<blend label="Darken" id="darken" />
					<blend label="Difference" id="difference" />
					<blend label="Add" id="add" />
					<blend label="Subtract" id="subtract" />
					<blend label="Invert" id="invert" />
					<blend label="Overlay" id="overlay" />
					<blend label="Hard Light" id="hardlight" />
										
				</control>
			</bar>

			<!-- LOOPS SLIDER -->
			<bar size="24" spacing="5" padding="2">
				<control tie="timeline.selection.loops" hide="timeline.selection.loops=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" pattern="Ciclos: {loops}" />
			</bar>
			<bar size="20" spacing="5" padding="2">
				<control width="*" hide="timeline.selection.loops=null" bind="timeline.selection.loops" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider" height="14" min="1" max="100" icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff" overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn" back="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff" reveal="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn" />
			</bar>

			<!-- ALPHA SLIDER -->
			<bar size="24" spacing="5" padding="2">
				<control tie="timeline.selection.alpha" hide="timeline.selection.alpha=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" pattern="Alpha: {alpha}" />
			</bar>
			<bar size="20" spacing="5" padding="2">
				<control width="*" hide="timeline.selection.alpha=null" bind="timeline.selection.alpha" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider" height="14" value="0" min="-180" max="180" icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff" overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn" back="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff" reveal="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn" />
			</bar>

			<!-- ROTATE SLIDER -->
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.rotate=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Rotação" />
			</bar>
			<bar size="20" spacing="5" padding="2">
				<control width="*" hide="timeline.selection.rotate=null" bind="timeline.selection.rotate" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider" height="14" value="0" min="-180" max="180" icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff" overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn" back="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff" reveal="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn" />
			</bar>
			
			<!-- POSITION SCALE AND SHEAR PLOTTERS -->
			<bar size="24" spacing="5" padding="2">
				<control width="*" hide="timeline.selection.position=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Posição" />
				<control width="*" hide="timeline.selection.scale=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Escala" />
				<control width="*" hide="timeline.selection.shear=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Shear" />
			</bar>
			<bar size="*" spacing="5" padding="2">
				<control color="666666" angle="270" curve="4" padding="2" grad="40" width="*" height="*" multiple="0" hide="timeline.selection.position=null" bind="timeline.selection.position" symbol="../../moviemasher/com/moviemasher/control/Editor/stable.swf@Plotter"/>
				<control color="666666" angle="270" curve="4" padding="2" grad="40" width="*" height="*" multiple="0" hide="timeline.selection.scale=null" bind="timeline.selection.scale" symbol="../../moviemasher/com/moviemasher/control/Editor/stable.swf@Plotter"  />
				<control color="666666" angle="270" curve="4" padding="2" grad="40" width="*" height="*" multiple="0" hide="timeline.selection.shear=null" bind="timeline.selection.shear" symbol="../../moviemasher/com/moviemasher/control/Editor/stable.swf@Plotter"  />
			</bar>

			<!-- ROTATE FADE SLIDER -->
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.rotatefade=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Rotação Fade" />
			</bar>
			<bar size="20" spacing="5" padding="2">
				<control width="*" hide="timeline.selection.rotatefade=null" bind="timeline.selection.rotatefade" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Slider" height="14" value="0" min="-180" max="180" icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOff" overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#SliderHorzBtnOn" back="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOff" reveal="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@SliderHorzBackOn" />
			</bar>
			
			<!-- POSITIONFADE SCALEFADE AND SHEARFADE PLOTTERS -->
			<bar size="24" spacing="5" padding="2">
				<control width="*" hide="timeline.selection.positionfade=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Fade Position" />
				<control width="*" hide="timeline.selection.scalefade=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Fade Scale" />
				<control width="*" hide="timeline.selection.shearfade=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Fade Shear" />
			</bar>
			<bar size="*" spacing="5" padding="2">
				<control color="666666" angle="270" curve="4" padding="2" grad="40" width="*" height="*" multiple="0" hide="timeline.selection.positionfade=null" bind="timeline.selection.positionfade" symbol="../../moviemasher/com/moviemasher/control/Editor/stable.swf@Plotter"/>
				<control color="666666" angle="270" curve="4" padding="2" grad="40" width="*" height="*" multiple="0" hide="timeline.selection.scalefade=null" bind="timeline.selection.scalefade" symbol="../../moviemasher/com/moviemasher/control/Editor/stable.swf@Plotter"  />
				<control color="666666" angle="270" curve="4" padding="2" grad="40" width="*" height="*" multiple="0" hide="timeline.selection.shearfade=null" bind="timeline.selection.shearfade" symbol="../../moviemasher/com/moviemasher/control/Editor/stable.swf@Plotter"  />
			</bar>
			
			<!-- FADE PLOTTER  -->
			<bar size="24" spacing="5" padding="2">
				<control hide="timeline.selection.fade=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Fade" />
			</bar>
			<bar size="*" spacing="5" padding="2">
				<control color="666666" angle="270" curve="4" padding="2" grad="40" hide="timeline.selection.fade=null" bind="timeline.selection.fade" symbol="../../moviemasher/com/moviemasher/control/Editor/stable.swf@Plotter" width="*" height="*" />
			</bar>

			<!-- EFFECTS VERTICAL SCROLLBAR -->
			<bar color='333333' grad='40' angle='270' align='right' size='16'>
				<control tie='effects.vscrollsize' bind='effects.vscroll' hide='effects.vscrollsize=0' symbol='../../moviemasher/com/moviemasher/control/Editor/stable.swf@Scrollbar' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollVertBtnOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollVertBtnOn' back='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollVertBackOff' />	
			</bar>
			
			<!-- EFFECTS VIEW -->
			<bar size="24" spacing="5" padding="2">
				<control width='*' hide="timeline.selection.composites=null" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" text="Media" />
				<control width='*' hide="timeline.selection.effects=null" tie="timeline.selection.kind" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@Text" textsize="11" pattern="Efeitos {kind} " />
			</bar>
			<bar size="*" padding="2" align='right'>
				<control 
					spacing='10' 
					color="666666" angle="270" curve="4" padding="2" grad="40" 
					id='effects'
					hide="timeline.selection.effects=null" bind="timeline.selection.effects" 
					symbol='../../moviemasher/com/moviemasher/control/Editor/stable.swf@Browser'
					height='*'
					width="*" tie="player.mash"
					previewwidth='80' 
					selection='timeline.selection'
				>
					<drop type='effect' />
					<preview type="effect" preview='../media/image/Logo/preview.jpg' 
						icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@EffectPreview"											
						color="CCCCCC" selcolor='99CCCCCC' grad="30" selgrad='50' angle="90" alpha="50"
						curve="8" border="2" bordercolor="666666" selbordercolor="669999"
						shadow="1" selshadow="2" shadowcolor="333333" shadowblur="2" selshadowblur="3" shadowstrength="1" selshadowstrength='2'
						textbackalpha="50" textbackcolor="FFFFFF"
						blend='multiply' selblend='normal'
					/>
				</control>
			</bar>

			<!-- COMPOSITES VERTICAL SCROLLBAR -->
			<bar color='333333' grad='40' angle='270' align='right' size='16'>
				<control tie='composites.vscrollsize' bind='composites.vscroll' hide='composites.vscrollsize=0' symbol='../../moviemasher/com/moviemasher/control/Editor/stable.swf@Scrollbar' icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollVertBtnOff' overicon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollVertBtnOn' back='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ScrollVertBackOff' />	
			</bar>
			
			<!-- COMPOSITES VIEW -->
			<bar size="*" padding="2" align='right'>
				<control 
					spacing='10' 
					color="666666" angle="270" curve="4" padding="2" grad="40" 
					id='composites' 
					hide="timeline.selection.composites=null" bind="timeline.selection.composites" 
					symbol='../../moviemasher/com/moviemasher/control/Editor/stable.swf@Browser'
					height='*'
					width="*" tie="player.mash"
					previewwidth='80' 
					selection='timeline.selection'
				>
					<drop type='image' />
					<drop type='theme' />
					<drop type='video' />
					
					<preview type="*"
						color="CCCCCC" selcolor='99CCCCCC' grad="30" selgrad='50' angle="90" alpha="50"
						curve="8" border="2" bordercolor="666666" selbordercolor="669999"
						shadow="1" selshadow="2" shadowcolor="333333" shadowblur="2" selshadowblur="3" shadowstrength="1" selshadowstrength='2'
						textbackalpha="50" textbackcolor="FFFFFF"
						blend='multiply' selblend='normal'
					/>
					<preview type="image" icon="@com.moviemasher.module.AVImage" />
					<preview type="theme" blend='normal' selblend='multiply' icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@ThemePreview" />
					<preview type="video" icon="@com.moviemasher.module.AVSequence" />
				</control>
				
			</bar>
			
		</panel>

	</panels>	
