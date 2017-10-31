'use strict';

var url = require('url');

var MultibarChart = require('./MultibarChartService');

module.exports.multibarPOST = function multibarPOST (req, res, next) {
  MultibarChart.multibarPOST(req.swagger.params, res, next);
};
