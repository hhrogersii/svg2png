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
use JonnyW\PhantomJs\DependencyInjection\ServiceContainer;

// POST Values
$chartConfig = $_POST['CHART_CONFIG'];
$reportDatum = $_POST['REPORT_DATUM'];

// Save for DEV
// $chartConfig = json_decode(json_encode(array(
//     'type' => 'pie',
//     'direction' => 'ltr',
//     'showTitle' => true,
//     'showLegend' => true,
//     'showLabels' => true,
//     'donut' => true,
//     'donutRatio' => 0.5,
//     'hole' => 10,
//     'maxRadius' => 250,
//     'minRadius' => 100,
//     'rotateDegrees' => 0,
//     'arcDegrees' => 360,
//     'colorData' => 'default',
//   )));
// $reportDatum = json_decode(file_get_contents('resources/pie_data.json'));

// Partials
$location = './partials';
$serviceContainer = ServiceContainer::getInstance();
$procedureLoader = $serviceContainer->get('procedure_loader_factory')->createProcedureLoader($location);

// Client
$client = Client::getInstance();
$client->getProcedureCompiler()->enableCache();
// $client->getProcedureCompiler()->clearCache();
$client->getProcedureLoader()->addLoader($procedureLoader);
$client->isLazy();

// Request
$url = 'http://localhost/phantom2png/chart.php';
$request = $client->getMessageFactory()->createCaptureRequest($url);
$request->setTimeout(5000);

$t = 8; $l = 8; $w = 600; $h = 600;
$request->setCaptureDimensions($w, $h, $t, $l);

// Passthrough Headers
$request->addHeader('CHART_CONFIG', $chartConfig);
$request->addHeader('REPORT_DATUM', $reportDatum);

// Response
$response = $client->getMessageFactory()->createResponse();

// Send
$client->send($request, $response);

echo $response->content;
?>
