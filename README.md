# Gallop

Gallop polls REST APIs at particular intervals to listen for changes.

## Usage
```javascript
var gallop = require('gallop')

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
Coming soon!

## Dependencies
* Restler
* Underscore

For testing:

* Mocha + Chai
* Grunt
* Restify

## License
(C) 2013 Leo Zhang. Released to the general public under the terms of the MIT license.