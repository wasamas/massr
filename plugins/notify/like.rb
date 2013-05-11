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
#          "delete": "any"   // "any" or "owner"
#          "volatile": true, // true or false / only true now
#       }
#    }
#
module Massr
	module Plugin::Notify
		class Like
			LIKES = {} unless const_defined? :LIKES
			SETTINGS = {} unless const_defined? :SETTINGS

			attr_reader :label, :delete

			def self.likes(id)
				LIKES[id]
			end

			def self.add(id, me)
				likes(id)[me.massr_id] = [me.twitter_icon_url, me.twitter_icon_url_https]
			end

			def self.delete(id, name, me)
				case SETTINGS[id].delete
				when 'owner'
					return likes(id).delete(name) if name == me.massr_id
				when 'any'
					return likes(id).delete(name)
				end
				return nil
			end

			def self.to_json(id)
				likes(id).to_json
			end

			def initialize(plugin_id, opts)
				@id = plugin_id
				LIKES[@id] = {}
				SETTINGS[@id] = self

				@label = opts['label'] || ''
				@delete = opts['delete'] || 'owner'
				### future function ### @volatile = opts['volatile'] || true
			end

			def render
				html = "#{@label}&nbsp;"
				html << %Q|<span class="pull-right"><a class="close" href="#" id="#{@id}-like"><img src="/img/wakaranaiwa.png"></a>|
				html << %Q|<a class="close" href="#" id="#{@id}-unlike"><img src="/img/wakaruwa.png"></a></span>|
				html << %Q|<span id="#{@id}">#{icons}</span>|
			end

		private

			def icons
				LIKES[@id].map{|user, (http, https)|
					case @delete
					when "any"
						%Q|<a href="#" class="#{@id}-delete"><img class="massr-icon-mini" src="#{https}" alt="#{user}" title="delete #{user}"></a>&nbsp;|
					else # "owner"
						%Q|<img class="massr-icon-mini" src="#{https}" alt="#{user}">|
					end
				}.join
			end
		end
	end

	class App < Sinatra::Base
		get '/plugin/notify/like/:plugin.json' do
			Massr::Plugin::Notify::Like.to_json(params[:plugin])
		end

		post '/plugin/notify/like/:plugin' do
			me = User.find_by_id(session[:user_id])
			Massr::Plugin::Notify::Like.add(params[:plugin], me)
			Massr::Plugin::Notify::Like.to_json(params[:plugin])
		end

		delete '/plugin/notify/like/:plugin/:user' do
			me = User.find_by_id(session[:user_id])
			Massr::Plugin::Notify::Like.delete(params[:plugin], params[:user], me)
			Massr::Plugin::Notify::Like.to_json(params[:plugin])
		end
	end
end

