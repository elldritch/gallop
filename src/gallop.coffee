Promise = require 'bluebird'

rest = require 'restler'
equal = require 'deep-equal'

ambi = Promise.promisify require 'ambi'

class Gallop
  constructor: (options = {}) ->
    {@targets, @interval} = options

    @interval ||= 60 * 1000

    @targets ||= {}
    @next_target = Object.keys(@targets).length

    @active = false

  subscribe: (url, options, callback) ->
    @targets[@next_target] =
      url: url
      options: options
      callback: callback
      last:
        data: undefined
        response: undefined
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
    requests = []
    for target_id, target of @targets
      requests.push new Promise (resolve, reject) ->
        req = rest.request target.url, target.options

        handle_request = (data, response) ->
          if not equal target.last.data, data
            resolve ambi target.callback, null, data, response, (err, res) ->
              target.last.data = data
              target.last.response = response

              data
          else
            resolve data

        handle_error = (err, response) ->
          target.last.data = err
          target.last.response = response

          resolve ambi target.callback, err, null
            .then ->
              err

        req.on 'success', handle_request
        req.on 'fail', handle_request

        req.on 'error', handle_error
        req.on 'timeout', (ms) ->
          err = new Error 'Request timed out after ' + ms + ' milliseconds.'
          err.ms = ms
          handle_error err, null

    Promise.settle requests
      .then =>
        if @active
          setTimeout @_refresh, @interval
    @

module.exports = Gallop
