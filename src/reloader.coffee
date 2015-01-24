
net = require 'net'
gutil = require 'gulp-util'
through2 = require 'through2'

EventEmitter = require('events').EventEmitter
WebSocketServer = require('ws').Server

Transform = require('stream').Transform

local = {}

module.exports = exports = (pattern) ->
  through2.obj (file, env, cb) ->
    unless file.path.match /\.map$/
      local.reload pattern
    cb()

createServer = ->
  wss = new WebSocketServer port: 8887
  station = new EventEmitter
  gutil.log gutil.colors.green('Created reloader server')

  wss.on 'connection', (ws) ->
    reloadTask = (data) ->
      try ws.send data
      catch error
        gutil.log "Failed to reload tabs", JSON.stringify(data)

    station.on 'data', reloadTask
    ws.onclose ->
      station.removeListener 'data', reloadTask

  net
  .createServer (socket) ->
    socket.on 'data', handleSocketData
  .listen 8888

  handleSocketData = (data) ->
    if local.nextCall?
      clearTimeout local.nextCall
      delete local.nextCall
    local.nextCall = setTimeout ->
      gutil.log 'Reloading tabs via', gutil.colors.yellow(data.toString())
      station.emit 'data', data.toString()
      clearTimeout local.nextCall
      delete local.nextCall
    , 300

exports.listen = ->
  client = net
  .createServer()
  .listen 8888
  .once 'error', (error) -> gutil.log 'Existed reloader server'
  .once 'listening', -> client.close()
  .once 'close', createServer

local.reload = (pattern) ->
  client = net.connect port: 8888, ->
    client.write pattern, 'utf8', -> client.destroy()