# -*- coding: utf-8; -*-
#
# plugins/picasa.rb : massr plugin of upload to picasa album
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#
require 'picasa'
require 'RMagick'

#
# Enhanced Picasa Client
#
class ::Picasa::Client
	def get_album(album_name)
		album_list = self.album.list(:fields => "entry[title eq \'#{album_name}\']")
		if album_list.entries.size == 0
			album = self.album.create(title: album_name, timestamp: Time::now.to_i)
		else
			album = album_list.entries[0]
		end

		return album.numphotos < 1000 ? album : get_album(album_name.succ)
	end
end

#
# Massr Picasa plugin
#
module Massr
	module Plugin
		class Picasa
			@@user_id = nil
			@@password = nil

			@@DEFAULT_UPLOAD_PHOTO_SIZE = 2048
			@@DEFAULT_DISPLAY_PHOTO_SIZE = 800

			def self.auth(user_id, password)
				@@user_id, @@password = user_id, password
			end

			def initialize
				raise StandardError::new('not specified user_id or password') unless @@user_id && @@password
				@picasa_client ||= init_picasa_client
			end

			def resize_file(path,size=0,square=false)
				size = @@DEFAULT_UPLOAD_PHOTO_SIZE if size == 0
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

			def upload_file(path, content_type)
				retry_count = 0
				size = ENV['DISPLAY_PHOTO_SIZE'].to_i > 0 ? ENV['DISPLAY_PHOTO_SIZE'].to_i : @@DEFAULT_DISPLAY_PHOTO_SIZE
				begin
					album = @picasa_client.get_album(Time.now.strftime("Massr%Y%m001"))
					image_uri = URI.parse(@picasa_client.photo.create(
						album.id,
						file_path: path,
						content_type: content_type
					).content.src)
					image_uri.path = image_uri.path.split('/').insert(-2,"s#{size}").join('/')
					return image_uri.to_s
				rescue ::Picasa::ForbiddenError
					init_picasa_client
					retry if (retry_count += 1) < 10
					raise
				end
			end

		private
			def init_picasa_client
				::Picasa::Client.new(user_id: @@user_id, password: @@password)
			end
		end
	end
end

