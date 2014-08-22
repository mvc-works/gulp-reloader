
net = require 'net'
gutil = require 'gulp-util'

EventEmitter = require('events').EventEmitter
WebSocketServer = require('ws').Server

Transform = require('stream').Transform

module.exports = exports = (pattern) ->
  reloader = new Transform objectMode: true
  reloader._transform = (data, encoding, done) ->
    @push data
    reload pattern
    done()
  return reloader

createServer = ->

  wss = new WebSocketServer port: 8887
  station = new EventEmitter

  wss.on 'connection', (ws) ->
    station.on 'data', (data) ->
      try
        gutil.log 'Reloading tabs via', JSON.stringify(data)
        ws.send data
      catch error
        gutil.log "Failed to reload tabs", JSON.stringify(data)

  net
  .createServer (socket) ->
    socket.on 'data', (data) ->
      station.emit 'data', data.toString()
  .listen 8888
  gutil.log 'Creating reloader server'

exports.listen = ->
  client = net
  .createServer()
  .listen 8888
  .once 'error', (error) -> gutil.log 'Using reloader server'
  .once 'listening', -> client.close()
  .once 'close', createServer

reload = (pattern) ->
  client = net.connect port: 8888, ->
    client.write pattern
    setTimeout ->
      client.destroy()