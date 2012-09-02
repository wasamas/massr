# -*- coding: utf-8 -*-
require 'spec_helper'
require 'massr/models/user'

def prototype(no)
	[
		{
			:massr_id => 'wasamas',
			:twitter_id => '1234567',
			:name => 'わさます',
			:email => 'wasamas@example.com',
		},
		{
			:massr_id => 'wasamas2',
			:twitter_id => '7654321',
			:name => 'わさます2',
			:email => 'wasamas2@example.com',
		}
	][no]
end

describe 'Massr::User' do
	before do
		Massr::User.collection.remove
	end

	describe '.create_by_registration_form' do
		before do
			@user = Massr::User.create_by_registration_form( prototype(0) )
		end
		subject{ @user }

		context '新規ユーザ登録が正常にできているか' do
			its(:massr_id) { should eq(prototype(0)[:massr_id]) }
			its(:twitter_id) { should eq(prototype(0)[:twitter_id]) }
			its(:name) { should eq(prototype(0)[:name]) }
			its(:email) { should eq(prototype(0)[:email]) }
		end
	end

	describe '.find_by_twitter_id' do
		before do
			Massr::User.create_by_registration_form( prototype(0) )
			@user0 = Massr::User.find_by_twitter_id(prototype(0)[:twitter_id])
			@user1 = Massr::User.find_by_twitter_id(prototype(1)[:twitter_id])
		end

		context '既存ユーザを検索する' do
			subject{ @user0 }

			it { should_not be_nil }
			its(:twitter_id) { should eq(prototype(0)[:twitter_id]) }
		end

		context '存在しないユーザを検索する' do
			subject{ @user1 }

			it { should be_nil }
		end
	end

	after do
	end
end
