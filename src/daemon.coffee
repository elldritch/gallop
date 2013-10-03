rest = require 'restler'
util = require 'util'

class Daemon
  constructor: (options) ->
    options ?= {}
    {@targets, @interval} = options

    @interval ?= 60 * 1000

    @targets ?= {}
    @next_target = Object.keys(@targets).length

    @active = false

  subscribe: (url, options, callback) ->
    @targets[@next_target] =
      url: url,
      options: options,
      callback: callback
    @next_target++
    @next_target - 1

  unsubscribe: (id) ->
    delete @targets[id]
    @

  start: ->
    @active = true
    @_refresh()
    @

  stop: ->
    @active = false
    @

  _refresh: ->
    responses = {}
    completed = 0
    expecting = @targets.length
    for id, target of @targets
      req = rest.request target.url, target.options
      responses = {}
      req.on 'complete', (result, res) ->
        responses[JSON.stringify target] = 
          result: result
          response: res
          last: target.last
          callback: target.callback
        @targets[id].last = JSON.stringify(result) + JSON.stringify res

        completed++

        if completed == expecting
          for key, response of responses
            previous_response_state = response.last
            if JSON.stringify(response.result) + JSON.stringify response.response != previous_response_state
              response.callback response.result, response.res

          if @active
            setTimeout @_refresh, @interval
    @

module.exports = Daemon