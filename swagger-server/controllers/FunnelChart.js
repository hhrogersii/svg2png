'use strict';

var url = require('url');

var FunnelChart = require('./FunnelChartService');

module.exports.funnelPOST = function funnelPOST (req, res, next) {
  FunnelChart.funnelPOST(req.swagger.params, res, next);
};
