# -*- coding: utf-8; -*-
require 'mongo_mapper'
require 'json'

module Massr
	class Statement
		include MongoMapper::Document
		safe
		
		key :body,  :type => String, :required => true
		key :photo, :type => String
		key :ref_ids, Array

		timestamps!

		belongs_to :user  , :class_name => 'Massr::User'
		belongs_to :res   , :class_name => 'Massr::Statement'
		many       :likes , :class_name => 'Massr::Like'  , :dependent => :delete_all
		many       :refs  , :class_name => 'Massr::Statement' , :in => :ref_ids

		def self.get_statements(page,options={})
			options[:order]    = :created_at.desc
			options[:per_page] = $limit
			options[:page]     = page
			return self.paginate(options)
		end

		def update_statement(request)
			self[:body]  = request[:body]
			self[:photo] = request[:photo] if request[:photo]

			if request[:res_id]
				res_statement  = Statement.find_by_id(request[:res_id])
				res_statement.refs << self
				self.res   = res_statement
			end

			user = request[:user]
			self.user  = user

			if save!
				user.statements << self
				user.save!
				res_statement.save! if request[:res_id]
			end

			return self
		end

		def like?(user)
			likes.map{|like| like.user._id == user._id}.include?(true)
		end

		def to_hash
			{
				'id' => id,
				'body' => body,
				'user' => user.to_hash,
				'likes' => likes.map{|l| l.to_hash},
				'ref_ids' => ref_ids,
				'res_id' => res_id,
			}
		end
	end
end
