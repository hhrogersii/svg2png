# PhantomJs to PNG Service POC

## Overview
A *service* that will generate a Base64 encoded PNG image file from a D3 chart using PHP, [PhantomJS](|http://phantomjs.org/), and [phantomjs-php](http://jonnnnyw.github.io/php-phantomjs/).

## Request
The *service* expects a POST request to the `service.php` URI with two (for now) data parameters:
- `CHART_CONFIG` a JSON object that contains a required chart `type` property and any needed method names to call and values to apply to the D3 chart model as key/value pairs (e.g., `showTitle: true`).
- `REPORT_DATUM` a JSON object that contains the report data as normally constructed in the `Sugar` client application with `properties` and `data` properties.
- ~~`POSTBACK`~~ not yet implemented but expected to post back the Base64 encoded image to the client application.

## Response
The *service* returns the captured chart image as a Base64 encoded string back to the client application. In this POC, the response string is set as the DataURI for an image but could be saved by the client application using internal methods.

## Basic usage from command line
During development it is helpful to verify the successful phantomjs capture of the various Sugar NVD3 chart types that will be tested via the service. The service source URI `chart.php` can be edited as needed and called directly from the command line (Node.js is not needed). An option will be added later to provide the chart config as a JSON object.

```sh
// Make sure phantomjs is installed globally
$ brew install phantomjs
// phantomjs [script] [source_url] [selector] [target_file]
$ phantomjs domshot.js http://localhost/phantom2png/chart.php .nv-chart pie.png
```

There should now be a new PNG image of the chart.

<img src="pie.png" width="600" height="600">

## PHP service using php-phanomjs wrapper
This service was written using http://jonnnnyw.github.io/php-phantomjs/ as a helper around the PhantomJs binary.

```sh
// Use composer to install php-phantomjs along with PhantomJS locally.
curl -s http://getcomposer.org/installer | php
php composer.phar install
```
Test the POC by opening a browser at:

`request.php`

Which defines the test chart config and report data objects and executes a AJAX POST to:

`service.php`

Which uses php-phantomjs to generate a PhantomJS script that opens a request for the page:

`chart.php`

Which runs D3 code to render the chart in SVG and is rasterized by PhantomJS script running in:

`service.php`

Which then Base64 encodes the image and echos the string back to:

`request.php`

Which sets appends a new image to its body using a DataURI as its source.

##Chart config parameter
The Chart.php page expects a JSON CHART_CONFIG POST parameter that sets the chart type and calls any number of optional methods to configure the chart model. Every chart type has a number of chart config options. Refer to the `include/SugarCharts/nvd3/js/sugarCharts.js` file to see common options for each chart type.

| Method | Required | Acceptable Values | Description |
| ------ | -------- | ----------------- | ----------- |
|`type`| (required) | ['pie'\|'multibar'\|'funnel'\|'line'] | Defines the NVD3 chart model type to load |
| colorData | (required) | ['default'\|'data'\|'classes'] | Sets the color palette options.|
| direction | (optional) | ['ltr'\|'rtl'] | Sets the rendering direction |
| showTitle | (optional) | [true\|false] | ... |
| showLegend | (optional) | [true\|false] | ... |
| showLabels | (optional) | [true\|false] | ... |

To set these options, add a key/value pair with the key equal to the name of the method. This is an example of options for configuring the pie chart type as a donut chart.

```json
{
  "type": "pie",
  "colorData": "default",
  "direction": "ltr",
  "showTitle": true,
  "showLegend": true,
  "showLabels": true,

  "donut": true,
  "donutRatio": 0.5,
  "hole": 10,
  "maxRadius": 250,
  "minRadius": 100,
  "rotateDegrees": 0,
  "arcDegrees": 360,
}
```

## Report data parameter
The the `include/SugarCharts/nvd3/js/sugarCharts.js` file for the expected report data structure. Here is the datum used for the POC.

```json
{
  "properties": {
    "title": "All Opportunities by Lead Source"
  },
  "data": [
    {
      "key": "Undefined",
      "value": 100
    },
    {
      "key": "Cold Call",
      "value": 0
    },
    {
      "key": "Existing Customer",
      "value": 75
    },
    {
      "key": "Self Generated",
      "value": 140
    },
    {
      "key": "Walk In",
      "value": 10
    },
    {
      "key": "Employee",
      "value": 160
    },
    {
      "key": "Partner",
      "value": 100
    },
    {
      "key": "Public Relations",
      "value": 145
    },
    {
      "key": "Other",
      "value": 9
    }
  ]
}
```
