var http = require('http');

var port          = 4000;
var remoteCluster = "ocp-070d31d9cf0761a13fcebd4a97861c1a-0000.eu-de.containers.appdomain.cloud";
var remotePort    = 80;
//var remoteServer = "localhost";
//var remotePort   = 4000;
// Public routes
// http://tenant1-demo-tenant1-demo.mycluster-fra02-b-681729-070d31d9cf0761a13fcebd4a97861c1a-0000.eu-de.containers.appdomain.cloud/
// http://tenant2-demo-tenant2-demo.mycluster-fra02-b-681729-070d31d9cf0761a13fcebd4a97861c1a-0000.eu-de.containers.appdomain.cloud/
// http://tenant3-demo-tenant3-demo.mycluster-fra02-b-681729-070d31d9cf0761a13fcebd4a97861c1a-0000.eu-de.containers.appdomain.cloud/
// Private services
// http://tenant1-demo.tenant1-demo:3000/
// http://tenant2-demo.tenant2-demo:3000/
// http://tenant3-demo.tenant3-demo:3000/

/*

*/

function parseCookies(request) {
    var list = {},
        rc = request.headers.cookie;

    rc && rc.split(';').forEach(function (cookie) {
        var parts = cookie.split('=');
        list[parts.shift().trim()] = decodeURI(parts.join('='));
    });

    return list;
}

function getTenantNameAndRemoteURL(request) {
    var tenantName = '';
    var remoteURL = '';

    var urlArray = request.url.split('/');
    //console.log("DEBUG! urlArray = ", urlArray);

    if (urlArray[1] == 'tenant') {
        tenantName = urlArray[2];
        urlArray.shift(); urlArray.shift(); urlArray.shift();
        if (urlArray.length == 1)
            urlArray.unshift('');
    }
    else {
        var cookies = parseCookies(request);
        tenantName = cookies['tenant'];
    }
    remoteURL = urlArray.join('/');
    
    return [ tenantName, remoteURL ] ;
}

function prepareRequestOptions(request, tenantName, remoteURL) {
    
    var newHeaders = request.headers;
    if ( remoteCluster !== "" )
        var remoteServer = tenantName + "-" + tenantName + "." + remoteCluster;
    else
        var remoteServer = tenantName + "-" + tenantName
    
    newHeaders['host'] = remoteServer;

    var options = {
        host: remoteServer,
        port: remotePort,
        path: remoteURL,
        method: request.method,
        headers: newHeaders
    }
    return options
}

http.createServer( (proxyReq, proxyRes) => {

    var [ tenantName, remoteURL ] = getTenantNameAndRemoteURL( proxyReq );
    // console.log("DEBUG! tenantName : ", tenantName, ' remoteURL : ', remoteURL, ' method : ', proxyReq.method);

    var options = prepareRequestOptions(proxyReq, tenantName, remoteURL);
    // console.log("DEBUG! options", options);

    var remoteRequest = http.request(options, (remoteRes) => {
        var headers = remoteRes.headers;
        
        // set cookie indicating tenant name 
        if (typeof headers['set-cookie'] !== 'undefined') {
            headers['set-cookie'].push('tenant=' + tenantName + '; path=/; HttpOnly');
        }

        // handle redirects
        if (typeof (headers.location) !== 'undefined')
            headers.location = '/tenant/' + tenantName + headers.location;

        proxyRes.writeHead(remoteRes.statusCode, headers);

        remoteRes.on('data', (chunk) => {
            proxyRes.write(chunk);
        });

        remoteRes.on('end', () => {
            proxyRes.end()
        });
    });

    proxyReq.on("data", (chunk) => {
        remoteRequest.write(chunk);
    });

    proxyReq.on("end", () => {
        remoteRequest.end();
    });

}).listen(port, () => {
    console.log("Server is listening on port", port);
});
