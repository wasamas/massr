# -*- coding: utf-8; -*-
#
# helpers/resource.rb : language resource
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

require 'open-uri'

module Massr
	class App < Sinatra::Base
		massr_settings_url = '/settings.json'

		env = ENV['MASSR_SETTINGS']
		if env # online
			if %r|\Ahttps?://|
				# saving copy to cache
				massr_settings_url = '/settings_cache.json'
				open("public#{massr_settings_url}", 'w'){|o|o.write(open(env, &:read))}
			else # local
				if %r|\.\.| =~ env
					puts "MASSR_SETTINGS cannot contains '..'."
					exit
				end
				massr_settings_url = env
				massr_settings_url = '/' + massr_settings_url if %r|\A/| !~ massr_settings_url
			end
		end
		SETTINGS = JSON.parse(open("public#{massr_settings_url}", &:read))

		define_method(:massr_settings) do
			massr_settings_url
		end

		SETTINGS['local'].each do |key, value|
			define_method("_#{key}"){|*args|
				value.gsub(/%(\d+)/){args[$1.to_i - 1]}
			}
		end
	end
end
