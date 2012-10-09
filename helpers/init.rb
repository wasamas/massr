# -*- coding: utf-8; -*-
#
# helpers/init.rb : initialize helper
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#
require 'mail'

module Massr
	class App < Sinatra::Base
		helpers do
			def csrf_meta
				{:name => "_csrf", :content => Rack::Csrf.token(env)}
			end

			def csrf_input
				{:type => 'hidden', :name => '_csrf', :value => Rack::Csrf.token(env)}
			end

			def current_user
				@current_user ||= User.find_by_id(session[:user_id])
			end

			def total_page( query = {} )
				[Statement.count(query) / ($limit + 0.0), 1].max.ceil
			end

			def page_query_param(page, query)
				param = {
					:page => page > 1 ? page : nil,
					:q => query
				}.map{|k, v| v ? "#{k}=#{v}" : nil}.compact.join('&')

				param.prepend('?') unless param.empty?

				return param
			end

			def send_mail(user, statement)
				msg = <<-MAIL
					#{statement.user.name}さんからレスがありました:

					「#{statement.body}」
				MAIL

				Thread.start do
					begin
						Mail.deliver do
							from 'no-reply@tdtds.jp'
							to  user.email
							subject 'Message from Massr'
							content_type 'text/plain; charset=UTF-8'
							body msg.gsub(/^\t+/, '')
						end
						puts "sending mail to #{user.massr_id} successfully."
					rescue => e
						puts e.to_s
					end
				end
			end

			def random_masao
				"/img/masao#{['', '2', '3'].sample}.jpg"
			end
		end
	end
end

require_relative 'resource'
require_relative 'picasa'
