'use strict';

// Concurrency testing for Report2Chart micro-service
// Run with node: node concurrency.js
// Run with npm: npm test
// https://github.com/alexfernandez/loadtest
var loadtest = require('loadtest');
var body = require('../resources/post.json');

var options = {
        url: 'https://svg2png.arch.sugarcrm.io/v1/pie',
        maxRequests: 100,
        maxSeconds: 60000,
        // requestsPerSecond: 10,
        method: 'POST',
        concurrency: 10,
        body: body,
        agentKeepAlive: true,
        headers: {
            accept: 'text/plain'
        },
        contentType: 'text/plain;charset=UTF-8'
    };

loadtest.loadTest(options, function(error, result) {
    if (error) {
        return console.error('Got an error: %s', error);
    }
    console.log('Tests run successfully');
    console.log(JSON.stringify(result, null, '  '));
});
