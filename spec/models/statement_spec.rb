require 'spec_helper'
require 'models/statement'
require 'models/user'
require 'models/like'

describe 'Massr::Statement', type: :model do
	describe '#update_statement' do
		before do
			Massr::User.collection.drop
			Massr::Statement.collection.drop
			@user = Massr::User.create_by_registration_form(prototype_user(0))
			statement = Massr::Statement.create.update_statement(prototype_statement(0, @user))
		end
		subject {Massr::Statement.first}
		
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
			Massr::User.collection.drop
			Massr::Statement.collection.drop
			@user = Massr::User.create_by_registration_form(prototype_user(1))
			@statement1 = Massr::Statement.create.update_statement(prototype_statement(0, @user))
			req = {
				body:   prototype_statement(1, @user)[:body],
				photo:  prototype_statement(1, @user)[:photo],
				res_id: @statement1._id,
				user:   prototype_statement(1, @user)[:user]
			}
			@statement2 = Massr::Statement.create.update_statement(req)
		end
		subject {@statement2}

		context 'レスポンスStatementが正常に登録できているか' do
			describe '#body' do
			  subject {super().body}
			  it {is_expected.to eq(prototype_statement(1, @user)[:body]) }
			end

			describe '#photos' do
			  subject {super().photos}
			  it {skip do ; is_expected.to eq(prototype_statement(1, @user)[:photos]);end }
			end

			describe '#user' do
			  subject {super().user}
			  it {is_expected.to eq(@user)}
			end

			describe '#res' do
			  subject {super().res}
			  it {is_expected.to eq(@statement1) }
			end
		end

	end

	describe '#like?' do
		before :all do
			Massr::User.collection.drop
			Massr::Statement.collection.drop
			@user0 = Massr::User.create_by_registration_form(prototype_user(0))
			@user1 = Massr::User.create_by_registration_form(prototype_user(1))
			statement = Massr::Statement.create.update_statement(prototype_statement(0, @user0))
			statement.add_like(Massr::Like::new(user: @user1))
		end
		subject{Massr::Statement.first}

		context 'イイネの数' do
			it {expect(subject.likes.size).to eq(1)}
		end

		context 'イイネした人が入っている' do
			it {expect(subject.like?(@user1)).to be_truthy}
		end

		context 'イイネしてない人が入っていない' do
			it {expect(subject.like?(@user0)).not_to be_truthy}
		end
	end

	describe '#to_hash' do
		before :all do
			Massr::User.collection.drop
			Massr::Statement.collection.drop
			@user = Massr::User.create_by_registration_form(prototype_user(0))
			@statement = Massr::Statement.create.update_statement(prototype_statement(0, @user))
			@statement.likes << Massr::Like::new(user: @user)
		end
		subject{ @statement.to_hash }

		it {is_expected.to be_a_kind_of(Hash)}
		it {expect(subject['created_at']).to match(/^\d{4}-\d\d-\d\d \d\d:\d\d:\d\d$/)}
		it {expect(subject['id']).to be_a_kind_of(BSON::ObjectId)}
		it {expect(subject['body']).to eq(prototype_statement(0, @user)[:body])}
		it {expect(subject['user']['name']).to eq(prototype_user(0)[:name])}
		it {expect(subject['likes']).to be_a_kind_of(Array)}
		it {expect(subject['re_ids']).to be_nil}
		it {expect(subject['res']).to be_nil}
	end

	describe '.get_statements' do
		before :all do
			Massr::User.collection.drop
			Massr::Statement.collection.drop
			@user0 = Massr::User.create_by_registration_form(prototype_user(0))
			@statement1 = Massr::Statement.create.update_statement(prototype_statement(0, @user0))

			@user1 = Massr::User.create_by_registration_form(prototype_user(1))
			@statement2 = Massr::Statement.create.update_statement(prototype_statement(1, @user1))

			@date = (Time.now+10).strftime('%Y%m%d%H%M%S')
			@queries = {
				body: prototype_statement(0, @user0)[:body]
			}
		end
		subject{Massr::Statement.get_statements(@date)}

		context 'statementsの個数' do
			it {expect(subject.count).to eq(2)}
		end

		context 'statementsの個数' do
			it {expect(Massr::Statement.get_statements(@date, @queries).count).to eq(1)}
		end
	end

	after do
	end
end
