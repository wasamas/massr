# -*- coding: utf-8; -*-

module Massr
	class Message
		include MongoMapper::Document
		
		key :from_user_id, :type => ObjectId, :required => true
		key :to_user_id,   :type => ObjectId, :required => true
		key :message,      :type => String,   :required => true
		timestamps!

		belongs_to :user, :class_name => 'User',  :in=> :from_user_id
		belongs_to :user, :class_name => 'User',  :in=> :to_user_id
	end
end
