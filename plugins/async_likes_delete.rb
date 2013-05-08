# -*- coding: utf-8; -*-
#
# plugins/async_likes_delete.rb : massr plugin of async likes_delete
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#
require 'thread'
require 'celluloid'

module Massr
	module Plugin
		class AsyncLikesDelete
			include Celluloid

			exclusive

			def initialize(statements, user_id)
				@statements = statements
				@user_id    = user_id
			end

			def delete
				@statements.each do |statement|
					statement.likes.delete_if{ |like| like.user_id == @user_id}
					statement.save!
				end
			end
		end
	end
end
