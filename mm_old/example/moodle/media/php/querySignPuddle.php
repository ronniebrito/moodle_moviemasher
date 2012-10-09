<?php

$search =  (empty($_GET['palavra']) ? '' : $_GET['palavra']);


if (substr_count($search," ") >= 1){
	$searches = explode(" ",$search);
}else{
	$searches[0] = $search;
}


if($searches[0]==""){  die();}

//$terms = file_get_contents("http://www.signbank.org/signpuddle2.0/data/spml/sgn46.spml");
$terms = file_get_contents("sgn46.spml");

$bsw .= "";
for ($count = 0 ; $count < count($searches); $count++){

	$search = $searches[$count];	


	
	//$bsw .= $search;
	//echo $search;  
	/*$pattern = "/<entry[^<entry].*?>[^<entry]*?<term>(AS[^<entry]*?\d\d\d)<\/term>[^<entry]*?<term>[^<entry]*\<\!\[CDATA\[".$search."\]\]\>.*?<\/term>.*?/is";
*/
	$pattern = "/<entry[^<entry].*?>[^<entry]*?<term>(AS[^<entry]*?\d\d\d)<\/term>[^<entry]*?<term>[^<entry]*\<\!\[CDATA\[".$search."\]\]\>.*?<\/term>.*?/is";

	//echo $pattern; die();
	$count2 = preg_match_all($pattern,$terms,$matches);

	


	$fsw = $matches[1][0];
	if($matches[1]!=null){ $bsw .= "0fb"; }


		//AS20311S20359S20c01S21405M529x521S20359494x480S21405489x509S20311508x494S20c01472x494

		$aux  = explode('M',$fsw);

		//M529x521S20359494x480S21405489x509S20311508x494S20c01472x494 

		$symbols  = explode("S",$aux[1]);

		$sym_num = count($symbols)-1;

		for($i =1; $i<= $sym_num; $i++){	
	
			$key = substr($symbols[$i],0,3);
			$fill = substr($symbols[$i],3,1);
			$rot = substr($symbols[$i],4,1);
			$x = substr($symbols[$i],5,3) ;
			$y = substr($symbols[$i],9,3);
			//echo "key is". $key. " filled with ".$fill." rotation=".$rot ."at x=".$x . " and y =". $y;
			$bsw .= $key;	
			$bsw .= dechex($fill + 908);
			$bsw .= dechex($rot + 914);
			$bsw .= dechex($x + 1229 -500);
			$bsw .= dechex( $y + 1229 -500 );
		}
	
}

//var_dump($fsw);
//var_dump($aux);
//var_dump($symbols);
require_once(dirname( dirname( dirname(dirname(dirname(dirname(dirname(dirname(__FILE__)))))))).'/config.php');
file_get_contents($CFG->wwwroot."/mod/moviemasher/binarySignWriting.php?palavra=".$bsw );	

echo $bsw;
?>
