# -*- coding: utf-8; -*-
#
# routes/statement.rb
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base
		post '/statement.?:format?' do
			@statement = Statement.new

			request[:user] = User.find_by(id: session[:user_id])
			begin
				(request[:photos] ||= []) << media_upload(params[:photo], SETTINGS['setting']['upload_photo_size'])
			rescue Massr::NoPhotoError
				# no photos
			end

			begin
				if (request[:stamp].nil?)
					@statement.update_statement( request ) unless request[:body].size == 0
				else
					@statement.update_statement( request ) unless request[:stamp].size == 0
					stamp = Stamp.find_by(id: request[:stamp_id])
					stamp.post_stamp() unless stamp.nil?
					cache.delete('stamp')
					cache.set('stamp', Stamp.get_stamps.map{|i| i.to_hash})
				end
				if @statement.res && @statement.res.user.email.length > 0 && @statement.res.user.massr_id != request[:user].massr_id
					send_mail(@statement.res.user, @statement)
				end
			rescue
				return 404
			end

			if params[:format] == 'json'
				@statement.to_hash.to_json
			else
				redirect '/'
			end
		end

		before '/statement/:id.?:format?' do
			case params[:id]
			when 'photos'
				@query = {"photos" => {:$ne => [] } }
			else
				@statement = Statement.find_by(id: params[:id])
				not_found unless @statement
			end
		end

		after '/statement*' do
			unless request.get?
				clear_search_cache(@statement.body) rescue nil
			end
		end


		get '/statement/photos' do
			#haml :user_photos, :locals => {
			#	:statements => Statement.get_statements(param_date, @query),
			#	:q => nil,
			#	:pagenation => true}
			haml :index , :locals => {:q => nil}
		end

		get '/statement/photos.json' do
			[].tap {|a|
				Statement.get_statements(param_date, @query).each do |statement|
					a << statement.to_hash
				end
			}.to_json
		end

		get '/statement/:id.json' do
			@statement.to_hash.to_json
		end

		get '/statement/:id' do
			haml :user_statement, locals: {statement: @statement}
		end

		delete '/statement/:id' do
			if current_user == Statement.find_by(id: params[:id]).user
				stamp =  Stamp.find_by("original.id": params[:id])
				stamp.destroy if stamp
				Statement.find_by(_id: params[:id]).delete
			end
			redirect '/'
		end

		before '/statement/:id/like' do
			@user = User.find_by(id: session[:user_id])
			@statement = Statement.find_by(id: params[:id])
			not_found unless @statement
		end

		post '/statement/:id/like' do
			@statement.likes.delete_if{|like| !like.user}
			unless @statement.like?(@user)
				@statement.add_like(Like.new(user: @user))
			end
			@statement.to_hash.to_json
		end

		delete '/statement/:id/like' do
			@statement.likes.delete_if{ |like| !like.user}
			@statement.likes.delete_if{ |like| like.user.id == @user._id}
			@statement.save!(validate: false)
			@statement.to_hash.to_json
		end
	end
end
