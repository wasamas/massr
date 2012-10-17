# -*- coding: utf-8; -*-
#
# routes/search.rb
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base
		before '/search*' do
			@q = params[:q].strip
		end

		get '/search.json' do
			[].tap {|a|
				Statement.get_statements(param_date,{:body => /#{@q}/}).each do |statement|
					a << statement.to_hash
				end
			}.to_json
		end

		get '/search' do
			if @q.size == 0 then
				redirect '/'
				return
			end
			if @q != params[:q] then
				redirect '/search?q=' + @q
				return
			end

			haml :index , :locals => {
				:statements => Statement.get_statements(param_date,{:body => /#{@q}/}),
				:q => @q}
		end
	end
end


