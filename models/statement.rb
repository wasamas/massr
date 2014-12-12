# -*- coding: utf-8; -*-
require 'mongo_mapper'
require 'json'
require 'uri'

module Massr
	class Statement
		include MongoMapper::Document

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

		def self.add_photo(id,uri)
			statement = Statement.find_by_id(id)
			statement[:photos] << uri.to_s
			statement.save!
		end

		def self.delete_all_statements(user, options={})
			options[:user_id] = user._id
			Statement.destroy_all(options)

			options={}
			options[:"likes.user_id"] = user._id
			statements = self.all(options)

			statements.each do |statement|
				statement.likes.delete_if{ |like| like.user_id == user._id}
				statement.save!
			end
		end

		def update_statement(request)
			self[:body], self[:photos] = request[:body], request[:photos]

			user = request[:user]
			self.user  = user

			if request[:res_id]
				res_statement  = Statement.find_by_id(request[:res_id])
				res_statement.refs << self
				self.res = res_statement
				if res_statement.user.massr_id != user.massr_id
					res_statement.user.ress << self
				end
			end

			if save!
				if request[:res_id]
					res_statement.save!
					res_statement.user.save!
				end

				# body内の画像
				re = URI.regexp(['http', 'https'])
				request_uri = URI.parse(request.url)
				self[:body].scan(re) do
					uri = URI.parse($&) rescue next
					next if uri.host == request_uri.host
					response = nil
					Massr::Plugin::AsyncRequest.new(uri).future.add_photo(self._id)
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
