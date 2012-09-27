# -*- coding: utf-8; -*-
#
# routes/user.rb
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base
		get '/users.html' do
			haml :users , :locals => { :users => User.sort(:created_at.desc) }
		end

		get '/user' do
			haml :user
		end

		get '/user/:massr_id' do
			user = User.find_by_massr_id(params[:massr_id])
			total = total_page({:user_id => user.id})
			page = params[:page]
			if page =~ /^\d+/
				page = page.to_i
			else
				page = 1
			end
			page = [page, total].min
			haml :user_statements , :locals => {
				:page => page,
				:statements => Statement.get_statements(page, {:user_id => user.id}),
				:total_page => total}
		end

		get '/user/:massr_id/liked' do
			user = User.find_by_massr_id(params[:massr_id])
			query = {:user_id => user.id, "likes.user_id" => {:$exists => true} }
			total = total_page(query)
			page = params[:page]
			if page =~ /^\d+/
				page = page.to_i
			else
				page = 1
			end
			page = [page, total].min
			haml :user_statements, :locals => {
				:page => page,
				:statements => Statement.get_statements(page, query),
				:total_page => total}
		end

		get '/user/:massr_id/likes' do
			user = User.find_by_massr_id(params[:massr_id])
			query = {"likes.user_id" => user.id }
			total = total_page(query)
			page = params[:page]
			if page =~ /^\d+/
				page = page.to_i
			else
				page = 1
			end
			page = [page, total].min
			haml :user_statements, :locals => {
				:page => page,
				:statements => Statement.get_statements(page, query),
				:total_page => total}
		end

		post '/user' do
			user = User.find_by_id(session[:user_id])
			request[:twitter_id] = session[:twitter_id]
			request[:twitter_icon_url] = session[:twitter_icon_url]
			if user
				user.update_profile(request)
			else
				user = User.create_by_registration_form( request )
				session[:user_id] = user._id
			end

			redirect '/'
		end

		delete '/user' do
			user = User.find_by_id(session[:user_id])
			user.destroy
			session.clear
			redirect '/'
		end

		put '/user/:massr_id' do
			user =  User.find_by_id(session[:user_id])
			redirect '/' unless user.admin?
			User.change_status(params[:massr_id],params[:status])
		end
	end
end


