<?php
    defined('moviemasher_INCLUDE_TEST') OR die('not allowed');

    $currenttab  = optional_param('tab',moviemasher_TAB1,PARAM_INT);
    $currentpage = optional_param('pag',1              ,PARAM_INT);
	switch ($currenttab) {
	case moviemasher_TAB1:
	case moviemasher_TAB2:
		switch ($currentpage) {
		case moviemasher_TAB2_PAGE1:
			$currentpagename = moviemasher_TAB2_PAGE1NAME;
			break;
		case moviemasher_TAB2_PAGE2:
			$currentpagename = moviemasher_TAB2_PAGE2NAME;
			break;
		case moviemasher_TAB2_PAGE3:
			$currentpagename = moviemasher_TAB2_PAGE3NAME;
			break;
		case moviemasher_TAB2_PAGE4:
			$currentpagename = moviemasher_TAB2_PAGE4NAME;
			break;
		case moviemasher_TAB2_PAGE5:
			$currentpagename = moviemasher_TAB2_PAGE5NAME;
			break;
		default:
			echo 'I am at the row '.__LINE__.' of the file '.__FILE__.'<br />';
			echo 'I have $currentpage = '.$currentpage.'<br />';
			echo 'But the right "case" is missing<br />';
		}
		break;
	case moviemasher_TAB3:
		switch ($currentpage) {
		case moviemasher_TAB3_PAGE1:
			$currentpagename = moviemasher_TAB3_PAGE1NAME;
			break;
		case moviemasher_TAB3_PAGE2:
			$currentpagename = moviemasher_TAB3_PAGE2NAME;
			break;
		default:
			echo 'I am at the row '.__LINE__.' of the file '.__FILE__.'<br />';
			echo 'I have $currentpage = '.$currentpage.'<br />';
			echo 'But the right "case" is missing<br />';
		}
		break;
	default:
		echo 'I am at the row '.__LINE__.' of the file '.__FILE__.'<br />';
		echo 'I have $currenttab = '.$currenttab.'<br />';
		echo 'But the right "case" is missing<br />';
	}
    
?>