# -*- coding: utf-8 -*-
require 'spec_helper'
require 'models/like'
require 'models/user'

describe 'Massr::Like' do
	describe '#to_json' do
		before :all do
			Massr::User.collection.remove
			@user = Massr::User.create_by_registration_form(prototype_user(0))
			@like = Massr::Like.new(:user => @user)
			puts @like.to_json
		end
		subject{ @like.to_json }

		it {should be_a_kind_of(String)}
		it {should match(/"id":"/)}
		it {should match(/"user":{/)}
	end
end
