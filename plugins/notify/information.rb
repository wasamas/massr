# -*- coding: utf-8; -*-
#
# plugins/notify/information.rb : massr notify plugin for information message on top of page
#
# Copyright (C) 2013 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#
# Usage:
#    "plugin": {
#       "notify/information": {
#          "message": "message text here"
#       }
#    }
#
module Massr
	module Plugin::Notify
		class Information
			def initialize(opts)
				@message = opts['message'] || nil
			end

			def render
				@message
			end
		end
	end
end
