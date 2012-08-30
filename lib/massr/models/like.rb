# -*- coding: utf-8; -*-

module Massr
	class Like
		include MongoMapper::Document

		key :entry_id, :type => ObjectId, :required => true
		key :user_id,  :type => ObjectId, :required => true
		key :is_read,  :type => Boolean,  :required => true 
		timestamps!
		
		belongs_to :entry, :class_name => 'Entry', :in => :entry_id
		belongs_to :user, :class_name => 'User',  :in=> :user_id
	end 
end
