# plugins/media/gyazo.rb : massr plugin of upload image to gyazo
#
# usage: set Gyazo API's access token to ENV['MEDIA_GYAZO_SECRET']
#
# Copyright (C) 2017 by The wasam@s production
# https://github.com/tdtds/massr
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
					raise StandardError::new('MEDIA_GYAZO_SECRET not found')
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
					res = @client.upload(path.to_s)
					return res['thumb_url'].sub(%r|/thumb/\d+/|, "/thumb/#{display_size}/")
				rescue
					init_client
					retry if (retry_count += 1) < 10
					raise
				end
			end

		private
			def init_client
				@client = ::Gazo::Client.new ENV['MEDIA_GYAZO_SECRET']
			end
		end
	end
end

