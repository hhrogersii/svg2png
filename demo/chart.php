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
  $reportDatum = json_decode($headers['REPORT_DATUM']);

} else {
  // else define variables for testing

  $post = file_get_contents('post.json');
  $json = json_decode($post);

  $chartConfig = $json->CHART_CONFIG;
  $reportDatum = $json->REPORT_DATUM;
}
?>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=720" />
  <title>Chart</title>
  <link rel="stylesheet" type="text/css" href="../service/resources/sucrose.min.css" />
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

<div id="chart_container" class="sc-chart">
  <svg></svg>
</div>

<script src="../service/resources/d3v4.min.js"></script>
<script src="../service/resources/d3fc-rebind.min.js"></script>
<script src="../service/resources/sucrose.min.js"></script>

<script type="text/javascript">
var config = <?php echo json_encode($chartConfig); ?>;
var datum = <?php echo json_encode($reportDatum); ?>;

window.onload = function() {
    // Define chart model & class name
    var model = sucrose.charts[config.type + 'Chart']();
    var classname = 'sc-chart-' + config.type;

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
    d3v4.select('#chart_container')
        .style('width', config.width + 'px')
        .style('height', config.height + 'px')
        .classed(classname, true);

    // Bind data to svg and call model
    d3v4.select('#chart_container svg')
      .datum(datum)
      .call(model);
  };
</script>
</body>
</html>
