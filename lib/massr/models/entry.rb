# -*- coding: utf-8; -*-
require 'mongo_mapper'

module Massr
	class Entry
		include MongoMapper::Document
		safe
		
		key :body,  :type => String, :required => true
		key :photo, :type => String
		key :ref_ids, Array

		timestamps!

		belongs_to :user  , :class_name => 'Massr::User'
		belongs_to :res   , :class_name => 'Massr::Entry'
		many       :likes , :class_name => 'Massr::Like'  , :dependent => :delete_all
		many       :refs  , :class_name => 'Massr::Entry' , :in => :ref_ids

		def self.get_entries(page,options={})
			options[:order]    = :created_at.desc
			options[:per_page] = $limit
			options[:page]     = page
			return self.paginate(options)
		end

		def update_entry(request)
			self[:body]  = request[:body]
			self[:photo] = request[:photo] if request[:photo]

			if request[:res_id]
				res_entry  = Entry.find_by_id(request[:res_id])
				res_entry.refs << self
				self.res   = res_entry
			end

			user = request[:user]
			self.user  = user
			
			if save!
				user.entries << self
				user.save!
				res_entry.save! if request[:res_id]
			end

			return self
		end
		
	end
end
