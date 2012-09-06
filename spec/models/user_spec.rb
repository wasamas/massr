# -*- coding: utf-8 -*-
require 'spec_helper'
require 'massr/models/user'

def prototype(no)
	[
		{
			:massr_id => 'wasamas',
			:twitter_id => '1234567',
			:twitter_icon_url => 'http://example.com/foo1.png',
			:name => 'わさます',
			:email => 'wasamas@example.com',
		},
		{
			:massr_id => 'wasamas2',
			:twitter_id => '7654321',
			:twitter_icon_url => 'http://example.com/foo2.png',
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
			its(:twitter_icon_url) { should eq(prototype(0)[:twitter_icon_url]) }
			its(:name) { should eq(prototype(0)[:name]) }
			its(:email) { should eq(prototype(0)[:email]) }
		end
	end

	describe '#update' do
		before do
			Massr::User.create_by_registration_form( prototype(0) )
		end

		context 'すべての属性を指定して更新する' do
			before :all do
				@user = Massr::User.find_by_twitter_id(prototype(0)[:twitter_id])
				@user.update_profile(prototype(1))
			end
			subject{ @user }

			its(:twitter_id) { should eq(prototype(1)[:twitter_id]) }
			its(:twitter_icon_url) { should eq(prototype(1)[:twitter_icon_url]) }
			its(:name) { should eq(prototype(1)[:name]) }
			its(:email) { should eq(prototype(1)[:email]) }

			# massr_idを変えてはいけない
			its(:massr_id) { should eq(prototype(0)[:massr_id]) }
		end
	end

	after do
	end
end
