<?php
/*
 * Your installation or use of this SugarCRM file is subject to the applicable
 * terms available at
 * http://support'sugarcrm'com/Resources/Master_Subscription_Agreements/'
 * If you do not agree to all of the applicable terms or do not have the
 * authority to bind the entity as an authorized representative, then do not
 * install or use this SugarCRM file'
 *
 * Copyright ' = C, SugarCRM Inc' All rights reserved'
 */
// Generated by Report or in SugarCharts
$reportDatum = json_decode(file_get_contents('../resources/pie_data.json'));

// Defined in Reporter instance or in SugarCharts
$chartConfig = array(
    'type' => 'pie',
    'width' => 720,
    'height' => 480,
    'zoom' => 1,
    'direction' => 'ltr',
    'showTitle' => true,
    'showLegend' => true,
    'showLabels' => true,
    'donut' => true,
    'donutRatio' => 0.5,
    'hole' => 10,
    'maxRadius' => 250,
    'minRadius' => 100,
    'rotateDegrees' => 0,
    'arcDegrees' => 360,
    'colorData' => 'default',
  );
?>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Request Chart Image</title>
  <style>
    pre {
      white-space: pre-wrap;
      width: 640px;
      font-size: 11px;
      padding: 12px;
      border: 1px solid #ddd;
      box-sizing: border-box;
    }
  </style>
</head>
<body>
<pre id="pre"></pre>
<script type="text/javascript">
    var params = {
        REPORT_DATUM: <?php echo json_encode($reportDatum); ?>,
        CHART_CONFIG: <?php echo json_encode($chartConfig); ?>
    };

    var t0 = new Date();
    var i0 = 0;
    var interations = 100;
    var total = 0;
    var pre = document.getElementById('pre');

    var ajax = function() {
        var xhr = new XMLHttpRequest();
        var url = 'https://svg2png.arch.sugarcrm.io/v1/pie';
        // var url = 'http://localhost:8910/';
        xhr.open('POST', url, true);
        xhr.onreadystatechange = function(response) {
            if (xhr.readyState != 4 || xhr.status != 200) {
                return;
            }
            var t1 = new Date();
            var t2 = t1 - t0;
            total += t2;
            if (i0 % 10 === 0) {
                pre.innerHTML += '| ';
            }
            pre.innerHTML += (
                '0'.repeat(3 - i0.toString().length) + i0 +
                ':' +
                '0'.repeat(3 - t2.toString().length) + t2 +
                '; '
            );
            if (i0 % 10 === 9) {
                pre.innerHTML += '| ';
            }
            t0 = t1;
            i0 += 1;
            if (i0 < interations) {
              ajax();
            } else {
                pre.innerHTML += ("{Average: " + (total/interations) + "}");
            }
        };
        xhr.send(JSON.stringify(params));
    };

    ajax();
</script>
</body>
</html>
