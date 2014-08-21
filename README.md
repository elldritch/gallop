# Gallop
Gallop polls REST APIs at particular intervals to listen for changes.

## Installation
Gallop is available on the NPM registry.
```shell
npm install gallop
```

## Usage
```javascript
var gallop = require('gallop')({
  interval: 10
});

// Add a target.
gallop.subscribe('//api-endpoint.provider.com/api', null, function(err, result, httpResponse){
  if(err){
    return console.error(err);
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

```javascript
var Gallop = require('gallop');

var daemon = new Gallop({
  interval: 500
});
```

### Creating targets
A Gallop daemon subscribes to targets, which are composed of a REST API URL, an options object for the request, and a callback that fires whenever the response from that API endpoint changes.
Arguments:

* `url` -- A string endpoint URL
* `options` -- An options object for the request -- see documentation for Restler's options
* `callback` -- A callback that takes `err`, `result`, and `httpResponse` to be called whenever the data changes

```javascript
daemon.subscribe('//api-endpoint.provider.com/api', {
  method: 'GET',
  query: {
    api_key: 'some API key',
    some_field: 'some data for the field'
    // ...
  }
}, function(err, result, httpResponse) {
  if (err) {
    return console.error(err);
  }
  console.log(result);
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

## License
&copy; 2014 Lehao Zhang. Released under the terms of the MIT license.
