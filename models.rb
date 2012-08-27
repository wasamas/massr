module Models
	
	MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
	MongoMapper.database = 'massr'
	
	class User
		include MongoMapper::Document
		safe
		
		key :twitter_id, :type => String,  :required => true
		key :name,       :type => String,  :required => true
		key :email,      :type => String,  :required => true
		key :token,      :type => String,  :required => true

		timestamps!
	end


	class Entry
		include MongoMapper::Document
		
		key :user_id, :type => ObjectId
		key :entry,   :type => String,   :required => true
		key :res_id,  :type => ObjectId
		key :photo,   :type => String

		timestamps!
		
		safe
		
		belongs_to :user, :class_name => 'User',  :in=> :user_id
		belongs_to :res , :class_name => 'Entry', :in=> :res_id
		many :likes
	end


	class Message
		include MongoMapper::Document
		
		key :from_user_id, :type => ObjectId, :required => true
		key :to_user_id,   :type => ObjectId, :required => true
		key :message,      :type => String,   :required => true
		timestamps!

		safe
		
		belongs_to :user, :class_name => 'User',  :in=> :from_user_id
		belongs_to :user, :class_name => 'User',  :in=> :to_user_id
	end

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
