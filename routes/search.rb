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
			total_page = [Statement.count({:body=>/.*#{params[:search]}.*/}) / $limit, 1].max
			page = params[:page]
			if page =~ /^\d+/
				page = page.to_i
			else
				page = 1
			end
			haml :index , :locals => {
				:page => page , 
				:statements => Statement.get_statements(page,{:body=>/.*#{params[:search]}.*/}),
				:total_page => total_page}
		end
	end
end


