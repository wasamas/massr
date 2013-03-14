# -*- coding: utf-8; -*-
#
# helpers/resource.rb : settings and resources
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
			if %r|\Ahttps?://| =~ env
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

		PLUGINS = []
		SETTINGS['plugin'].each do |plugin_name, opts|
			begin
				genre, klass, label = plugin_name.split(/[\/ ]/)
				require_relative "../plugins/#{genre}/#{klass}"
				PLUGINS << (Massr::Plugin.const_get(genre.capitalize)).const_get(klass.capitalize).new(label, opts)
			rescue LoadError
				puts "cannot load plugin: #{plugin_name}."
			rescue NameError
				puts "load plugin module not found: #{genre}/#{klass}"
			end
		end

		helpers do
			def notify_plugins
				PLUGINS.select do |plugin|
					/^Massr::Plugin::Notify::/ =~ plugin.class.to_s
				end
			end
		end

		SETTINGS['local'].each do |key, value|
			define_method("_#{key}"){|*args|
				value.gsub(/%(\d+)/){args[$1.to_i - 1]}
			}
		end
	end
end
