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
$headers = apache_request_headers();

if (isset($headers['CHART_CONFIG'])) {
  // If page is called by service screen capture with header variables

  $chartConfig = json_decode($headers['CHART_CONFIG']);
  $reportDatum = $headers['REPORT_DATUM'];

} else {
  // else define variables for testing

  $chartConfig = json_decode(json_encode(array(
    'type' => 'pie',
    'width' => 720,
    'height' => 480,
    'zoom' => 1,
    'direction' => 'ltr',
    'showTitle' => true,
    'showLegend' => true,
    'showLabels' => true,
    'tooltips' => false,
    'donut' => true,
    'donutRatio' => 0.5,
    'hole' => 10,
    'maxRadius' => 250,
    'minRadius' => 100,
    'rotateDegrees' => 0,
    'arcDegrees' => 360,
    'colorData' => 'default',
  )));

  $reportDatum = file_get_contents('pie_data.json');

}
?>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=600" />
  <title>Chart</title>
  <link rel="stylesheet" type="text/css" href="../resources/nvd3_print.css" />
  <style>
    body {
      background-color: #eef5ff;
    }
    #chart_container {
      width: 720px;
      height: 480px;
    }
  </style>
</head>
<body>

<div id="chart_container" class="nv-chart">
  <svg></svg>
</div>

<script src="../resources/d3.min.js"></script>
<script src="../resources/nv.d3.min.js"></script>

<script type="text/javascript">
var config = <?php echo json_encode($chartConfig); ?>;
var datum = <?php echo $reportDatum; ?>;

window.onload = function() {
    // Define chart model & class name
    var model = nv.models[config.type + 'Chart']();
    var classname = 'nv-chart-' + config.type;

    // Apply configuration settings
    // Get method names from config keys
    var methods = Object.getOwnPropertyNames(config);
    // This will be replaced with a model.config(config) in future release
    for (var i = 0, l = methods.length; i < l; i += 1) {
      var method = methods[i];
      if (model[method]) {
        model[method](config[method]);
      }
    }

    // Add chart type class to container
    d3.select('#chart_container')
        .style('width', config.width + 'px')
        .style('height', config.height + 'px')
        .classed(classname, true);

    // Bind data to svg and call model
    d3.select('#chart_container svg')
      .datum(datum)
      .call(model);
  };
</script>
</body>
</html>
