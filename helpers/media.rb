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
			def specify_content_type(head)
				image_type = head.scan(/(image\/\w+)/)
				if image_type.length > 0
					return image_type[0][0]
				end
				# octet-stream
				ext = head.scan(/filename=\"[^\"]*\.([^\"\.]+)\"/)
				if ext.length > 0
					return 'image/' + ext[0][0].downcase
				end
				# not found
				return ''
			end

			def media_upload(photo_info, size=0, square=false)
				begin
					return nil unless photo_info && photo_info[:tempfile]
				rescue TypeError
					return nil
				end

				media_client = media_plugins.first
				return nil unless media_client

				path = photo_info[:tempfile].to_path || ''
				content_type = specify_content_type(photo_info[:head])
				media_client.resize_file(path, size, square)
				return media_client.upload_file(path, content_type, SETTINGS['setting']['display_photo_size'])
			end
		end
	end
end
