# -*- coding: utf-8; -*-
require 'mongo_mapper'

module Massr
	class User
		include MongoMapper::Document
		safe

		# user status code
		ADMIN        = 0
		AUTHORIZED   = 1
		UNAUTHORIZED = 9

		key :massr_id,         :type => String , :required => true ,:unique => true
		key :twitter_id,       :type => String , :required => true ,:unique => true
		key :twitter_icon_url, :type => String , :required => true
		key :name,             :type => String , :required => true
		key :email,            :type => String , :required => true
		key :status,           :type => Integer, :default  => UNAUTHORIZED
		key :statement_ids,    Array

		timestamps!

		many :statements , :class_name => 'Massr::Statement', :in => :statement_ids, :dependent => :delete_all

		def self.create_by_registration_form(request)
			user = User.new(:massr_id => request[:massr_id])
			user.update_profile(request)
			return user
		end

		def self.change_status(id, status)
			user = User.find_by_massr_id(id)
			user[:status] = status.to_i
			user.save!
		end

		def update_profile(request)
			self[:twitter_id] = request[:twitter_id]
			self[:twitter_icon_url] = request[:twitter_icon_url]
			self[:name] = request[:name]
			self[:email] = request[:email]

			# 最初期のユーザは管理者として登録
			if User.all().count() == 0
				self[:status] = ADMIN
			end

			save!
			return self
		end

		def admin?
			status == ADMIN
		end

		def authorized?
			status != UNAUTHORIZED
		end
	end
end
