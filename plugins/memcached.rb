# -*- coding: utf-8; -*-
#
# plugins/memcached.rb : massr plugin of memcached
#
# Copyright (C) 2014 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#
require 'celluloid'

module Massr
	module Plugin
		class Memcached

			def self.cache cache
				@@cache = cache
			end

			def self.delete
				@@cache.delete("#{@@prefix}#{@@key}")
			end

			def self.set(value)
				@@cache.set("#{@@prefix}#{@@key}",value)
			end

			def self.get
				@@cache.get("#{@@prefix}#{@@key}")
			end

			def self.get_list
				@@cache.get("#{@@prefix}#{@@key}") ? @@cache.get("#{@@prefix}#{@@key}") : Set.new
			end

			def self.add_list(value)
				qlist = self.get_list.add(value)
				@@cache.set("#{@@prefix}#{@@key}",qlist)
			end

			def self.delete_list(value)
				qlist = self.get_list.delete(value)
				@@cache.set("#{@@prefix}#{@@key}",qlist)
			end

			def self.search(key)
				@@prefix="search-"
				@@key = key
				self
			end

			def self.main
				@@prefix="mail-"
				@@key="index"
				self
			end

			def self.query_list
				@@prefix="qlist-"
				@@key = "list"
				self
			end

		end

		class AsyncCleanCache
			include Celluloid

			def clean_cache(body)

				Massr::Plugin::Memcached.query_list.get.each do |query|
					if /#{query}/ =~ body
						Massr::Plugin::Memcached.query_list.delete_list(query)
						Massr::Plugin::Memcached.search(query).delete
					end
				end
			end
		end
	end
end
