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

		def self.get_stamps(options={})
			options[:order] = :popular.desc
			return self.all(options)
		end

		def self.get_statements(options={})
			stamps = get_stamps(options)
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
				'id' => id,
				'created_at' => created_at.localtime.strftime('%Y-%m-%d %H:%M:%S'),
				'image_url' => image_url,
				'tag' => tag,
				'popular' => popular,
				'original' => original ? original.to_hash : nil
			}
		end
	end
end
