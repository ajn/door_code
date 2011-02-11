### DoorCode. Restrict access with a 5-digit PIN code.

Install with Bundler:

    gem 'door_code', '0.0.1', :git => 'http://github.com/6twenty/door_code.git'
    
In config.ru:

    use Rack::DoorCode::RestrictedAccess, :code => '12345' # Note: ZERO is not a supported digit! Why? Because I forgot to add it to the keypad :(
    
Or in application.rb (Rails3) or environment.rb (Rails2):

    config.middleware.use Rack::DoorCode::RestrictedAccess, :code => '12345'
    
---

NOTE: This gem is not ready yet!

---

### To Do

* Fix bug which allows everyone access when only one person enters the code (see next todo)
* Set up Rack::Sessions to handle monitoring when the user enters the correct code
* Set up Rack::Cookies for long-term rememberability (tied to Sessions)
* Fix the bug causing the keypad to be shown again even after entering the correct code (reloading loads the site correctly)
* Fix visual irregularities (ie positioning of numbers in the display)
* Fix 'blue' version (doesn't always display)
* Allow specifying a URL to restrict access conditionally
* Add ZERO to the keypad!
* Set a default PIN if none is given
* Validate the code passed to the middleware; revert to default if the code is invalid
* Add some sort of security to keep the PIN code safe & secure
* Add no-js version of index.html
* Extended browser support (requires PNG fixing)
* Add favicon?
