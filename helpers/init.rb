# -*- coding: utf-8; -*-
#
# helpers/init.rb : initialize helper
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/wasamas/massr
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
				@current_user ||= User.find_by(id: session[:user_id])
			end

			def send_mail(user, statement)

				body = statement.body ? statement.body : ""
				msg = <<-MAIL
					#{_res_from(statement.user.name)}:

					#{_res_body(body.strip)}
				MAIL

				Thread.start do
					begin
						Mail.deliver do
							from 'no-reply@wasamas.net'
							to	user.email
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

			def param_date
				date = params[:date] ? params[:date] : (Time.now + 10).strftime("%Y%m%d%H%M%S")
			end

			def get_icon_url(user)
				user['twitter_icon_url_https']
			end

			def icon_dir
				SETTINGS['resource']['icon_dir'] || 'default'
			end

			def image_size_change(url, size, centering)
				begin
					host = url.match(%r|\Ahttps?://(.*?)/|)[1]
				rescue NoMethodError
					puts "Fatal error in image_size_change cause by dirty cache"
				end

				if (host =~ /\A[0-9a-zA-Z]+\.googleusercontent\.com\z/)
					pattern = /\/([whs][0-9]+|r(90|180|270)|-|c|p|o|d)+\//
					if url =~ pattern
						if centering
							url.sub(pattern , "/s#{size}-c/")
						else
							url.sub(pattern , "/s#{size}/")
						end
					else
						if centering
							url.split('/').insert(-2,"s#{size}-c").join('/')
						else
							url.split('/').insert(-2,"s#{size}").join('/')
						end
					end
				elsif host =~ /^(i|thumb)\.gyazo\.com$/
					url.sub(%r|/thumb/\d+/|, "/thumb/#{size}/")
				else
					url
				end
			end

			def stamps
				cache.get('stamp')
			end

			def get_stamp(photo)
				dst = image_size_change(photo,1,false)
				Massr::Stamp.find_by(image_url: dst)
			end

			def clear_search_cache(body)
				new_query_list = (cache.get('query_list') || []).reject{|query|
					if /#{query}/i =~ body
						cache.delete("search:#{query}")
						true
					else
						false
					end
				}
				cache.set('query_list', new_query_list)
			end
		end
	end
end

class String
	def truncate(len = 20)
		matched = self.gsub( /\n/, ' ' ).scan( /^.{0,#{len - 3}}/u )[0]
		($'.nil? || $'.empty?) ? matched : matched + '...'
	end
end

require_relative 'resource'
require_relative 'media'
require_relative 'stats'
