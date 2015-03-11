# -*- coding: utf-8; -*-
require 'mongo_mapper'
require 'json'
require 'uri'

module Massr
	class Stamp
		include MongoMapper::Document

		key :image_url,  :type => String, :required => true , :unique => true

		timestamps!

		belongs_to :original , :class_name => 'Massr::Statement' , :required => true

		validates_uniqueness_of :image_url

		def self.get_stamps(options={})
			options[:order]         = :created_at.desc
			return self.all(options)
		end

		def self.get_image_urls(options={})
			options[:order]         = :created_at.desc
			[].tap{ |a|
				json = self.all.to_json(:only => [:image_url])
				JSON.parse(json).each do |data|
					data.each do |k,v|
						a << v
					end
				end
			}
		end

		def self.get_statements(options={})
			options[:order]         = :created_at.desc
			stamps = self.all(options)

			statements = Array.new
			stamps.each do |stamp|
				original = stamp.original
				statements << original
			end
			return statements
		end

		def self.delete_stamp(url,options={})
			stamp = self.find_by_image_url(url)
			stamp.delete
		end

		def update_stamp(request)
			self[:image_url] = request[:image_url]
			statement = Statement.find_by_id(request[:statement_id])
			self.original = statement
			if save
				return self
			end
		end

		def to_hash
			original = Statement.find_by_id(original_id)
			{
				'id' => id,
				'created_at' => created_at.localtime.strftime('%Y-%m-%d %H:%M:%S'),
				'image_url' => image_url,
				'original' => original ? original.to_hash : nil
			}
		end
	end
end
