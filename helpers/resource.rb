# -*- coding: utf-8; -*-
#
# helpers/resource.rb : language resource
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base
		SETTINGS = JSON.parse(open('public/settings.json', &:read))

		SETTINGS['local'].each do |key, value|
			define_method("_#{key}"){|*args|
				value.gsub(/%(\d+)/){args[$1.to_i - 1]}
			}
		end
	end
end
