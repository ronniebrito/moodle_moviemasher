<?php

function floatcmp($f1,$f2, $precision = 2) // are 2 floats equal
{
    $e = pow(10, $precision);
    $i1 = round($f1 * $e);
    $i2 = round($f2 * $e);
    return ($i1 == $i2);
}

function floatgtr($big,$small, $precision = 2) // is one float bigger than another
{
    $e = pow(10, $precision);
    $ibig = round($big * $e);
    $ismall = round($small * $e);
    return ($ibig > $ismall);
}

function floatgtre($big,$small, $precision = 2) // is on float bigger or equal to another
{
    $e = floatval(pow(10, $precision));
    $ibig = round($big * $e);
    $ismall = round($small * $e);
    return ($ibig >= $ismall);
}

function floatmax($a, $b, $precision = 2)
{
	if (floatgtr($a, $b, $precision)) return $a;
	return $b;
}

function floatmin($a, $b, $precision = 2)
{
	if (floatgtr($a, $b, $precision)) return $b;
	return $a;
}

function floatsort($a, $b)
{
	if (floatgtr($a[0], $b[0])) return 1;
	if (floatcmp($a[0], $b[0])) return 0;
	return -1;
}

?>