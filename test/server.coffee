op = require 'openport'
request = require 'superagent'
expect = require 'chai'
  .expect

mocker = require './lib/server'

describe 'mock server', ->
  server = null
  port = 3000
  url = 'http://localhost'

  before (done) ->
    op.find (err, found) ->
      if err
        throw new Error 'Could not find open port.'
      port = found
      url += ':' + port
      server = mocker found
      server.start done

  it 'starts', (done) ->
    request.get url
      .end (res) ->
        parsed = JSON.parse res.body

        expect parsed
          .to.be.an.object
        expect Object.keys parsed
          .to.not.have.length 0

        done()

  it 'sends correct responses', (done) ->
    request.get url
      .end (res) ->
        previous = res.body
        expect res.body
          .to.equal server.get_response()

        request.get url
          .end (res) ->
            expect res.body
              .to.equal server.get_response()
            expect res.body
              .to.equal previous

            done()

  it 'changes its response', (done) ->
    request.get url
      .end (res) ->
        previous = res.body
        expect res.body
          .to.equal server.get_response()

        server.change_response()
        expect previous
          .to.not.equal server.get_response()

        request.get url
          .end (res) ->
            expect res.body
              .to.equal server.get_response()
            expect res.body
              .to.not.equal previous

            done()
