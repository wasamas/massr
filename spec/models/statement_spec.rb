# -*- coding: utf-8 -*-
require 'spec_helper'
require 'models/statement'
require 'models/user'
require 'models/like'

describe 'Massr::Statement' do
	before do
		Massr::Statement.collection.remove
	end

	describe '#update_statement' do
		before do
			@user = Massr::User.create_by_registration_form( prototype_user(0) )
			@statement1_1 = Massr::Statement.new.update_statement( prototype_statement(0,@user) )
		end
		subject {@statement1_1}
		
		context 'Statementが正常に登録できているか' do
			its(:body)  {should eq(prototype_statement(0,@user)[:body]) }
			its(:photo) {should eq(prototype_statement(0,@user)[:photo]) }
			its(:user)  {should eq(@user) }
			its(:res)   {should raise_error(NoMethodError) }
		end
	end
		
	describe '#response_statement' do
		before do
			@user = Massr::User.create_by_registration_form( prototype_user(1) )
			@statement2_1 = Massr::Statement.new.update_statement( prototype_statement(0,@user) )
			req = {
				:body   => prototype_statement(1,@user)[:body],
				:photo  => prototype_statement(1,@user)[:photo],
				:res_id => @statement2_1._id,
				:user   => prototype_statement(1,@user)[:user]
			}
			@statement2_2 = Massr::Statement.new.update_statement( req )
		end

		subject {@statement2_2}
		context 'レスポンスStatementが正常に登録できているか' do
			its(:body)  {should eq(prototype_statement(1,@user)[:body]) }
			its(:photo) {should eq(prototype_statement(1,@user)[:photo]) }
			its(:user)  {should eq(@user) }
			its(:res)   {should eq(@statement2_1) }
		end

	end

	describe '#like?' do
		before :all do
			Massr::User.collection.remove
			@user0 = Massr::User.create_by_registration_form(prototype_user(0))
			@statement = Massr::Statement.new.update_statement(prototype_statement(0, @user0))
			@statement.likes << Massr::Like::new(:user => @user0)

			@user1 = Massr::User.create_by_registration_form(prototype_user(1))
		end
		subject{ @statement }

		context 'イイネした' do
			it {subject.like?(@user0).should be_true}
		end
		context 'イイネしてない' do
			it {subject.like?(@user1).should_not be_true}
		end
	end

	describe '#to_json' do
		before :all do
			Massr::User.collection.remove
			@user = Massr::User.create_by_registration_form(prototype_user(0))
			@statement = Massr::Statement.new.update_statement(prototype_statement(0, @user))
			@like = Massr::Like::new(:user => @user)
			@statement.likes << @like
		end
		subject{ @statement.to_json }

		it {should be_a_kind_of(String)}
		it {should match(/"id":"/)}
		it {should match(/"body":"/)}
		it {should match(/"user":{/)}
		it {should match(/"likes":\[{/)}
		it {should match(/"ref_ids":\[\]/)}
		it {should match(/"res_id":null/)}
	end

	after do
	end
end
