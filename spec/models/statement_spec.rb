require 'spec_helper'
require 'models/statement'
require 'models/user'
require 'models/like'

describe 'Massr::Statement', :type => :model do
	before do
		Massr::Statement.collection.drop
	end

	describe '#update_statement' do
		before do
			@user = Massr::User.create_by_registration_form( prototype_user(0) )
			@statement1_1 = Massr::Statement.new.update_statement( prototype_statement(0,@user) )
		end
		subject {@statement1_1}
		
		context 'Statementが正常に登録できているか' do
			describe '#body' do
			  subject { super().body }
			  it {is_expected.to eq(prototype_statement(0,@user)[:body]) }
			end

			describe '#photos' do
			  subject { super().photos }
			  it {is_expected.to eq(prototype_statement(0,@user)[:photos])}
			end

			describe '#user' do
			  subject { super().user }
			  it {is_expected.to eq(@user) }
			end

			describe '#res' do
			  subject { super().res }
			  it {is_expected.to eq(nil) }
			end
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
			describe '#body' do
			  subject { super().body }
			  it {is_expected.to eq(prototype_statement(1,@user)[:body]) }
			end

			describe '#photos' do
			  subject { super().photos }
			  it {skip do ; is_expected.to eq(prototype_statement(1,@user)[:photos]);end }
			end

			describe '#user' do
			  subject { super().user }
			  it {is_expected.to eq(@user) }
			end

			describe '#res' do
			  subject { super().res }
			  it {is_expected.to eq(@statement2_1) }
			end
		end

	end

	describe '#like?' do
		before :all do
			Massr::User.collection.drop
			@user0 = Massr::User.create_by_registration_form(prototype_user(0))
			@statement = Massr::Statement.new.update_statement(prototype_statement(0, @user0))
			@statement.likes << Massr::Like::new(:user => @user0)

			@user1 = Massr::User.create_by_registration_form(prototype_user(1))
		end
		subject{ @statement }

		context 'イイネした' do
			it {expect(subject.like?(@user0)).to be_truthy}
		end
		context 'イイネしてない' do
			it {expect(subject.like?(@user1)).not_to be_truthy}
		end
	end

	describe '#to_hash' do
		before :all do
			Massr::User.collection.drop
			@user = Massr::User.create_by_registration_form(prototype_user(0))
			@statement = Massr::Statement.new.update_statement(prototype_statement(0, @user))
			@like = Massr::Like::new(user: @user)
			@statement.likes << @like
		end
		subject{ @statement.to_hash }

		it {is_expected.to be_a_kind_of(Hash)}
		it {expect(subject['created_at']).to match(/^\d{4}-\d\d-\d\d \d\d:\d\d:\d\d$/)}
		it {expect(subject['id']).to be}
		it {expect(subject['body']).to be}
		it {expect(subject['user']).to be}
		it {expect(subject['likes']).to be_a_kind_of(Array)}
		it {expect(subject['re_ids']).to be_nil}
		it {expect(subject['res']).to be_nil}
	end

	after do
	end
end
