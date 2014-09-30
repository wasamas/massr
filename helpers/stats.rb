# -*- coding: utf-8; -*-
#
# helpers/stats.rb : system statuses
#
# Copyright (C) 2014 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base
		helpers do
			def stats(item)
				MongoMapper.database.stats[item.to_s]
			end
		end
	end
end
