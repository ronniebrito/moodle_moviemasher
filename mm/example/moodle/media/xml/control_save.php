<?php echo '<?xml version="1.0" encoding="utf-8"?>'; ?>
	<control symbol='../../moviemasher/com/moviemasher/control/Player/stable.swf@Icon' width="*" />
	
	
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
		fill='stretch' pattern='Legendas' 
		width='65' textalign='center' textsize="11" textcolor='333333'
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
		width='85' textalign='center' textsize="11" textcolor='333333'
	>		
		<filetype description="Arquivos de texto ou HTML" extension="*.txt;*.html;*.htm" />
	</control>
  
	
	<control id="uploader" symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@CGI"
		tooltip="Envie um vídeo já gravado" upload="media/php/upload.php?id=<?php echo $mash_id; ?>&amp;userid=<?php echo $userid; ?>&amp;cmid=<?php echo $cmid; ?>"  		
		icon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOff"
		overicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnOn"
		disicon="../../moviemasher/com/moviemasher/skin/Liquid/stable.swf@BtnDis"
		fill='stretch' pattern='Importar vídeo' 
		width='85' textalign='center' textsize="11" textcolor='333333'
	>		
		<filetype description="Arquivos FLV" extension="*.flv" />
	</control>

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
		textalign='center' textsize='11' width='85' textcolor='333333'
	/>
  
	
	<!-- SHARE CGI CONTROL -->
	<control pattern='   Share ' 
		tie="player.mash" id='sharer'
		url="media/php/share.php?id={mash.id}&amp;duration={mash.duration}" 
		media="1" mash="1" 
		symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@CGI" 
		icon="media/image/f_logo_button.swf"
		textalign='center' textsize="11" textcolor='FFFFFF'
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
		fill='stretch' width='65' textalign='center' textsize="11" textcolor='333333'
	/>
	

	
	<!-- ONLY REMOVE IF YOU PROVIDE SOME OTHER OBVIOUS LINK TO MOVIEMASHER.COM -->
	<control tooltip='Movie Masher' id='logo'
		symbol="../../moviemasher/com/moviemasher/control/Player/stable.swf@CGI" 
		get='javascript:window.open("../../LICENSE.html", "moviemasher_license", "width=340,height=540");'
		icon='../../moviemasher/com/moviemasher/skin/Liquid/stable.swf#MovieMasher' 
	/>			
