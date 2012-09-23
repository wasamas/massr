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
			page = params[:page]?params[:page]:1
			haml :index , :locals => {
				:page => page , 
				:statements => Statement.get_statements(page,{:body=>/.*#{params[:search]}.*/})}
		end
	end
end


