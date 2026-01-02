# -*- coding: utf-8; -*-
#
# helpers/picasa.rb : helper methods of upload to picasa album
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/wasamas/massr
#
# Distributed under GPL
#
module Massr
	class NoPhotoError < StandardError; end

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
					media_client = media_plugins.first
					raise Massr::NoPhotoError.new unless media_client

					unless photo_info && photo_info[:tempfile]
						puts "Media upload error: photo_info or tempfile is nil"
						raise Massr::NoPhotoError.new
					end

					path = photo_info[:tempfile].to_path
					unless path && File.exist?(path)
						puts "Media upload error: tempfile path is invalid or file does not exist (path: #{path})"
						raise Massr::NoPhotoError.new
					end

					content_type = specify_content_type(photo_info[:head])
					media_client.resize_file(path, size, square)
					return media_client.upload_file(path, content_type, SETTINGS['setting']['display_photo_size'])
				rescue StandardError => e
					puts "Media upload error: #{e.class}: #{e.message}"
					puts e.backtrace.first(5).join("\n")
					raise Massr::NoPhotoError
				end
			end
		end
	end
end
