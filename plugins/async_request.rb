# -*- coding: utf-8; -*-
#
# plugins/async_request.rb : massr plugin of async request
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#
require 'uri'
require 'net/http'
require 'net/https'
require 'thread'
require 'celluloid'


module Massr
	module Plugin
		class AsyncRequest
			include Celluloid

			def initialize(uri)
				@uri = uri

				proxy = if @uri.scheme == 'https'
					URI(ENV['https_proxy'] || '')
				else
					URI(ENV['http_proxy'] || '')
				end
				@nethttp = Net::HTTP::Proxy(proxy.host, proxy.port).new( @uri.host, @uri.port )
				@nethttp.use_ssl = true if @uri.scheme == 'https'
			end

			def add_photo(statement_id)
				@statement_id = statement_id
				begin
					@nethttp.start do |http|
						response = http.head( @uri.request_uri )
						Statement.add_photo(@statement_id,@uri) if response["content-type"].to_s.include?('image')
					end
				rescue SocketError => e
					#URLの先が存在しないなど。
				rescue Timeout::Error => e
					#タイムアウト
				end
			end
		end
	end
end
