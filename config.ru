require './massr'

$stdout.sync = true # for Heroku logging
run Massr::App

