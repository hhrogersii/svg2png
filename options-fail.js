//TEST WEB SERVER MODULE
// curl http://localhost:8080
// returns <html>
// curl -v -X OPTIONS 127.0.0.1:8080
// returns
// * Rebuilt URL to: 127.0.0.1:8080/
// *   Trying 127.0.0.1...
// * Connected to 127.0.0.1 (127.0.0.1) port 8080 (#0)
// > OPTIONS / HTTP/1.1
// > Host: 127.0.0.1:8080
// > User-Agent: curl/7.43.0
// > Accept: */*
// >
// < HTTP/1.1 400 Bad Request
// < Content-Type: text/plain
// < Content-Length: 59
// < Connection: close
// <
// Error 400: Bad Request
// * Closing connection 0
var webserver = require('webserver');
var server = webserver.create();
var service = server.listen('127.0.0.1:8080', function(request, response) {
    response.statusCode = 200;
      // Set up response
    response.setHeader('Content-Type', 'text/plain');
    // Since service is running on a domain different than request
    response.setHeader('Access-Control-Allow-Headers', '*');
    response.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    response.setHeader('Access-Control-Allow-Origin', '*');

    response.write('<html><body>Hello!</body></html>');
    response.close();
});
