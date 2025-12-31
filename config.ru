# Set default encoding to UTF-8 for Ruby 4.0
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require './massr'

if ENV['FORCE_HTTPS']
	require 'rack/ssl'
	use Rack::SSL
end

$stdout.sync = true # for Heroku logging
run Massr::App

