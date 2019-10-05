<?php

/*
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
*/

$code=$_POST["code"];

$temp = tmpfile();
fwrite($temp, $code);
$path = stream_get_meta_data($temp)['uri'];

//echo($path . $code);

exec("racket $path 2>&1", $result);
fclose($temp);
echo "".implode("\n",$result);
