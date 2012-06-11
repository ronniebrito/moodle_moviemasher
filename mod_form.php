<?php //$Id: mod_form.php,v 1.2.2.3 2009/03/19 12:23:11 mudrd8mz Exp $

/**
 * This file defines the main moviemasher configuration form
 * It uses the standard core Moodle (>1.8) formslib. For
 * more info about them, please visit:
 *
 * http://docs.moodle.org/en/Development:lib/formslib.php
 *
 * The form must provide support for, at least these fields:
 *   - name: text element of 64cc max
 *
 * Also, it's usual to use these fields:
 *   - intro: one htmlarea element to describe the activity
 *            (will be showed in the list of activities of
 *             moviemasher type (index.php) and in the header
 *             of the moviemasher main page (view.php).
 *   - introformat: The format used to write the contents
 *             of the intro field. It automatically defaults
 *             to HTML when the htmleditor is used and can be
 *             manually selected if the htmleditor is not used
 *             (standard formats are: MOODLE, HTML, PLAIN, MARKDOWN)
 *             See lib/weblib.php Constants and the format_text()
 *             function for more info
 */

require_once($CFG->dirroot.'/course/moodleform_mod.php');

class mod_moviemasher_mod_form extends moodleform_mod {

    function definition() {

        global $COURSE, $CFG, $USER,  $context;
		
	//	var_dump( $context);
        $mform = $this->_form;

//-------------------------------------------------------------------------------
    /// Adding the "general" fieldset, where all the common settings are showed
        $mform->addElement('header', 'general', get_string('general', 'form'));

    /// Adding the standard "name" field
        $mform->addElement('text', 'name', get_string('moviemashername', 'moviemasher'), array('size'=>'64'));
        $mform->setType('name', PARAM_TEXT);
        $mform->addRule('name', null, 'required', null, 'client');
        $mform->addRule('name', get_string('maximumchars', '', 255), 'maxlength', 255, 'client');

    /// Adding the required "intro" field to hold the description of the instance
        $mform->addElement('htmleditor', 'intro', get_string('moviemasherintro', 'moviemasher'));
        $mform->setType('intro', PARAM_RAW);
        $mform->addRule('intro', get_string('required'), 'required', null, 'client');
        $mform->setHelpButton('intro', array('writing', 'richtext'), false, 'editorhelpbutton');
		
    /// Adding "introformat" field
        $mform->addElement('format', 'introformat', get_string('format'));
		
		
		 /// Adding the required "intro" field to hold the description of the instance
        $mform->addElement('textarea', 'teleprompttext', 'texto a traduzir','wrap="virtual" rows="20" cols="50"');
        $mform->setType('teleprompttext', PARAM_RAW);
		
		

//-------------------------------------------------------------------------------
    /// Adding the rest of moviemasher settings, spreeading all them into this fieldset
    /// or adding more fieldsets ('header' elements) if needed for better logic
      //$mform->addElement('static', 'label1', 'moviemashersetting1', 'Your moviemasher fields go here. Replace me!');

        $mform->addElement('header', 'moviemasherfieldset', get_string('moviemasherfieldset', 'moviemasher'));
		
        $mform->addElement('choosecoursefile', 'moviemashervideo', 'Arquivo de v&iacute;deo:', null, array('maxlength' => 255, 'size' => 48));
		
		
        $mform->setDefault('moviemashervideo', $CFG->moviemasher_defaulturl);
		
		
        $mform->addRule('moviemashervideo', null, 'required', null, 'client');
		
		
		//$mform->addElement('defaultmash', 'moviemashervideo', 'Video inicial', null, array('maxlength' => 255, 'size' => 48));
		
		
		//$mform->addElement('html', '<iframe id="editor_frame" src="'.$CFG->wwwroot.'/mod/moviemasher/mm/example/moodle/indexEdit.php" width="1320px" height="600px"> </iframe> ');
		
		
		/*$mform->addElement('html', '
		
		<input name="default_mash" type="hidden" value="yes" id="default_mash"/>
		
		<script type="text/javascript">

 
		function moviemasher(frame, id){	
		
		//return (navigator.appName.indexOf("Microsoft") == -1) ? document[id] : window[id];		
			var fr =  document.getElementById(frame).contentDocument;	
			return fr.getElementById(id);		
		}

        window.onsubmit = function doSpuff()
        {			
			var obj_form = document.getElementById(\'id_default_mash\');
			obj_form.value = moviemasher(\'editor_frame\', \'moviemasher_editor\').evaluate(\'mash.xml\');
				return true;
        }
		
		
</script>'
);*/
		
		//$mform->addElement('hidden', 'default_mash', 'sucker');
		
		$attributes=array('size'=>'0', 'style'=>'display:none', 'id'=>'default_mash');
		$mform->addElement('text', 'default_mash', '', $attributes);
        $mform->setType('default_mash', PARAM_RAW);
		
//-------------------------------------------------------------------------------
        // add standard elements, common to all modules
        $this->standard_coursemodule_elements();
//-------------------------------------------------------------------------------
        // add standard buttons, common to all modules
        $this->add_action_buttons();

    }
}

?>
