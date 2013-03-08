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

		SETTINGS = JSON.parse(
			if ENV['MASSR_SETTINGS']
				tmp = ENV['MASSR_SETTINGS']
				if %r|\A/| =~ tmp
					puts "MASSR_SETTINGS cannot start with '/'."
					exit
				elsif %r|\.\.| =~ tmp
					puts "MASSR_SETTINGS cannot contains '..'."
					exit
				end
				massr_settings_url = '/custom.json'
				file = open(tmp, &:read)
				open("public#{massr_settings_url}", 'w'){|o|o.write file}
				file
			else
				open("public#{massr_settings_url}", &:read)
			end
		)

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
