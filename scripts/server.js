var express = require('express');
var path = require('path');
var util = require('util');
var http = require('http');

var config = {};
try {
 config = require('./config');
} catch(err){
	throw err;
}

console.log("settings: " + util.inspect(config));

var app = express();
app.use(express.logger());
app.use('/media', express.static( path.resolve(__dirname, config.folder) ));

var server = http.createServer(app)
server.on("listening", function(){
    console.log("Server running, listening on port: "+config.port)
})
server.listen(config.port);
