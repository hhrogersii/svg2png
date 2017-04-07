'use strict';

var url = require('url');

var Default = require('./DefaultService');

module.exports.funnelOPTIONS = function funnelOPTIONS (req, res, next) {
  Default.funnelOPTIONS(req.swagger.params, res, next);
};

module.exports.lineOPTIONS = function lineOPTIONS (req, res, next) {
  Default.lineOPTIONS(req.swagger.params, res, next);
};

module.exports.multibarOPTIONS = function multibarOPTIONS (req, res, next) {
  Default.multibarOPTIONS(req.swagger.params, res, next);
};

module.exports.pieOPTIONS = function pieOPTIONS (req, res, next) {
  Default.pieOPTIONS(req.swagger.params, res, next);
};
