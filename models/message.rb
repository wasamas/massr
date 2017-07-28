module Massr
	class Message
		include ::Mongoid::Document
		include ::Mongoid::Timestamps
		store_in collection: 'massr.messages'
		
		field :from_user_id, type: ObjectId
		field :to_user_id,   type: ObjectId
		field :message,      type: String
		validates_presence_of :from_user_id, :to_user_id, :message

		belongs_to :user, class_name: 'User',  in: :from_user_id
		belongs_to :user, class_name: 'User',  in: :to_user_id
	end
end
