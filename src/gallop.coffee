rest = require 'restler'
_ = require 'underscore'

class Gallop
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
    expected = Object.keys(@targets).length
    for target_id, target of @targets
      req = rest.request target.url, target.options
      responses = {}
      req.on 'complete', (result, res) =>
        responses[target_id] = 
          result: result
          response: res
          last: target.last
          callback: target.callback

        completed++

        if completed is expected
          for response_id, response of responses
            # console.log 'Comparing states:', response.result, response.last?.result

            if response.result instanceof Error
              response.callback response.result, null, null
            else if not _.isEqual {
              result: response.result
              response: response.response
            }, response.last
              response.callback null, response.result, response.response

            @targets[target_id].last = 
              result: result
              response: res

          if @active
            setTimeout @_refresh, @interval
    @

module.exports = Daemon