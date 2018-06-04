# -*- coding: utf-8; -*-
#
# helpers/resource.rb : settings and resources
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/wasamas/massr
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
		custom_settings = JSON.parse(open("public#{custom_settings_uri}", &:read)) if custom_settings_uri
		default_settings.keys.each do |key|
			default_settings[key].merge!(custom_settings[key]) if custom_settings[key]
		end
		SETTINGS = default_settings

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

		# needs a cache plugin instance
		unless PLUGINS.find{|plugin| plugin.class.to_s =~ /^Massr::Plugin::Cache::/}
			require_relative "../plugins/cache/memcached"
			PLUGINS << Massr::Plugin::Cache::Memcached.new('default')
		end

		# define methods to search plugin instance
		helpers do
			[:notify, :media, :cache].each do |genre|
				define_method("#{genre}_plugins") do
					PLUGINS.select do |plugin|
						/^Massr::Plugin::#{genre.to_s.capitalize}::/ =~ plugin.class.to_s
					end
				end

				define_method(genre) do
					__send__("#{genre}_plugins").first
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
