should = require('chai').should()
Daemon = require '../src/daemon'

server = require('./mock-server')
test_port = server.test_port

describe 'Daemon', ->
  describe '#subscribe', ->
    it 'should add new targets', ->
      daemon = new Daemon
      Object.keys(daemon.targets).length.should.equal(0)
      daemon.subscribe 'fake url', {}, ->
      Object.keys(daemon.targets).length.should.equal(1)

  describe '#unsubscribe', ->
    it 'should remove targets', ->
      daemon = new Daemon
      daemon.subscribe 'fake url', {}, ->
      id1 = daemon.subscribe 'fake url', {}, ->
      daemon.subscribe 'fake url', {}, ->
      id2 = daemon.subscribe 'fake url', {}, ->
      daemon.subscribe 'fake url', {}, ->
      Object.keys(daemon.targets).length.should.equal(5)
      daemon.unsubscribe(id1)
      Object.keys(daemon.targets).length.should.equal(4)
      daemon.unsubscribe(id2)
      Object.keys(daemon.targets).length.should.equal(3)

  describe '#start', ->
    it 'should start', ->
      daemon = new Daemon
      daemon.start()
      daemon.active.should.equal(true)

  describe '#stop', ->
    it 'should stop', ->
      daemon = new Daemon
      daemon.start()
      daemon.stop()
      daemon.active.should.equal(false)

  describe '#_refresh', ->
    before (done) ->
      server.make_server done

    it 'should test for state changes', (done) ->
      daemon = new Daemon
      refreshes = 0

      daemon.subscribe 'http://localhost:' + test_port + '/', {}, (err, result, res) ->
        # console.log err, result
        refreshes++

        if refreshes == 1
          server.change_server_response()
          daemon._refresh()

        if refreshes == 2
          done()

      daemon._refresh()