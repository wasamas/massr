# -*- coding: utf-8; -*-
require 'mongo_mapper'
require 'json'
require 'uri'
require 'net/http'
require 'picasa'

module Massr
	class Statement
		include MongoMapper::Document
		safe
		
		key :body,  :type => String, :required => true
		key :photos, Array
		key :ref_ids, Array

		timestamps!

		belongs_to :user  , :class_name => 'Massr::User'
		belongs_to :res   , :class_name => 'Massr::Statement'
		many       :likes , :class_name => 'Massr::Like'  , :dependent => :delete_all
		many       :refs  , :class_name => 'Massr::Statement' , :in => :ref_ids

		def self.get_statements(page,options={})
			options[:order]    = :created_at.desc
			options[:per_page] = $limit
			options[:page]     = page
			return self.paginate(options)
		end

		def get_album(album_name)
			album_list = $picasa_client.album.list(:fields => "entry[title eq \'#{album_name}\']")
			if album_list.entries.size == 0
				album = $picasa_client.album.create(:title => album_name)
			else
				album = album_list.entries[0]
			end

			return album.numphotos < 1000 ? album : get_album(album_name.succ)
		end


		def update_statement(request)
			self[:body]  = request[:body]
			
			#upload to picasa
			if request[:file_path]
				album_name = Time.now.strftime("Massr%Y%m") + "001"
				album = get_album(album_name)
				photo = $picasa_client.photo.create(
					album.id,
					file_path: "#{request[:file_path]}",
					content_type: "#{request[:file_content_type]}"
					)
				self[:photos] << photo.content.src
			end

			# body内の画像
			re = URI.regexp(['http', 'https'])
			self[:body].scan(re) do 
				uri = URI.parse($&)
				response = nil
				begin
					Net::HTTP.start( uri.host, uri.port ) do |http|
						response = http.head( uri.request_uri )
						self[:photos] << uri.to_s if response["content-type"].to_s.include?('image')
					end
				rescue SocketError => e
					#URLの先が存在しないなど。
				end
			end

			if request[:res_id]
				res_statement  = Statement.find_by_id(request[:res_id])
				res_statement.refs << self
				self.res   = res_statement
			end

			user = request[:user]
			self.user  = user

			if save!
				user.statements << self
				user.save!
				res_statement.save! if request[:res_id]
			end

			return self
		end

		def like?(user)
			likes.map{|like| like.user._id == user._id}.include?(true)
		end

		def to_hash
			{
				'id' => id,
				'created_at' => created_at.localtime.strftime('%Y-%m-%d %H:%M:%S'),
				'body' => body,
				'user' => user.to_hash,
				'likes' => likes.map{|l| l.to_hash},
				'ref_ids' => ref_ids,
				'res' => res_id ? Statement.find_by_id(res_id).to_hash : nil,
				'photos' => photos
			}
		end
	end
end
