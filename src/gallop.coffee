Promise = require 'bluebird'

rest = require 'restler'

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
      options: options or {}
      callback: callback or ->
      last: undefined
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
      # console.log 'requesting target', target_id
      requests.push new Promise (resolve, reject) ->
        req = rest.request target.url, target.options

        handle_response = (data, response) ->
          # console.log 'response received', typeof data, 'of length', data.length
          # console.log 'last:', typeof target.last
          # console.log data isnt target.last

          if data isnt target.last
            ambi target.callback, null, data, response
              .then ->
                # console.log 'processed'
                target.last = data
                resolve data
          else
            resolve data

        handle_error = (err, response) ->
          target.last = err

          resolve ambi target.callback, err, null
            .then ->
              err

        req.on 'success', handle_response
        req.on 'fail', handle_response

        req.on 'error', handle_error
        req.on 'timeout', (ms) ->
          err = new Error 'Request timed out after ' + ms + ' milliseconds.'
          err.ms = ms
          handle_error err, null

    Promise.settle requests
      .then =>
        if @active
          setTimeout @_refresh, @interval

module.exports = Gallop
