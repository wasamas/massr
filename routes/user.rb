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

		before "/user/:massr_id*" do
			@user = User.find_by_massr_id(params[:massr_id].sub(/\.json$/,""))
			@total = total_page({:user_id => @user.id})
			@page = [current_page, @total].min
		end

		get '/user/:massr_id.json' do
			date = params[:date] ? params[:date] : Time.now.strftime("%Y%m%d%H%M%S")
			[].tap {|a|
				Statement.get_statements_by_date(date, {:user_id => @user.id}).each do |statement|
					a << statement.to_hash
				end
			}.to_json
		end

		get '/user/:massr_id' do
			haml :user_statements , :locals => {
				:page => @page,
				:statements => Statement.get_statements_by_page(@page, {:user_id => @user.id}),
				:total_page => @total,
				:q => nil}
		end

		before '/user/:massr_id/res*' do
			user = User.find_by_massr_id(params[:massr_id])
			statements = Statement.where(:user_id => user.id)
			received_id = Array.new
			statements.each do |statement|
				received_id |= (statement.ref_ids) unless statement.ref_ids.nil?
			end
			@query = {:_id => { :$in => received_id.uniq }}
			@total = total_page(@query)
			@page = [current_page, @total].min
		end

		get '/user/:massr_id/res.json' do
			date = params[:date] ? params[:date] : Time.now.strftime("%Y%m%d%H%M%S")
			[].tap { |a|
				Statement.get_statements_by_date(date, @query).each do |statement|
					a << statement.to_hash
				end
			}.to_json
		end

		get '/user/:massr_id/res' do
			haml :user_statements, :locals => {
				:page => @page,
				:statements => Statement.get_statements_by_page(@page, @query),
				:total_page => @total,
				:q => nil}
		end

		before '/user/:massr_id/liked*' do
			user = User.find_by_massr_id(params[:massr_id])
			@query = {:user_id => user.id, "likes.user_id" => {:$exists => true} }
			@total = total_page(@query)
			@page = [current_page, @total].min
		end

		get '/user/:massr_id/liked.json' do
			date = params[:date] ? params[:date] : Time.now.strftime("%Y%m%d%H%M%S")
			[].tap {|a|
				Statement.get_statements_by_date(date, @query).each do |statement|
					a << statement.to_hash
				end
			}.to_json
		end

		get '/user/:massr_id/liked' do
			haml :user_statements, :locals => {
				:page => @page,
				:statements => Statement.get_statements_by_page(@page, @query),
				:total_page => @total,
				:q => nil}
		end

		before '/user/:massr_id/likes*' do
			user = User.find_by_massr_id(params[:massr_id])
			@query = {"likes.user_id" => user.id }
			@total = total_page(@query)
			@page = [current_page, @total].min
		end

		get '/user/:massr_id/likes.json' do
			date = params[:date] ? params[:date] : Time.now.strftime("%Y%m%d%H%M%S")
			[].tap {|a|
				Statement.get_statements_by_date(date, @query).each do |statement|
					a << statement.to_hash
				end
			}.to_json
		end

		get '/user/:massr_id/likes' do
			haml :user_statements, :locals => {
				:page => @page,
				:statements => Statement.get_statements_by_page(@page, @query),
				:total_page => @total,
				:q => nil}
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

		put '/user/:massr_id' do
			user =  User.find_by_id(session[:user_id])
			redirect '/' unless user.admin?
			User.change_status(params[:massr_id],params[:status])
		end
	end
end


