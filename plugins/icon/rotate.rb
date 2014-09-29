# -*- coding: utf-8; -*-
#
# plugins/icon/rotate.rb : massr icon plugin for monthly masao
#
# Copyright (C) 2014 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#
# Usage:
#    "plugin": {
#       "icon/rotate" : {}
#    }
#
module Massr
	module Plugin::Icon
		class Rotate
			def initialize(plugin_id, opts)
			end
		end
	end

	class App < Sinatra::Base
		helpers do
			def icon_dir
				Time.now.strftime("%m") || SETTINGS['resource']['icon_dir'] || 'default'
			end
		end
	end
end

