restify = require 'restify'
faker = require 'faker'

module.exports = (port) ->
  server = restify.createServer()
  responder = (req, res, next) ->
    res.send responder.message
    next()
  responder.message = JSON.stringify faker.Helpers.createCard()

  start: (done) ->
    server.get '/', responder
    server.listen port, done
  change_response: ->
    responder.message = JSON.stringify faker.Helpers.createCard()
  get_response: -> responder.message
