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
			cache = Massr::Plugin::Memcached.main.get
			if(cache && !params[:date])
				cache
			else
				json = [].tap {|a|
					Statement.get_statements(param_date).each do |statement|
						a << statement.to_hash
					end
				}.to_json
				Massr::Plugin::Memcached.main.set(json)
				json
			end
		end

		delete '/newres' do
			access_user = User.find_by_id(session[:user_id])
			res_ids = access_user.res_ids
			access_user.clear_res_ids
		end

		get '/ressize.json' do
			access_user = User.find_by_id(session[:user_id])
			ressize = {
				:user => access_user.massr_id,
				:size => access_user.res_ids.size
			}.to_json
		end

	end
end


