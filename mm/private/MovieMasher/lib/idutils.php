<?php

function unique_id($seed)
{
	return md5(uniqid(time() . $seed));
}

?>