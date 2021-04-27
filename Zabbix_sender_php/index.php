<?php

error_reporting(E_ALL);
require_once 'sender.php';

$server = $_REQUEST['server'];
$key = $_REQUEST['key'] ;
$value = $_REQUEST['value'] ;

$sender = new Sender('localhost', 10051);
$sender->addData($server, $key, $value);
$sender->send();

$result = $sender->getResponse();

if ($result['response'] == 'success') 
{
    echo $result['info'] . "\r\n";

    $infoArray = preg_split('[;]', $result['info']);
    $kv = preg_split('[:]', $infoArray[1]);
    $failedCount = intval(trim($kv[1]));

    if ($failedCount == 0)
    {
	http_response_code(200);
    }
    else
    {
	http_response_code(406);
    }
}

?>
