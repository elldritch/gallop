restify = require 'restify'
server = restify.createServer()

test_port = 1337
responder = () ->
  'Test response for index'

module.exports = 
  make_server: (done) ->
    server.get '/', (req, res, next) ->
      # console.log 'Request made to test server index'
      # console.log 'Response:', responder()
      res.send responder()
      return next()

    server.listen test_port, () ->
      # console.log "Test server listening on port", test_port
      done()
  
  test_port: test_port
  
  change_server_response: () ->
    responder = () ->
      'Test response 2 for index'