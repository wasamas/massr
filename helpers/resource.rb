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
		custom_settings_uri = nil
		custom_settings = {}
		env = ENV['MASSR_SETTINGS']

		if env # online
			if %r|\Ahttps?://| =~ env
				# saving copy to cache
				custom_settings_uri = '/custom_cache.json'
				open("public#{custom_settings_uri}", 'w'){|o|o.write(open(env, &:read))}
			else # local
				if %r|\.\.| =~ env
					puts "MASSR_SETTINGS cannot contains '..'."
					exit
				end
				custom_settings_uri = env
				custom_settings_uri = '/' + custom_settings_uri if %r|\A/| !~ custom_settings_uri
			end
		end
		default_settings = JSON.parse(open("public/default.json", &:read))
		puts "defailt: #{default_settings}"
		custom_settings = JSON.parse(open("public#{custom_settings_uri}", &:read)) if custom_settings_uri
		puts "custom: #{custom_settings}"
		default_settings.keys.each{|key| default_settings[key].merge!(custom_settings[key])}
		SETTINGS = default_settings
		puts "SETTINGS: #{SETTINGS}"

		define_method(:massr_settings) do
			custom_settings_uri
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
