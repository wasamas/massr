# -*- coding: utf-8 -*-
require 'spec_helper'
require 'massr/models/entry'
require 'massr/models/user'
require 'massr/models/like'

def prototype_entry(no)
	[
		{
			# 元エントリ用
			:body => 'ほんぶんだよ！',
			:photo => 'http://example.com/foo.jpg',
		},
		{
			# レスエントリ用
			:body => 'ほんぶんだよ２！',
			:photo => 'http://example.com/baa.jpg',
		}
	][no]
end

describe 'Massr::Entry' do
	before do
		Massr::Entry.collection.remove
		@user1 = Massr::User.new
		@user2 = Massr::User.new
	end

	describe '#update_entry' do
		before do
			@entry1_1 = Massr::Entry.new.update_entry( prototype_entry(0) , {:user => @user1} )
		end
		subject {@entry1_1}
		
		context 'Entryが正常に登録できているか' do
			its(:body)  {should eq(prototype_entry(0)[:body]) }
			its(:photo) {should eq(prototype_entry(0)[:photo]) }
			its(:user)  {should eq(@user1) }
			its(:res)   {should raise_error(NoMethodError) }
		end
	end
		
	describe '#response_entry' do
		before do
			@entry2_1 = Massr::Entry.new.update_entry( prototype_entry(0) , {:user => @user1} )
			req = {
				:body => prototype_entry(1)[:body],
				:photo => prototype_entry(1)[:photo],
				:res_id => @entry2_1._id
			}
			@entry2_2 = Massr::Entry.new.update_entry( req , {:user => @user2} )
		end

		subject {@entry2_2}
		context 'レスポンスEntryが正常に登録できているか' do
			its(:body)  {should eq(prototype_entry(1)[:body]) }
			its(:photo) {should eq(prototype_entry(1)[:photo]) }
			its(:user)  {should eq(@user2) }
			its(:res)   {should eq(@entry2_1) }
		end

	end

	after do
	end
end
