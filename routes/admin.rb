# -*- coding: utf-8; -*-
#
# routes/admin.rb
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/wasamas/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base
		before '/admin*' do
			user =  User.find_by(id: session[:user_id])
			redirect to('/') unless user.admin?
		end
		
		get '/admin' do
			haml :admin, :locals => {users: User.where(:_id.ne => session[:user_id])}
		end
	end
end
