# plugins/media/gyazo.rb : massr plugin of upload image to gyazo
#
# usage: set Gyazo API's access token to ENV['MEDIA_GYAZO_SECRET']
#
# Copyright (C) 2017 by The wasam@s production
# https://github.com/wasamas/massr
#
# Distributed under GPL
#
require 'gyazo'

#
# Massr Gyazo media plugin
#
module Massr
	module Plugin::Media
		class Gyazo
			DEFAULT_DISPLAY_PHOTO_SIZE = 800

			def initialize(label, opts)
				unless ENV['MEDIA_GYAZO_SECRET']
					puts "ERROR: MEDIA_GYAZO_SECRET environment variable is not set"
					raise StandardError.new('MEDIA_GYAZO_SECRET not found')
				end
				init_client
			end

			def resize_file(path, size=0, square=false)
				# NOP because no limit size in Gyazo
			end

			def upload_file(path, content_type, display_size = nil)
				display_size ||= DEFAULT_DISPLAY_PHOTO_SIZE
				retry_count = 0
				begin
					res = @client.upload(imagefile: path.to_s)

					# レスポンスからURLを取得
					url = res[:url] || res['url']

					unless url
						puts "ERROR: Could not extract URL from Gyazo response: #{res.inspect}"
						raise StandardError.new("No URL in Gyazo response")
					end

					return url.sub(%r|^https://i\.gyazo\.com|, "https://i.gyazo.com/thumb/#{display_size}")
				rescue => e
					puts "Gyazo upload error (attempt #{retry_count + 1}/10): #{e.class}: #{e.message}"
					puts "  File path: #{path}"
					puts "  File exists: #{File.exist?(path)}" if path
					init_client
					retry if (retry_count += 1) < 10
					raise
				end
			end

		private
			def init_client
				@client = ::Gyazo::Client.new(access_token: ENV['MEDIA_GYAZO_SECRET'])
			end
		end
	end
end

