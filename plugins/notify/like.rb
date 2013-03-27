# -*- coding: utf-8; -*-
#
# plugins/notify/like.rb : massr notify plugin for global like
#
# Copyright (C) 2013 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#
# Usage:
#    "plugin": {
#       "notify/like party": {
#          "label": "Do you attend the party?",
#          "delete": "any"   // "any" or "owner" / only "owner" now
#          "volatile": true, // true or false / only true now
#       }
#    }
#
module Massr
	module Plugin::Notify
		class Like
			LIKES = {} unless const_defined? :LIKES

			def self.likes(id)
				LIKES[id]
			end

			def initialize(plugin_id, opts)
				@id = plugin_id
				LIKES[@id] = {}

				@label = opts['label'] || ''
				@delete = opts['delete'] || 'owner'
				### future function ### @volatile = opts['volatile'] || true
			end

			def render
				html = "#{@label}&nbsp;"
				html << %Q|<span id="#{@id}">#{icons}</span>|
				html << %Q|<a class="close" href="#" id="#{@id}-like"><img src="/img/wakaranaiwa.png"></a>|
				html << %Q|<a class="close" href="#" id="#{@id}-unlike"><img src="/img/wakaruwa.png"></a>|
			end

		private

			def icons
				LIKES[@id].map{|user, (http, https)|
					case @delete
					when "any"
						%Q|<a href="#" class="#{@id}-delete"><img class="massr-icon-mini" src="#{https}" alt="#{user}"></a>|
					else # "owner"
						%Q|<img class="massr-icon-mini" src="#{https}" alt="#{user}">|
					end
				}.join("\n")
			end
		end
	end

	class App < Sinatra::Base
		get '/plugin/notify/like/:plugin.json' do
			Massr::Plugin::Notify::Like.likes(params[:plugin]).to_json
		end

		post '/plugin/notify/like/:plugin' do
			me = User.find_by_id(session[:user_id])
			likes = Massr::Plugin::Notify::Like.likes(params[:plugin])
			likes[me.massr_id] = [me.twitter_icon_url, me.twitter_icon_url_https]
			likes.to_json
		end

		delete '/plugin/notify/like/:plugin/:user' do
			me = User.find_by_id(session[:user_id])
			likes = Massr::Plugin::Notify::Like.likes(params[:plugin])
			likes.delete(params[:user]) if me.massr_id == params[:user]
			likes.to_json
		end
	end
end

