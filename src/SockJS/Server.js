"use strict";

const sockjs = require('sockjs');

var sockjsOpts = {
  sockjs_url: 'http://cdn.jsdelivr.net/sockjs/1.0.1/sockjs.min.js'
};

// Server methods
exports.createServer_ = function () {
  // TODO: support options
  return sockjs.createServer(sockjsOpts);
}
exports.installHandlers_ = function(sockjsServer, httpServer, prefix) {
  sockjsServer.installHandlers(httpServer, { prefix: prefix });
}
exports.onConnection_ = function(sockjsServer, handler) {
  sockjsServer.on('connection', handler);
}

// Connection methods
exports.write_ = function(conn, message) {
  conn.write(message);
}
exports.end_ = function(conn) {
  conn.end();
}
exports.onData_ = function(conn, handler) {
  conn.on('data', handler);
}
exports.onClose_ = function(conn, handler) {
  conn.on('close', handler);
}
