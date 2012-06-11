<?php
    defined('moviemasher_INCLUDE_TEST') OR die('not allowed');

	switch ($currenttab) {
	case moviemasher_TAB1:
        include_once('./tab1/page1.php');
		break;
	case moviemasher_TAB2:
		switch ($currentpage) {
		case moviemasher_TAB2_PAGE1:
            include_once('./tab2/page1.php');
			break;
		case moviemasher_TAB2_PAGE2:
            include_once('./tab2/page2.php');
			break;
		case moviemasher_TAB2_PAGE3:
            include_once('./tab2/page3.php');
			break;
		case moviemasher_TAB2_PAGE4:
            include_once('./tab2/page4.php');
			break;
		case moviemasher_TAB2_PAGE5:
            include_once('./tab2/page5.php');
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
            include_once('./tab3/page1.php');
			break;
		case moviemasher_TAB3_PAGE2:
            include_once('./tab3/page2.php');
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