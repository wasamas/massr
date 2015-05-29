# -*- coding: utf-8; -*-
#
# plugins/media/picasa.rb : massr plugin of upload to picasa album
#
# usage: in default.json file:
#
#        "plugin": {
#          "media/picasa": {
#            "user_id": "hoge@gmail.com",
#            "client_id": "hogehoge.apps.googleusercontent.com",
#            "client_secret": "fuga",
#            "redirect_uri": "https://hoge.example.com",
#            "refresh_token": "foobarbaz"
#          }
#        }
#
#        if no variables in json, massr uses alternative values from ENV:
#          user_id       -> PICASA_ID
#          client_id     -> GOOGLE_OAUTH_CLIENT_ID
#          client_secret -> GOOGLE_OAUTH_CLIENT_SECRET
#          redirect_uri  -> GOOGLE_OAUTH_REDIRECT
#          refresh_token -> GOOGLE_OAUTH_REFRESH_TOKEN
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#
require 'picasa'
require 'signet/oauth_2'
require 'signet/oauth_2/client'
require 'rmagick'

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
	module Plugin::Media
		class Picasa
			DEFAULT_UPLOAD_PHOTO_SIZE = 2048
			DEFAULT_DISPLAY_PHOTO_SIZE = 800

			def initialize(label, opts)
				@user_id   = opts['user_id']           || ENV['PICASA_ID']
				@client_id = opts['client_id']         || ENV['GOOGLE_OAUTH_CLIENT_ID']
				@client_secret = opts['client_secret'] || ENV['GOOGLE_OAUTH_CLIENT_SECRET']
				@redirect_uri = opts['redirect_uri']   || ENV['GOOGLE_OAUTH_REDIRECT']
				@refresh_token = opts['refresh_token'] || ENV['GOOGLE_OAUTH_REFRESH_TOKEN']
				raise StandardError::new('not specified user_id or password') unless @user_id && @client_id && @client_secret && @redirect_uri && @refresh_token
				@picasa_client = init_picasa_client
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
				display_size ||= DEFAULT_DISPLAY_PHOTO_SIZE
				retry_count = 0
				begin
					album = @picasa_client.get_album(Time.now.strftime("Massr%Y%m001"))
					image_uri = URI.parse(@picasa_client.photo.create(
						album.id,
						file_path: path,
						content_type: content_type
					).content.src)
					image_uri.path = image_uri.path.split('/').insert(-2,"s#{display_size}").join('/')
					return image_uri.to_s
				rescue ::Picasa::ForbiddenError
					@picasa_client = init_picasa_client
					retry if (retry_count += 1) < 10
					raise
				end
			end

		private
			def init_picasa_client
				oauth2_client = Signet::OAuth2::Client.new(
					token_credential_uri: "https://accounts.google.com/o/oauth2/token",
					client_id: @client_id,
					client_secret: @client_secret,
					redirect_uri: @redirect_uri,
					scope: "https://picasaweb.google.com/data/",
					refresh_token: @refresh_token
				)
				oauth2_client.refresh!
				::Picasa::Client.new(user_id: @user_id, authorization_header: Signet::OAuth2.generate_bearer_authorization_header(oauth2_client.access_token))
			end
		end
	end
end

