# -*- coding: utf-8 -*-
require 'spec_helper'
require 'massr/models/user'

describe 'Massr::User' do
	before do
		Massr::User.collection.remove
	end

	describe '.create_by_registration_form' do
		before do
			request = {
				:id => 'wasamas',
				:twitter_id => '1234567',
				:name => 'わさます',
				:email => 'wasamas@example.com',
			}
			@user = Massr::User.create_by_registration_form( request )
		end
		subject{ @user }

		context '新規ユーザ登録が正常にできているか' do
			its(:massr_id) { should eq('wasamas') }
			its(:twitter_id) { should eq('1234567') }
			its(:name) { should eq('わさます') }
			its(:email) { should eq('wasamas@example.com') }
		end
	end

	after do
	end
end
