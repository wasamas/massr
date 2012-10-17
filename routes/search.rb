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
			@total = total_page({:body => /#{@q}/})
			@page = current_page
		end

		get '/search.json' do
			date = params[:date] ? params[:date] : Time.now.strftime("%Y%m%d%H%M%S")
			[].tap {|a|
				Statement.get_statements_by_date(date,{:body => /#{@q}/}).each do |statement|
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
				:page => @page, 
				:statements => Statement.get_statements_by_page(@page,{:body => /#{@q}/}),
				:q => @q,
				:total_page => @total}
		end
	end
end


