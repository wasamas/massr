module Models
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
end
