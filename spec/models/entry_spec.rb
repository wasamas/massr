# -*- coding: utf-8 -*-
require 'spec_helper'
require 'massr/models/entry'
require 'massr/models/user'
require 'massr/models/like'

describe 'Massr::Entry' do
	before do
		Massr::Entry.collection.remove
	end

	describe '#update_entry' do
		before do
			@user = Massr::User.create_by_registration_form( prototype_user(0) )
			@entry1_1 = Massr::Entry.new.update_entry( prototype_entry(0,@user) )
		end
		subject {@entry1_1}
		
		context 'Entryが正常に登録できているか' do
			its(:body)  {should eq(prototype_entry(0,@user)[:body]) }
			its(:photo) {should eq(prototype_entry(0,@user)[:photo]) }
			its(:user)  {should eq(@user) }
			its(:res)   {should raise_error(NoMethodError) }
		end
	end
		
	describe '#response_entry' do
		before do
			@user = Massr::User.create_by_registration_form( prototype_user(1) )
			@entry2_1 = Massr::Entry.new.update_entry( prototype_entry(0,@user) )
			req = {
				:body   => prototype_entry(1,@user)[:body],
				:photo  => prototype_entry(1,@user)[:photo],
				:res_id => @entry2_1._id,
				:user   => prototype_entry(1,@user)[:user]
			}
			@entry2_2 = Massr::Entry.new.update_entry( req )
		end

		subject {@entry2_2}
		context 'レスポンスEntryが正常に登録できているか' do
			its(:body)  {should eq(prototype_entry(1,@user)[:body]) }
			its(:photo) {should eq(prototype_entry(1,@user)[:photo]) }
			its(:user)  {should eq(@user) }
			its(:res)   {should eq(@entry2_1) }
		end

	end

	after do
	end
end
