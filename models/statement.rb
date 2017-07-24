require 'uri'

module Massr
	class Statement
		include ::Mongoid::Document
		include ::Mongoid::Timestamps
		store_in collection: "massr.statements"

		field :body,    type: String
		field :stamp,   type: String
		field :photos,  type: Array
		#field :ref_ids, type: Array # do not access directly, use refs field instead

		belongs_to  :user,  class_name: 'Massr::User', inverse_of: :statements
		embeds_many :likes, class_name: 'Massr::Like'

		has_many   :refs,  class_name: 'Massr::Statement', inverse_of: :res
		belongs_to :res,   class_name: 'Massr::Statement', inverse_of: :refs

		has_one :stamp_source, class_name: 'Massr::Stamp', inverse_of: :original

		def custom_validation
			if body.nil && stamp.nil
				errors.add( :body,  "Please enter the body or stamp.")
				errors.add( :stamp,  "Please enter the body or stamp.")
			end
		end

		def self.get_statements(date, queries={})
			queries[:created_at.lt] = Time.parse(date)
			return self.where(queries).order_by(created_at: 'desc').limit($limit)
		end

		def self.add_photo(id, uri)
			statement = Statement.find_by(id: id)
			statement.photos << uri.to_s
			statement.save!(validate: false)
		end

		def self.delete_all_statements(user, options={})
			options[:user_id] = user._id
			Statement.destroy_all(options)

			options={}
			options[:"likes.user_id"] = user._id
			statements = self.all(options)

			statements.each do |statement|
				statement.likes.delete_if{ |like| like.user_id == user._id}
				statement.save!
			end
		end

		def update_statement(request)
			self.user, self.body, self.photos, self.stamp = request[:user], request[:body], request[:photos], request[:stamp]

			if request[:res_id]
				res_statement = Statement.find_by(id: request[:res_id])
				res_statement.refs << self
				if res_statement.user.massr_id != user.massr_id
					res_statement.user.res_ids << self._id
				end
			end

			if save(validate: false)
				if request[:res_id]
					res_statement.save!(validate: false)
					res_statement.user.save!(validate: false)
				end

				# aync add photos in body message
				re = URI.regexp(['http', 'https'])
				request_uri = URI.parse(request.url)
				self.body.scan(re) do
					uri = URI.parse($&) rescue next
					next if uri.host == request_uri.host
					response = nil
					Massr::Plugin::AsyncRequest.new(uri).future.add_photo(self._id)
				end unless self.body.nil?
			end

			return self
		end

		def add_like(user)
			self.likes << user
			save!(validate: false)
		end

		def like?(user)
			likes.map{|like| like.user._id == user._id}.include?(true)
		end

		def to_hash
			res = Statement.find_by(id: res.id) rescue nil
			{
				'id' => id.to_s,
				'created_at' => created_at.localtime.strftime('%Y-%m-%d %H:%M:%S'),
				'body' => body,
				'user' => user.to_hash,
				'likes' => likes.map{|l| l.to_hash},
				'ref_ids' => ref_ids,
				'res' => res ? res.to_hash : nil,
				'photos' => photos,
				'stamp' => stamp
			}
		end
	end
end
