'use strict';

var url = require('url');

var PieChart = require('./PieChartService');

module.exports.piePOST = function piePOST (req, res, next) {
  PieChart.piePOST(req.swagger.params, res, next);
};
