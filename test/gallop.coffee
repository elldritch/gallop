op = require 'openport'
expect = require 'chai'
  .expect

Gallop = require '../src'
mocker = require './lib/server'

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

    daemon.subscribe 'fake url', null, ->

    expect Object.keys daemon.targets
      .to.have.length 1

  it 'removes targets', ->
    daemon = new Gallop()
    targets = []

    targets.push daemon.subscribe 'fake url', null, ->
    targets.push daemon.subscribe 'fake url', null, ->

    daemon.subscribe 'fake url', null, ->
    daemon.subscribe 'fake url', null, ->
    daemon.subscribe 'fake url', null, ->

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
    refreshes = 1
    previous = null

    daemon.subscribe 'http://localhost:' + port, null, (err, result) ->
      # console.log 'result received', typeof result, 'of length', result.length

      if refreshes is 1
        previous = result

        refreshes++
        daemon._refresh()
          .then ->
            server.change_response()

            refreshes++
            daemon._refresh()
      else if refreshes is 3
        expect result
          .to.not.equal previous

        done()
      else
        throw new Error 'Gallop is firing on identical responses.'

    daemon._refresh()
