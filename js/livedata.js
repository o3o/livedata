/* jslint esversion: 6 */

/* jslint node: true */

/* global  WebSocket,  $  */

'use strict';

function getBaseURL () {
  var href = window.location.href.substring(7); // strip "http://"
  var idx = href.indexOf('/');
  return 'ws://' + href.substring(0, idx);
}

function getBaseURLs () {
  var href = window.location.href.substring(7); // strip "http://"
  var idx = href.indexOf('/');
  return 'wss://' + href.substring(0, idx);
}

function connectIndex () {
  const socket = new WebSocket(getBaseURL() + '/index_ws');
  socket.onmessage = function (msg) {
    var msgVal = JSON.parse(msg.data);
    parseContainer(msgVal);
  };
  socket.onerror = function (event) {
    console.error('WebSocket error observed:', event);
  };
}
