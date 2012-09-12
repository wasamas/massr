# -*- coding: utf-8; -*-
require 'mongo_mapper'

module Massr
	class User
		include MongoMapper::Document
		safe
		
		key :massr_id,         :type => String,  :required => true ,:unique => true
		key :twitter_id,       :type => String,  :required => true ,:unique => true
		key :twitter_icon_url, :type => String,  :required => true
		key :name,             :type => String,  :required => true
		key :email,            :type => String,  :required => true
		key :admin,            :type => Boolean, :default => false 
		key :entry_ids , Array

		timestamps!

		many :entries , :class_name => 'Massr::Entry', :in => :entry_ids, :dependent => :delete_all 

		def self.create_by_registration_form( request )
			user = User.new( :massr_id => request[:massr_id] )
			user.update_profile( request )
			return user
		end

		def update_profile(request)
			self[:twitter_id] = request[:twitter_id]
			self[:twitter_icon_url] = request[:twitter_icon_url]
			self[:name] = request[:name]
			self[:email] = request[:email]

			save!
			return self
		end
	end
end
