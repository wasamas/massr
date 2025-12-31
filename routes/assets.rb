# -*- coding: utf-8; -*-
#
# routes/assets.rb : asset routes
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/wasamas/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base
		get '/assets/*' do
			env['PATH_INFO'].sub!('/assets', '')
			settings.sprockets.call(env)
		end
	end
end
