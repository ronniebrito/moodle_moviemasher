<?php  // $Id: submissions.php,v 1.43 2006/08/28 08:42:30 toyomoyo Exp $

//dsfecho (integer)ini_get('display_errors');
ini_set('display_errors', 1);

    require_once("../../config.php");
    require_once("lib.php");

    $id   = optional_param('id', 0, PARAM_INT);          // Course module ID
    $a    = optional_param('a', 0, PARAM_INT);           // moviemasher ID
    $mode = optional_param('mode', 'all', PARAM_ALPHA);  // What mode are we in?

    if ($id) {
	if (! $cm = get_coursemodule_from_id('moviemasher', $id)) {
	    error("Course Module ID was incorrect");
	}

	if (! $moviemasher = get_record("moviemasher", "id", $cm->instance)) {
	    error("moviemasher ID was incorrect");
	}

	if (! $course = get_record("course", "id", $moviemasher->course)) {
	    error("Course is misconfigured");
	}
    } else {
	if (!$moviemasher = get_record("moviemasher", "id", $a)) {
	    error("Course module is incorrect");
	}
	if (! $course = get_record("course", "id", $moviemasher->course)) {
	    error("Course is misconfigured");
	}
	if (! $cm = get_coursemodule_from_instance("moviemasher", $moviemasher->id, $course->id)) {
	    error("Course Module ID was incorrect");
	}
    }
    
$context = get_context_instance(CONTEXT_MODULE, $cm->id);
$tablecolumns = array('fullname', 'content');
$tableheaders = array(
				  get_string('fullname'),
				  '');

require_once($CFG->libdir.'/tablelib.php');
$table = new flexible_table('mod-moviemasher-submissions');
$table->define_columns($tablecolumns);
$table->define_headers($tableheaders);
$table->set_attribute('cellspacing', '0');
$table->set_attribute('id', 'attempts');
$table->set_attribute('class', 'submissions');
$table->set_attribute('width', '80%');
$table->setup();


// selects all posts of this mm


if ($where = $table->get_sql_where()) {
	      $where .= ' AND ';
}

if ($sort = $table->get_sql_sort()) {
    $sort = ' ORDER BY '.$sort;
}

$groupmode = groups_get_activity_groupmode($cm);
$currentgroup = groups_get_activity_group($cm, true);

if (!empty($CFG->gradebookroles)) {
    $gradebookroles = explode(",", $CFG->gradebookroles);
} else {
    $gradebookroles = '';
}
$users = get_role_users($gradebookroles, $context, true, '', 'u.lastname ASC', true, $currentgroup);
 if ($users) {

            $users = array_keys($users);

            if (!empty($CFG->enablegroupings) and $cm->groupmembersonly) {

                $groupingusers = groups_get_grouping_members($cm->groupingid, 'u.id', 'u.id');

                if ($groupingusers) {

                    $users = array_intersect($users, array_keys($groupingusers));

                }

            }

        }
        
  $select = 'SELECT u.id, u.firstname, u.lastname, 
			  s.id AS submissionid, 
			  s.timemodified ';
	$sql = 'FROM '.$CFG->prefix.'user u '.
	      'LEFT JOIN '.$CFG->prefix.'moviemasher_mash s ON u.id = s.user_id
								  AND s.moviemasher_id = '.$moviemasher->id.' '.
	       'WHERE '.$where.'u.id IN ('.implode(',',$users).') ';

//$db->debug =true;
$posts = get_records_sql($select.$sql.$sort, $table->get_page_start(), $table->get_page_size());


$navigation = build_navigation("Envios", $cm);
print_header_simple(format_string($moviemasher->name,true), "", $navigation,'', '', true,  navmenu($course, $cm));

/// find out current groups mode
        $groupmode = groups_get_activity_groupmode($cm);
        $currentgroup = groups_get_activity_group($cm, true);
        groups_print_activity_menu($cm, $CFG->wwwroot . '/mod/moviemasher/submissions.php?id=' . $cm->id);
		
		
foreach ($posts as $post ){
	
		//var_dump($post);
	if($post->submissionid ) {		
		$player_content = '<a href="'.$CFG->wwwroot.'/mod/moviemasher/mm/example/player/index.php?userid='.$post->id.'&amp;cm_id='.$cm->id.'&amp;mash_id='.$post->submissionid.'" target="new" > ver </a>';
	} else{
		$player_content = 'não enviou';
	}
	
    $row = array($post->firstname . ' '.$post->lastname, $player_content);
    $table->add_data($row);
}

	$table->print_html();  /// Print the whole table

	print_footer($this->course);
?>
