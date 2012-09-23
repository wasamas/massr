# -*- coding: utf-8 -*-
require 'spec_helper'
require 'models/user'
require 'models/statement'

describe 'Massr::User' do
	describe '.create_by_registration_form' do
		context '最初の新規ユーザ登録が正常にできているか' do
			before :all do
				Massr::User.collection.remove
				@user = Massr::User.create_by_registration_form( prototype_user(0) )
			end
			subject{ @user }

			its(:massr_id) { should eq(prototype_user(0)[:massr_id]) }
			its(:twitter_id) { should eq(prototype_user(0)[:twitter_id]) }
			its(:twitter_icon_url) { should eq(prototype_user(0)[:twitter_icon_url]) }
			its(:name) { should eq(prototype_user(0)[:name]) }
			its(:email) { should eq(prototype_user(0)[:email]) }
			its(:status) { should eq(Massr::User::ADMIN) }
		end

		context '2番目の新規ユーザ登録が正常にできているか' do
			before :all do
				Massr::User.collection.remove
				Massr::User.create_by_registration_form( prototype_user(0) )
				@user = Massr::User.create_by_registration_form( prototype_user(1) )
			end
			subject{ @user }

			its(:massr_id) { should eq(prototype_user(1)[:massr_id]) }
			its(:twitter_id) { should eq(prototype_user(1)[:twitter_id]) }
			its(:twitter_icon_url) { should eq(prototype_user(1)[:twitter_icon_url]) }
			its(:name) { should eq(prototype_user(1)[:name]) }
			its(:email) { should eq(prototype_user(1)[:email]) }
			its(:status) { should eq(Massr::User::UNAUTHORIZED) }
		end
	end

	describe '.change_status' do
		context '未承認アカウントを承認する' do
			before :all do
				Massr::User.collection.remove
				Massr::User.create_by_registration_form( prototype_user(0) ) # admin
				@user = Massr::User.create_by_registration_form( prototype_user(1) ) # unauthorized
				massr_id = @user.massr_id.to_s
				Massr::User.change_status(massr_id, Massr::User::AUTHORIZED)
				@user = Massr::User.find_by_massr_id(massr_id)
			end
			subject{ @user }

			its(:status) { should eq(Massr::User::AUTHORIZED) }
		end
	end

	describe '#update' do
		context 'すべての属性を指定して更新する' do
			before :all do
				Massr::User.collection.remove
				Massr::User.create_by_registration_form( prototype_user(0) )
				@user = Massr::User.find_by_twitter_id(prototype_user(0)[:twitter_id])
				@user.update_profile(prototype_user(1))
			end
			subject{ @user }

			its(:twitter_id) { should eq(prototype_user(1)[:twitter_id]) }
			its(:twitter_icon_url) { should eq(prototype_user(1)[:twitter_icon_url]) }
			its(:name) { should eq(prototype_user(1)[:name]) }
			its(:email) { should eq(prototype_user(1)[:email]) }

			# massr_idを変えてはいけない
			its(:massr_id) { should eq(prototype_user(0)[:massr_id]) }
		end
	end

	describe 'admin?' do
		context 'ユーザが管理者の場合' do
			before :all do
				Massr::User.collection.remove
				@user = Massr::User.create_by_registration_form( prototype_user(0) )
			end
			subject{ @user }
			its(:admin?){ should be }
		end

		context 'ユーザが管理者でない場合' do
			before :all do
				Massr::User.collection.remove
				Massr::User.create_by_registration_form( prototype_user(1) )
				@user = Massr::User.create_by_registration_form( prototype_user(0) )
			end
			subject{ @user }
			its(:admin?){ should_not be }
		end
	end

	describe 'authorized?' do
		context 'ユーザが認可済の場合' do
			before :all do
				Massr::User.collection.remove
				@user = Massr::User.create_by_registration_form( prototype_user(0) )
			end
			subject{ @user }
			its(:authorized?){ should be }
		end

		context 'ユーザが未認可の場合' do
			before :all do
				Massr::User.collection.remove
				Massr::User.create_by_registration_form( prototype_user(1) )
				@user = Massr::User.create_by_registration_form( prototype_user(0) )
			end
			subject{ @user }
			its(:authorized?){ should_not be }
		end
	end

	describe '#to_json' do
		before :all do
			@user = Massr::User.create_by_registration_form(prototype_user(0))
		end
		subject{ @user.to_json }

		it {should be_a_kind_of(String)}
		it {should match(/"id":"/)}
		it {should match(/"massr_id":"wasamas"/)}
		it {should match(/"twitter_id":"1234567"/)}
		it {should match(/"twitter_icon_url":"/)}
		it {should match(/"name":"/)}
		it {should match(/"email":"wasamas@example\.com"/)}
		it {should match(/"status":0/)}
	end
end
