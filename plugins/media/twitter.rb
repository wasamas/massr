# -*- coding: utf-8; -*-
#
# plugins/media/twitter.rb : massr plugin of upload image to twitter
#
# usage: in default.json file:
#
#        // if no *_secret , uses MEDIA_*_SECRET from ENV
#        "plugin": {
#          "media/twitter": {
#            "consumer_key": "hoge",
#            "consumer_secret": "fuga",
#            "access_token": "foo",
#            "access_token_secret", "bar"
#          }
#        }
#
# Copyright (C) 2014 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#
require 'twitter'
require 'rmagick'

#
# Massr Twitter media plugin
#
module Massr
	module Plugin::Media
		class Twitter
			DEFAULT_UPLOAD_PHOTO_SIZE = 2048

			def initialize(label, opts)
				@conf = {
					consumer_key: opts['consumer_key'] || ENV['MEDIA_CONSUMER_KEY'],
					consumer_secret: opts['consumer_secret'] || ENV['MEDIA_CONSUMER_SECRET'],
					access_token: opts['access_token'] || ENV['MEDIA_ACCESS_TOKEN'],
					access_token_secret: opts['access_token_secret'] || ENV['MEDIA_ACCESS_TOKEN_SECRET']
				}
				if @conf.values.include?(nil)
					raise StandardError::new('not specified OAuth keys')
				end
				@client ||= init_client
			end

			def resize_file(path, size=0, square=false)
				size = DEFAULT_UPLOAD_PHOTO_SIZE if size == 0
				photo = Magick::ImageList.new(path).first
				if photo.columns > size || photo.rows > size
					photo.resize_to_fit!(size,size)
					photo.write(path)
				end
				if square
					img = Magick::Image.new(size, size)
					img.background_color = '#ffffff'
					img.composite!(photo, Magick::CenterGravity, Magick::OverCompositeOp)
					img.format = photo.format
					img.write(path)
					img.destroy!
				end
				photo.destroy!
			end

			def upload_file(path, content_type, display_size = nil)
				retry_count = 0
				begin
					status = @client.update_with_media(Time.now.to_s, File.new(path))
					return status.attrs[:entities][:media].first[:media_url]
				rescue
					init_client
					retry if (retry_count += 1) < 10
					raise
				end
			end

		private
			def init_client
				::Twitter::REST::Client.new(@conf)
			end
		end
	end
end

