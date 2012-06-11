<?php

    defined('moviemasher_INCLUDE_TEST') OR die('not allowed');

    $tabs = array();
    $row  = array();
    $inactive = array();
    $activated = array();

    $baseurl = $CFG->wwwroot.'/mod/moviemasher/view.php?id='.$id.'&amp;tab=';

    // the main three tabs
    //==> first tab
    $row[] = new tabobject(moviemasher_TAB1, $baseurl.moviemasher_TAB1, get_string('firsttabname', 'moviemasher'));

    //==> second tab
	$row[] = new tabobject(moviemasher_TAB2, $baseurl.moviemasher_TAB2, get_string('secondtabname', 'moviemasher'));

    //==> third tab
    $row[] = new tabobject(moviemasher_TAB3, $baseurl.moviemasher_TAB3, get_string('thirdtabname', 'moviemasher'));



    //==> tab definition
    $tabs[] = $row; //$tabs is an array of arrays

    $inactive[] = $currenttab;
    $activated[] = $currenttab;

    switch ($currenttab) {
    case moviemasher_TAB1:
        break;
    case moviemasher_TAB2:
        $inactive[] = $currentpagename;
        $activated[] = $currentpagename;

        $baseurl = $CFG->wwwroot.'/mod/moviemasher/view.php?id='.$cm->id.'&amp;tab='.moviemasher_TAB2.'&amp;pag=';

        $row  = array();
        $strlabel = get_string('tab2page1', 'moviemasher');
        $row[] = new tabobject(moviemasher_TAB2_PAGE1NAME, $baseurl.moviemasher_TAB2_PAGE1, $strlabel);

        $strlabel = get_string('tab2page2', 'moviemasher');
        $row[] = new tabobject(moviemasher_TAB2_PAGE2NAME, $baseurl.moviemasher_TAB2_PAGE2, $strlabel);

        $strlabel = get_string('tab2page3', 'moviemasher');
        $row[] = new tabobject(moviemasher_TAB2_PAGE3NAME, $baseurl.moviemasher_TAB2_PAGE3, $strlabel);

        $strlabel = get_string('tab2page4', 'moviemasher');
        $row[] = new tabobject(moviemasher_TAB2_PAGE4NAME, $baseurl.moviemasher_TAB2_PAGE4, $strlabel);

        $strlabel = get_string('tab2page5', 'moviemasher');
        $row[] = new tabobject(moviemasher_TAB2_PAGE5NAME, $baseurl.moviemasher_TAB2_PAGE5, $strlabel);

        $tabs[] = $row;
        break;
    case moviemasher_TAB3:
        $inactive[] = $currentpagename;
        $activated[] = $currentpagename;

        $baseurl = $CFG->wwwroot.'/mod/moviemasher/view.php?id='.$cm->id.'&amp;tab='.moviemasher_TAB3.'&amp;pag=';

        $row  = array();
		$strlabel = get_string('tab3page1', 'moviemasher');
		$row[] = new tabobject(moviemasher_TAB3_PAGE1NAME, $baseurl.moviemasher_TAB3_PAGE1, $strlabel);

		$strlabel = get_string('tab3page2', 'moviemasher');
		$row[] = new tabobject(moviemasher_TAB3_PAGE2NAME, $baseurl.moviemasher_TAB3_PAGE2, $strlabel);

        $tabs[] = $row;
        break;
    default:
        echo 'I am at the row '.__LINE__.' of the file '.__FILE__.'<br />';
        echo 'I have $currenttab = '.$currenttab.'<br />';
        echo 'But the right "case" is missing<br />';
    }
/*print_object($tabs);
print_object($inactive);
print_object($activated);*/

    print_tabs($tabs, $currenttab, $inactive, $activated);
?>