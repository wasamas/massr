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
			total = total_page
			page = [current_page, total].min
			haml :index , :locals => {
				:page => page,
				:statements => Statement.get_statements(page),
				:q => nil,
				:total_page => total}
		end

		get '/index.json' do
			total = total_page
			page = [current_page, total].min
			[].tap {|a|
				Statement.get_statements(page).each do |statement|
					a << statement.to_hash
				end
			}.to_json
		end
	end
end


