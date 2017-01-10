<?php
/*
 * Your installation or use of this SugarCRM file is subject to the applicable
 * terms available at
 * http://support.sugarcrm.com/Resources/Master_Subscription_Agreements/.
 * If you do not agree to all of the applicable terms or do not have the
 * authority to bind the entity as an authorized representative, then do not
 * install or use this SugarCRM file.
 *
 * Copyright (C) SugarCRM Inc. All rights reserved.
 */
require __DIR__ . '/vendor/autoload.php';
use JonnyW\PhantomJs\Client;

// POST Values
$chartConfig = $_POST['CHART_CONFIG'];
$reportDatum = $_POST['REPORT_DATUM'];

// Client
$client = Client::getInstance();
$client->getProcedureCompiler()->enableCache();
$client->isLazy();

// Request
$url = 'http://localhost/phantom2png/chart.php';
$request  = $client->getMessageFactory()->createCaptureRequest($url);

$file = 'chart.png';
$request->setOutputFile($file);

$top    = 8;
$left   = 8;
$width  = 600;
$height = 600;
$request->setCaptureDimensions($width, $height, $top, $left);

$request->setTimeout(5000);

// Passthrough Headers
$request->addHeader('CHART_CONFIG', json_encode($chartConfig));
$request->addHeader('REPORT_DATUM', json_encode($reportDatum));

// Response
$response = $client->getMessageFactory()->createResponse();

// Send
$client->send($request, $response);

// Output Base64 image data
$base64 = base64_encode(file_get_contents($file));
echo $base64;
?>
