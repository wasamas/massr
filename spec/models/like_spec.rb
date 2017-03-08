require 'spec_helper'
require 'models/like'
require 'models/user'

describe 'Massr::Like' do
	describe '#to_hash' do
		before :all do
			Massr::User.collection.drop
			@user = Massr::User.create_by_registration_form(prototype_user(0))
			@like = Massr::Like.new(:user => @user)
			puts @like.to_json
		end
		subject{ @like.to_hash }

		it {is_expected.to be_a_kind_of(Hash)}
		it {expect(subject['id']).to be_a_kind_of(String)}
		it {expect(subject['user']).to be_a_kind_of(Hash)}
	end
end
