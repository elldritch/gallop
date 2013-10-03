(function() {
  var Daemon, rest, _;

  rest = require('restler');

  _ = require('underscore');

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
      var completed, expected, req, responses, target, target_id, _ref,
        _this = this;
      responses = {};
      completed = 0;
      expected = Object.keys(this.targets).length;
      _ref = this.targets;
      for (target_id in _ref) {
        target = _ref[target_id];
        req = rest.request(target.url, target.options);
        responses = {};
        req.on('complete', function(result, res) {
          var response, response_id, _ref1;
          responses[target_id] = {
            result: result,
            response: res,
            last: target.last,
            callback: target.callback
          };
          _this.targets[target_id].last = {
            result: result,
            response: res
          };
          completed++;
          if (completed === expected) {
            for (response_id in responses) {
              response = responses[response_id];
              console.log('Comparing states:', response.result, (_ref1 = response.last) != null ? _ref1.result : void 0);
              if (response.result instanceof Error) {
                response.callback(response.result, null, null);
              } else if (!_.isEqual({
                result: response.result,
                response: response.response
              }, response.last)) {
                response.callback(null, response.result, response.response);
              }
            }
            if (_this.active) {
              return setTimeout(_this._refresh, _this.interval);
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
