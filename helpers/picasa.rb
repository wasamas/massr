# -*- coding: utf-8; -*-
#
# helpers/picasa.rb : helper methods of upload to picasa album
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#
module Massr
	class App < Sinatra::Base
		helpers do
			def picasa_client
				@picasa_client ||= Massr::Plugin::Picasa.new
			end

			def picasa_upload(photo_info)
				return nil unless photo_info && photo_info[:tempfile]

				path = photo_info[:tempfile].to_path || ''
				content_type = photo_info[:head].scan(/(image\/\w+)/)[0][0] || ''
				return picasa_client.upload_file(path, content_type)
			end
		end
	end
end
