# -*- coding: utf-8; -*-
#
# routes/icon.rb
#
# Copyright (C) 2014 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base

		get '/favicon.ico' do
			send_file("public/img/icons/#{icon_dir}/favicon.ico")
		end

		get '/img/apple-touch-icon-:size.png' do
			send_file("public/img/icons/#{icon_dir}/apple-touch-icon-#{params[:size]}.png")
		end

	end
end


