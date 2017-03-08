require 'json'
require 'uri'

module Massr
	class Stamp
		include ::Mongoid::Document
		include ::Mongoid::Timestamps
		store_in collection: "massr.stapms"

		field :image_url, type: String
		field :popular,   type: Integer, :default => 0
		field :tag,       type: String
		validates_presence_of :image_url
		validates_uniqueness_of :image_url

		belongs_to :original, class_name: 'Massr::Statement', inverse_of: :stamp_source

		def self.get_stamps
			all = self.all
			if block_given?
				return yield(all)
			else
				return all.order_by(popular: 'desc')
			end
		end

		def self.get_statements(&block)
			stamps = get_stamps(&block)
			statements = []

			stamps.each do |stamp|
				original = stamp.original
				if original.is_a? Massr::Statement
					statements << original
				else
					stamp.delete
				end
			end
			return statements
		end

		def self.delete_stamp(url,options={})
			stamp = self.find_by(image_url: url)
			stamp.delete
		end

		def update_stamp(request)
			self[:image_url] = request[:image_url]
			statement = Statement.find_by(id: request[:statement_id])
			self.original = statement
			save!
			return self
		end

		def post_stamp()
			self[:popular] += 1
			save!
			return self
		end

		def update_tag(request)
			self[:tag] = request[:tag]
			save!
			return self
		end

		def to_hash
			original = Statement.find_by(id: original_id)
			{
				'id' => id.to_s,
				'created_at' => created_at.localtime.strftime('%Y-%m-%d %H:%M:%S'),
				'image_url' => image_url,
				'tag' => tag,
				'popular' => popular,
				'original' => original ? original.to_hash : nil
			}
		end
	end
end
