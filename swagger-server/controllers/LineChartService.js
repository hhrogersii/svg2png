'use strict';

exports.linePOST = function(args, res, next) {
  /**
   * Capture line chart image.
   * This entry point is specically for the line chart type.
   *
   * report LineChartRequest 
   * returns ImageResponse
   **/
  var examples = {};
  examples['application/json'] = { };
  if (Object.keys(examples).length > 0) {
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify(examples[Object.keys(examples)[0]] || {}, null, 2));
  } else {
    res.end();
  }
}

