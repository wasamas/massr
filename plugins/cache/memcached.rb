# -*- coding: utf-8; -*-
#
# plugins/cache/memcached.rb : massr cache plugin of memcached
#
# Copyright (C) 2016 by The WASAM@S Production
# https://github.com/wasamas/massr
#
# Distributed under GPL
#
require 'celluloid'

module Massr
	module Plugin::Cache
		class Memcached
			include Celluloid

			def initialize(label, opts = {})
				if ENV['MEMCACHE_SERVERS'] || ENV["MEMCACHIER_SERVERS"]
					@cache = Dalli::Client.new(
						ENV['MEMCACHE_SERVERS'] || ENV["MEMCACHIER_SERVERS"],
						:username => ENV['MEMCACHE_USERNAME'] || ENV["MEMCACHIER_USERNAME"],
						:password => ENV['MEMCACHE_PASSWORD'] || ENV["MEMCACHIER_PASSWORD"],
						:expires_in => 24 * 60 * 60,
						:compress => true)
				else
					@cache = Dalli::Client.new(
						nil,
						:expires_in => 24 * 60 * 60,
						:compress => true)
				end
			end

			def get(key)
				@cache.get(key)
			end

			def set(key, value)
				@cache.set(key, value)
			end

			def delete(key)
				@cache.delete(key)
			end
		end
	end
end
