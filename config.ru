require './massr'

if ENV['FORCE_HTTPS']
	require 'rack/ssl'
	use Rack::SSL
end

$stdout.sync = true # for Heroku logging
run Massr::App

