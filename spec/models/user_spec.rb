# -*- coding: utf-8 -*-
require 'spec_helper'
require 'massr/models/user'


describe 'Massr::User' do
	before do
		Massr::User.collection.remove
	end

	describe '.create_by_registration_form' do
		before do
			@user = Massr::User.create_by_registration_form( prototype_user(0) )
		end
		subject{ @user }

		context '新規ユーザ登録が正常にできているか' do
			its(:massr_id) { should eq(prototype_user(0)[:massr_id]) }
			its(:twitter_id) { should eq(prototype_user(0)[:twitter_id]) }
			its(:twitter_icon_url) { should eq(prototype_user(0)[:twitter_icon_url]) }
			its(:name) { should eq(prototype_user(0)[:name]) }
			its(:email) { should eq(prototype_user(0)[:email]) }
		end
	end

	describe '#update' do
		before do
			Massr::User.create_by_registration_form( prototype_user(0) )
		end

		context 'すべての属性を指定して更新する' do
			before :all do
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

	after do
	end
end
