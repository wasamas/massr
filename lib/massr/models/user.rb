# -*- coding: utf-8; -*-
require 'mongo_mapper'

module Massr
	class User
		include MongoMapper::Document
		safe
		
		key :massr_id,   :type => String,  :required => true ,:unique => true
		key :twitter_id, :type => String,  :required => true ,:unique => true
		key :name,       :type => String,  :required => true
		key :email,      :type => String,  :required => true

		timestamps!
	end
end
