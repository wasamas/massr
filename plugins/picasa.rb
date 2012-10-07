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

			def self.auth(user_id, password)
				@@user_id, @@password = user_id, password
			end

			def initialize
				raise StandardError::new('not specified user_id or password') unless @@user_id && @@password
				@picasa_client ||= ::Picasa::Client.new(user_id: @@user_id, password: @@password)
			end

			def upload_file(path, content_type)
				album = @picasa_client.get_album(Time.now.strftime("Massr%Y%m001"))
				return @picasa_client.photo.create(
					album.id,
					file_path: path,
					content_type: content_type
				).content.src
			end
		end
	end
end

