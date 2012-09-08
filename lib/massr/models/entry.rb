# -*- coding: utf-8; -*-
require 'mongo_mapper'

module Massr
	class Entry
		include MongoMapper::Document
		safe
		
		key :body,  :type => String, :required => true
		key :photo, :type => String

		timestamps!

		belongs_to :user  , :class_name => 'Massr::User'
		belongs_to :res   , :class_name => 'Massr::Entry'
		many       :likes , :class_name => 'Massr::Like'
		many       :ref   , :class_name => 'Massr::Entry'

		def update_entry(request,session)
			self[:body]  = request[:body]
			self[:photo] = request[:photo] if request[:photo]
			if request[:res_id]
				res_entry  = Entry.find_by_id(request[:res_id])
				self.res   = res_entry
				res_entry.ref << self
			end
			self.user  = session[:user]
			save!

			return self
		end
	end
end
