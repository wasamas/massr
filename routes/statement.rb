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
		post '/statement' do
			statement = Statement.new
			request[:user] = User.find_by_id(session[:user_id])
			statement.update_statement( request ) unless request[:body].size==0
			redirect '/'
		end
		
		get '/statement/:id.json' do
			Statement.find_by_id(params[:id]).to_json
		end

		get '/statement/:id' do
			haml :user_statement, :locals => {:statement => Statement.find_by_id(params[:id])}
		end

		delete '/statement/:id' do
			Statement.destroy(params[:id])
			redirect '/'
		end

		before '/statement/:id/like' do
			@user = User.find_by_id(session[:user_id])
			@statement = Statement.find_by_id(params[:id])
		end
		
		post '/statement/:id/like' do
			@statement.likes.delete_if{ |like| !like.user}
			unless ((@statement.likes.map{|like| like.user._id == @user._id  }).include? true)
				like = Like.new(:user => @user)
				@statement.likes << like
			end
			@statement.save!
			redirect '/'
		end

		delete '/statement/:id/like' do
			@statement.likes.delete_if{ |like| !like.user}
			@statement.likes.delete_if{ |like| like.user.id == @user._id}
			@statement.save!
			redirect '/'
		end
	end
end

