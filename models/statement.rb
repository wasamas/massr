# -*- coding: utf-8; -*-
require 'mongo_mapper'
require 'json'
require 'uri'
require 'net/http'
require 'net/https'
require 'picasa'

module Massr
	class Statement
		include MongoMapper::Document
		safe
		
		key :body,  :type => String, :required => true
		key :photos, Array
		key :ref_ids, Array

		timestamps!

		belongs_to :user  , :class_name => 'Massr::User'
		belongs_to :res   , :class_name => 'Massr::Statement'
		many       :likes , :class_name => 'Massr::Like'  , :dependent => :delete_all
		many       :refs  , :class_name => 'Massr::Statement' , :in => :ref_ids

		def self.get_statements(date,options={})
			options[:created_at.lt] = Time.parse(date)
			options[:order]         = :created_at.desc
			options[:limit]         = $limit
			return self.all(options)
		end

		def update_statement(request)
			self[:body], self[:photos] = request[:body], request[:photos]
			
			# body内の画像
			re = URI.regexp(['http', 'https'])
			request_uri = URI.parse(request.url)
			self[:body].scan(re) do 
				uri = URI.parse($&)
				next if uri.host == request_uri.host
				response = nil
				begin
					proxy = if uri.scheme == 'https'
						URI(ENV['https_proxy'] || '')
					else
						URI(ENV['http_proxy'] || '')
					end
					nethttp = Net::HTTP::Proxy(proxy.host, proxy.port).new( uri.host, uri.port )
					nethttp.use_ssl = true if uri.scheme == 'https'
					nethttp.start do |http|
						response = http.head( uri.request_uri )
						self[:photos] << uri.to_s if response["content-type"].to_s.include?('image')
					end
				rescue SocketError => e
					#URLの先が存在しないなど。
				end
			end

			user = request[:user]
			self.user  = user

			if request[:res_id]
				res_statement  = Statement.find_by_id(request[:res_id])
				res_statement.refs << self
				self.res   = res_statement
				
				res_statement.user.ress << self
			end


			if save!
				if request[:res_id]
					res_statement.save!
					res_statement.user.save!
				end
			end

			return self
		end

		def like?(user)
			likes.map{|like| like.user._id == user._id}.include?(true)
		end

		def to_hash
			res = Statement.find_by_id(res_id)
			{
				'id' => id,
				'created_at' => created_at.localtime.strftime('%Y-%m-%d %H:%M:%S'),
				'body' => body,
				'user' => user.to_hash,
				'likes' => likes.map{|l| l.to_hash},
				'ref_ids' => ref_ids,
				'res' => res ? res.to_hash : nil,
				'photos' => photos
			}
		end
	end
end
