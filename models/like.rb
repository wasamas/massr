module Massr
	class Like
		include ::Mongoid::Document
		include ::Mongoid::Timestamps

		field :is_read,  :type => Boolean
		validates_presence_of :is_read

		embedded_in :statement, class_name: 'Massr::Statement', inverse_of: :likes
		belongs_to :user, class_name: 'Massr::User'

		def to_hash
			{
				'id' => id.to_s,
				'user' => user.to_hash,
			}
		end
	end
end
