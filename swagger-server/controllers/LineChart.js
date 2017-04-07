'use strict';

var url = require('url');

var LineChart = require('./LineChartService');

module.exports.linePOST = function linePOST (req, res, next) {
  LineChart.linePOST(req.swagger.params, res, next);
};
