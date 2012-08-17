# -*- coding: utf-8; -*-
#
# massr.rb : Massr - Mini Wassr
#
# Copyright (C) 2012 by TADA Tadashi <t@tdtds.jp>
#

require 'sinatra/base'
require 'haml'
require 'json'

module Massr
	class App < Sinatra::Base
		set :haml, { format: :html5, escape_html: true }
		
		get '/' do
			haml :index
		end
	end
end

Massr::App::run! if __FILE__ == $0
