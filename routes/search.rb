# -*- coding: utf-8; -*-
#
# routes/search.rb
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#
module Massr
	class App < Sinatra::Base
		before '/search*' do
			@q = params[:q].strip if params[:q]
			redirect '/' unless @q
		end

		get '/search.json' do
			[].tap {|a|
				Statement.get_statements(param_date,{:body => /#{@q}/}).each do |statement|
					a << statement.to_hash
				end
			}.to_json
		end

		get '/search' do
			if @q.size == 0 then
				redirect '/'
				return
			end

			if @q != params[:q] then
				redirect '/search?q=' + @q
				return
			end

			cache = Massr::Plugin::Memcached.query_list.include_list?(@q) ? Massr::Plugin::Memcached.search(@q).get : nil

			if(cache)
				statements = Array.new
				cache.each do |statement|
					statements << Statement.from_json(statement.to_json)
				end

			else
				statements = Statement.get_statements(param_date,{:body => /#{@q}/i})
				Massr::Plugin::Memcached.query_list.add_list(@q)

				Statement.include_root_in_json = true
				Massr::Plugin::Memcached.search(@q).set(statements.as_json)
			end
			begin
				page = haml :index , :locals => {
					:statements => statements ,
					:q => @q}
			rescue RegexpError
				redirect '/'
			end
		end

		get '/search/pins.json' do
			[].tap{|h|
				SearchPin.all.each do |pin|
					h << {'q' => h[pin.word], 'label' => h[pin.label]}
				end
			}.to_json
		end

		post '/search/pin' do
			begin
				pin = SearchPin.create_by_word(params[:q], params[:label])
				return [{'q' => pin.word, 'label' => pin.label}].to_json
			rescue MongoMapper::DocumentNotValid
				return 409
			end
		end

		delete '/search/pin' do
			begin
				pin = SearchPin.find_by_word(params[:q])
				SearchPin.destroy(pin.id)
				return [{'q' => pin.word, 'label' => pin.label}].to_json
			rescue NoMethodError
				return 404
			end
		end

		put '/search/pin' do
			begin
				pin = SearchPin::find_by_word(params[:q])
				pin.label = params[:label]
				return [{'q' => pin.word, 'label' => pin.label}].to_json
			rescue NoMethodError
				return 404
			end
		end

		after '/search/pin' do
			if (not request.get?)
				Massr::Plugin::Memcached.cache_cleaner.async.clean_cache(params[:q])
			end
		end
	end
end


