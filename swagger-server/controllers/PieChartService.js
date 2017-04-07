'use strict';

exports.piePOST = function(args, res, next) {
  /**
   * Capture pie chart image.
   * This entry point is specically for the pie chart type.
   *
   * report PieChartRequest 
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

