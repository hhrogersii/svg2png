var page = require('webpage').create();
var system = require('system');
var address, selector, output;

if (system.args.length < 4) {
    console.log('Usage: ' + system.args[0] + ' <some URL> <some selector> <destination.png>');
    phantom.exit();
}

address = system.args[1];
selector = system.args[2];
output = system.args[3];

page.viewportSize = {width: 600, height: 600};

page.open(address, function(status) {
    if (status !== 'success') {
        console.log('Unable to access the network!');
        phantom.exit();
    } else {
        var dimensions = page.evaluate(function (selector) {
            var el = document.querySelector(selector);
            var curTop = 0, curLeft = 0, obj = el;

            do {
                curLeft += obj.offsetLeft;
                curTop += obj.offsetTop;
            } while (obj = obj.offsetParent);

            return {
                height: el.offsetHeight,
                width: el.offsetWidth,
                top: curTop,
                left: curLeft
            }
        }, selector);

        page.clipRect = {
            top: dimensions.top,
            left: dimensions.left,
            width: dimensions.width,
            height: dimensions.height
        };
        page.viewportSize = {
            width: dimensions.width,
            height: dimensions.height
        };
        page.zoomFactor = 1;

		window.setTimeout(function () {
			page.render(output, {format: 'PNG', quality: 100});
			phantom.exit();
		}, 200);
    }
});
