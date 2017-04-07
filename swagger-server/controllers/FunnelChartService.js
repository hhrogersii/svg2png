'use strict';

exports.funnelPOST = function(args, res, next) {
  /**
   * Capture funnel chart image.
   * This entry point is specically for the funnel chart type.
   *
   * report FunnelChartRequest 
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

