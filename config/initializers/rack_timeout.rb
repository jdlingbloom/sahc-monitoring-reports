# Lower the application timeout so it doesn't keep running when Heroku's 30
# second timeout kicks in. This also gives us better error messages in the
# application.
Rack::Timeout.service_timeout = 28 # seconds

# Disable wait timeouts to allow for larger uploads on Heroku.
Rack::Timeout.wait_timeout = false

# Better rack-timeout errors for rollbar.
require "rack/timeout/rollbar"
