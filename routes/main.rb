# -*- coding: utf-8; -*-
#
# routes/main.rb
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base
		get '/' do
			haml :index , :locals => {
				:statements => Statement.get_statements(param_date),
				:q => nil}
		end

		get '/index.json' do
			cache = settings.cache.get(cache_keys[:index_json])
			if(cache)
				cache
			else
				json = [].tap {|a|
					Statement.get_statements(param_date).each do |statement|
						a << statement.to_hash
					end
				}.to_json
				settings.cache.set(cache_keys[:index_json],json)
				json
			end
		end
	end
end


