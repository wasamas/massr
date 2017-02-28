# -*- coding: utf-8; -*-
#
# routes/stamp.rb
#
# Copyright (C) 2015 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base
		before '/stamp' do
			cache.delete('stamp') unless request.get?
		end

		post '/stamp' do
			@stamp = Stamp.new
			@stamp.update_stamp( request ) unless (request[:image_url].size == 0 || request[:statement_id].size == 0)
		end

		delete '/stamp' do
			Stamp.delete_stamp(params[:image_url])
			redirect '/'
		end

		after '/stamp' do
			cache.set('stamp', Stamp.get_stamps {|i| i.to_hash}) unless request.get?
		end

		get '/stamps' do
			haml :user_photos, :locals => {
				:statements => cache.get('stamp').map {|s| s.original},
				:q => nil,
				:pagenation => false}
		end

		post '/stamp/tag' do
			@stamp = Stamp.find_by(id: request[:stamp_id])
			@stamp.update_tag( request ) unless @stamp.nil?
			cache.delete('stamp')
			cache.set('stamp', Stamp.get_stamps {|i| i.to_hash})
			@stamp.to_hash.to_json
		end
	end
end
