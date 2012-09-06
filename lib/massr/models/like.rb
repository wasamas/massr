# -*- coding: utf-8; -*-
require 'mongo_mapper'

module Massr
	class Like
		include MongoMapper::EmbeddedDocument

		key :is_read,  :type => Boolean,  :required => true 
		timestamps!

		embedded_in :entry
		belongs_to :user  , :class_name => 'Massr::User'

	end 
end
