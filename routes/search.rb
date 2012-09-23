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
		get '/search' do
			q = params[:q].strip
			if q.size == 0 then
				redirect '/'
				return
			end
			if q != params[:q] then
				redirect '/search?q=' + q
				return
			end

			total_page = [Statement.count({:body=>/.*#{q}.*/}) / $limit, 1].max
			page = params[:page]
			if page =~ /^\d+/
				page = page.to_i
			else
				page = 1
			end

			haml :index , :locals => {
				:page => page, 
				:statements => Statement.get_statements(page,{:body=>/.*#{q}.*/}),
				:q => q,
				:total_page => total_page
			}
		end
	end
end


