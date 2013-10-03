# Gallop

Gallop polls REST APIs at particular intervals to listen for changes.

## Usage
```javascript
var gallop = require('gallop')({
  interval: 10
});

// Add a target.
gallop.subscribe('//rest-api.com/API', null, function(err, result, response){
  if(err){
    console.error(err);
  }
  console.log(result);
})

// Start listening.
gallop.start();
```

## Documentation
### Gallop
Requiring Gallop exposes a Gallop constructor. This object serves as a daemon which listens to requests in the background.
Arguments:

* `options` -- An optional options object with keys:
  * `interval` -- The polling interval in milliseconds. Defaults to 1 minute.
  <!-- * `targets` -- An array of targets (see below for specification of targets). -->

```javascript
var Gallop = require('gallop')

var options = {
  interval: 500
};
var daemon = new Gallop(options);
```

### Creating targets
Gallop subscribes to targets, which are objects composed of a REST API URL, an options object for the request, and a callback that fires whenever the response from that API endpoint changes.
Arguments:

* `url` -- A string endpoint URL
* `options` -- An options object for the request -- see documentation for Restler's options
* `callback` -- A callback that takes `err`, `result`, and `response` to be called whenever the data changes

```javascript
daemon.subscribe('//api-endpoint.provider.com/API', {
  method: 'GET',
  query: {
    api_key: 'some API key',
    // ...
  }
});
```

`subscribe` returns a target ID, which can be passed to `unsubscribe` to remove the target.

```javascript
// Save the target ID.
var id = daemon.subscribe( /* ... */ );

// Unsubscribe from the target.
daemon.unsubscribe(id);
```

### Listening for changes
The Gallop daemon can `start` and `stop`; stopping in the middle of the polling cycle will complete the current cycle.

```javascript
daemon.start();

// Some time later...
daemon.stop();
```

## Dependencies
For basic usage:

* Restler
* Underscore

For testing:

* CoffeeScript
* Mocha, Chai
* Grunt, grunt-contrib-coffee
* Restify

## License
(C) 2013 Lehao Zhang. Released to the general public under the terms of the MIT license.