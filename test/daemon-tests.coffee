should = require('chai').should()
Daemon = require '../src/daemon'
server = require('./mock-server')()

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
    it 'should properly connect', (done) ->
      daemon = new Daemon
      daemon.subscribe '//localhost:8080', {}, (result, res) ->
        console.log result
        done()
      daemon._refresh()
    it 'should test for state changes'