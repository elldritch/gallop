op = require 'openport'
# equal = require 'deep-equal'
expect = require 'chai'
  .expect

Gallop = require '../src'
mocker = require './mock-server'

describe 'Gallop', ->
  server = null
  port = 3000

  before (done) ->
    op.find (err, found) ->
      if err
        throw new Error 'Could not find open port.'
      port = found
      server = mocker found
      server.start done

  it 'adds new targets', ->
    daemon = new Gallop()

    expect Object.keys daemon.targets
      .to.have.length 0

    daemon.subscribe 'fake url', {}, ->

    expect Object.keys daemon.targets
      .to.have.length 1

  it 'removes targets', ->
    daemon = new Gallop()
    targets = []

    targets.push daemon.subscribe 'fake url', {}, ->
    targets.push daemon.subscribe 'fake url', {}, ->

    daemon.subscribe 'fake url', {}, ->
    daemon.subscribe 'fake url', {}, ->
    daemon.subscribe 'fake url', {}, ->

    expect Object.keys daemon.targets
      .to.have.length 5

    daemon.unsubscribe targets.pop()
    expect Object.keys daemon.targets
      .to.have.length 4

    daemon.unsubscribe targets.pop()
    expect Object.keys daemon.targets
      .to.have.length 3

  it 'starts', ->
    daemon = new Gallop()

    daemon.start()

    expect daemon.active
      .to.be.true

  it 'stops', ->
    daemon = new Gallop()

    daemon.start()
    daemon.stop()

    expect daemon.active
        .to.be.false

  it 'tests for state changes', (done) ->
    daemon = new Gallop()
    refreshes = 0

    daemon.subscribe 'http://localhost:' + port + '/', {}, (err, result, res) ->
      refreshes++

      if refreshes is 1
        server.change_server_response()
        daemon._refresh()

      if refreshes is 2
        done()

    daemon._refresh()
