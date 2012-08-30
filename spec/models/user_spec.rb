# -*- coding: utf-8 -*-
require 'spec_helper'
require 'massr/models/user'

describe 'Massr::User' do
	before do
		Massr::User.collection.remove
	end

	context '新規ユーザ登録' do
		request = {
			:id => 'wasamas',
			:twitter_id => '1234567',
			:name => 'わさます',
			:email => 'wasamas@example.com',
		}
		user = Massr::User.create_by_registration_form( request )

		it { user[:massr_id].should eq('wasamas') }
		it { user[:twitter_id].should eq('1234567') }
		it { user[:name].should eq('わさます') }
		it { user[:email].should eq('wasamas@example.com') }
	end

	after do
	end
end
