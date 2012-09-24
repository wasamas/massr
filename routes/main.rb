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
			total_page = [Statement.count / ($limit + 0.0), 1].max.ceil
			page = params[:page]
			if page =~ /^\d+/
				page = page.to_i
			else
				page = 1
			end
			page = [page, total_page].min
			haml :index , :locals => {:page => page , :statements => Statement.get_statements(page) , :q => '' , :total_page => total_page }
		end
	end
end


