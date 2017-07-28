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
				statements: Statement.get_statements(param_date),
				q: nil}
		end

		get '/index.json' do
			main = cache.get('main')
			if(main && !params[:date])
				main
			else
				json = [].tap {|a|
					Statement.get_statements(param_date).each do |statement|
						a << statement.to_hash
					end
				}.to_json
				cache.set('main', json)
				json
			end
		end

		delete '/newres' do
			access_user = User.find_by(id: session[:user_id])
			res_ids = access_user.res_ids
			access_user.clear_res_ids
		end

		get '/ressize.json' do
			access_user = User.find_by(id: session[:user_id])
			ressize = {
				:user => access_user.massr_id,
				:size => access_user.res_ids.size
			}.to_json
		end

	end
end


