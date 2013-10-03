(function() {
  var Daemon, rest, util;

  rest = require('restler');

  util = require('util');

  Daemon = (function() {
    function Daemon(options) {
      if (options == null) {
        options = {};
      }
      this.targets = options.targets, this.interval = options.interval;
      if (this.interval == null) {
        this.interval = 60 * 1000;
      }
      if (this.targets == null) {
        this.targets = {};
      }
      this.next_target = Object.keys(this.targets).length;
      this.active = false;
    }

    Daemon.prototype.subscribe = function(url, options, callback) {
      this.targets[this.next_target] = {
        url: url,
        options: options,
        callback: callback
      };
      this.next_target++;
      return this.next_target - 1;
    };

    Daemon.prototype.unsubscribe = function(id) {
      delete this.targets[id];
      return this;
    };

    Daemon.prototype.start = function() {
      this.active = true;
      this._refresh();
      return this;
    };

    Daemon.prototype.stop = function() {
      this.active = false;
      return this;
    };

    Daemon.prototype._refresh = function() {
      var completed, expecting, id, req, responses, target, _ref;
      responses = {};
      completed = 0;
      expecting = this.targets.length;
      _ref = this.targets;
      for (id in _ref) {
        target = _ref[id];
        req = rest.request(target.url, target.options);
        responses = {};
        req.on('complete', function(result, res) {
          var key, previous_response_state, response;
          responses[JSON.stringify(target)] = {
            result: result,
            response: res,
            last: target.last,
            callback: target.callback
          };
          this.targets[id].last = JSON.stringify(result) + JSON.stringify(res);
          completed++;
          if (completed === expecting) {
            for (key in responses) {
              response = responses[key];
              previous_response_state = response.last;
              if (JSON.stringify(response.result) + JSON.stringify(response.response !== previous_response_state)) {
                response.callback(response.result, response.res);
              }
            }
            if (this.active) {
              return setTimeout(this._refresh, this.interval);
            }
          }
        });
      }
      return this;
    };

    return Daemon;

  })();

  module.exports = Daemon;

}).call(this);
