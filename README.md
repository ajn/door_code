### DoorCode. Restrict access with a 5-digit PIN code.

## Installation

Install with Bundler:

    gem 'door_code', '0.0.1', :git => 'http://github.com/6twenty/door_code.git'
    
In config.ru:

    use Rack::DoorCode::RestrictedAccess, :code => '12345'
    
Or in application.rb (Rails3) or environment.rb (Rails2):

    config.middleware.use Rack::DoorCode::RestrictedAccess, :code => '12345'

## Notes

* The default code is '12345'
* If the code passed to DoorCode is invalid (eg contains non-digits), the default code will be assigned
* ZERO is not a supported digit! Why? Because I forgot to add it to the keypad :(

## To Do

* Fix the bug causing the keypad to be shown again even after entering the correct code (reloading loads the site correctly)
* Fix visual irregularities (ie positioning of numbers in the display)
* Fix 'blue' version (doesn't always display on time)
* Allow specifying URLs/domains to restrict access conditionally
* Add ZERO to the keypad!
* Add no-js version of index.html
* Extended browser support (requires PNG fixing)
* Add favicon?
