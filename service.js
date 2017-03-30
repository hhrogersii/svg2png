var port = 8910;
var server = require('webserver').create();
// var fs = require('fs');
// var url = 'file://' + fs.absolute('./chart.html');
var url = 'resources/chart.html';

var chartRender = function(config, datum) {
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

var service = server.listen(port, function(request, response) {
    console.log('request: ', JSON.stringify(request, null, "  "));

    // Set up response
    response.setHeader('Content-Type', 'text/plain');
    // Since service is running on a domain different than request
    response.setHeader('Access-Control-Allow-Origin', '*');
    response.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    response.setHeader('Access-Control-Allow-Headers', '*');

//--api-enable-cors=true
//curl -v -X OPTIONS 127.0.0.1:8910

    if (request.method === 'OPTIONS') {
        response.statusCode = 200;
        // Close to complete request
        response.close();
        return;
    }
    var post = JSON.parse(request.post);
    var chartConfig = post.CHART_CONFIG;
    var reportDatum = post.REPORT_DATUM;

    var zoom = chartConfig.zoom || 1;
    var width = chartConfig.width || (720 * zoom);
    var height = chartConfig.height || (480 * zoom);

    var page = require('webpage').create();
    var handleError = function(code, msg) {
            response.statusCode = code;
            response.write(msg);
            response.close();
            page.close();
            phantom.exit();
        };

    // Define boundaries of capture region
    page.clipRect = {
            top: 0,
            left: 0,
            width: width,
            height: height
        };
    // Clip * zoom
    page.viewportSize = {
            width: width,
            height: height
        };
    // A zoom factor of 1 for screen display
    page.zoomFactor = zoom;

    // Load the chart page
    page.open(url, function(status) {

        if (status !== 'success') {
            handleError(500, 'Unable to load chart page.');
            return;
        }

        try {
            // Render chart with config and data inside page context
            page.evaluate(chartRender, chartConfig, reportDatum);
        } catch(e) {
            handleError(500, e.message);
            return;
        }

        // Need to wait a bit to allow CSS to catch up
        // thanks web fonts
        window.setTimeout(function() {
            // Everything's A-OK
            response.statusCode = 200;
            // Send encoded image
            response.write(page.renderBase64('PNG'));
            // Close to complete request
            response.close();

            // Close to release memory
            page.close();
        }, 50);
    });
});

if (service) {
  console.log('Web server running on port ' + port);
} else {
  console.log('Error: Could not create web server listening on port ' + port);
  phantom.exit();
}
