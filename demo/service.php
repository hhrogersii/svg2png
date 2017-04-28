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

  $post = file_get_contents('post.json');
  $json = json_decode($post);

  $chartConfig = $json->CHART_CONFIG;
  $reportDatum = $json->REPORT_DATUM;

?>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Request Chart Image</title>
  <style>
    body {
      background-color: #eef5ff;
    }
  </style>
</head>
<body id="body">
<script type="text/javascript">
    var params = {
        REPORT_DATUM: <?php echo json_encode($reportDatum); ?>,
        CHART_CONFIG: <?php echo json_encode($chartConfig); ?>
    };

    // Use for verification of phantomjs script
    // var url = 'http://localhost:8910/';
    // User for verification of docker image
    var url = 'http://127.0.0.1:8910/v1/pie';
    // Use for verification of api specification
    //
    // Use for verification of minikube externally
    // var url = 'http://192.168.99.100:30604/api/v1/pie';
    // Use for verification of minikube internally
    // var url = '<?php echo getenv('REPORT2CHART_SVC'); ?>';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.setRequestHeader('Accept', 'text/plain');
    xhr.setRequestHeader('Content-Type', 'text/plain;charset=UTF-8');
    xhr.onreadystatechange = function() {
        if (xhr.readyState != 4 || xhr.status != 200) {
            return;
        }
        var image = '<img src="data:image/png;base64,' + xhr.responseText + '">';
        document.getElementById('body').innerHTML += image;
    };

    xhr.send(JSON.stringify(params));
</script>
</body>
</html>