restify = require 'restify'

module.exports = () ->
  server = restify.createServer()
  server.get '/test', (req, res, next) ->
    res.send 'Hello.'

  server.listen 8080, () ->
    console.log "I'm listening."