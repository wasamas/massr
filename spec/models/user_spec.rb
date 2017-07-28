require 'spec_helper'
require 'models/user'
require 'models/statement'

describe 'Massr::User', :type => :model do
	describe '.create_by_registration_form' do
		context '最初の新規ユーザ登録が正常にできているか' do
			before :all do
				Massr::User.collection.drop
				@user = Massr::User.create_by_registration_form( prototype_user(0) )
			end
			subject{ @user }

			describe '#massr_id' do
			  subject { super().massr_id }
			  it { is_expected.to eq(prototype_user(0)[:massr_id]) }
			end

			describe '#twitter_user_id' do
			  subject { super().twitter_user_id }
			  it { is_expected.to eq(prototype_user(0)[:twitter_user_id]) }
			end

			describe '#twitter_id' do
			  subject { super().twitter_id }
			  it { is_expected.to eq(prototype_user(0)[:twitter_id]) }
			end

			describe '#twitter_icon_url' do
			  subject { super().twitter_icon_url }
			  it { is_expected.to eq(prototype_user(0)[:twitter_icon_url]) }
			end

			describe '#twitter_icon_url_https' do
			  subject { super().twitter_icon_url_https }
			  it { is_expected.to eq(prototype_user(0)[:twitter_icon_url_https]) }
			end

			describe '#name' do
			  subject { super().name }
			  it { is_expected.to eq(prototype_user(0)[:name]) }
			end

			describe '#email' do
			  subject { super().email }
			  it { is_expected.to eq(prototype_user(0)[:email]) }
			end

			describe '#status' do
			  subject { super().status }
			  it { is_expected.to eq(Massr::User::ADMIN) }
			end
		end

		context '2番目の新規ユーザ登録が正常にできているか' do
			before :all do
				Massr::User.collection.drop
				Massr::User.create_by_registration_form( prototype_user(0) )
				@user = Massr::User.create_by_registration_form( prototype_user(1) )
			end
			subject{ @user }

			describe '#massr_id' do
			  subject { super().massr_id }
			  it { is_expected.to eq(prototype_user(1)[:massr_id]) }
			end

			describe '#twitter_user_id' do
			  subject { super().twitter_user_id }
			  it { is_expected.to eq(prototype_user(1)[:twitter_user_id]) }
			end

			describe '#twitter_id' do
			  subject { super().twitter_id }
			  it { is_expected.to eq(prototype_user(1)[:twitter_id]) }
			end

			describe '#twitter_icon_url' do
			  subject { super().twitter_icon_url }
			  it { is_expected.to eq(prototype_user(1)[:twitter_icon_url]) }
			end

			describe '#twitter_icon_url_https' do
			  subject { super().twitter_icon_url_https }
			  it { is_expected.to eq(prototype_user(1)[:twitter_icon_url_https]) }
			end

			describe '#name' do
			  subject { super().name }
			  it { is_expected.to eq(prototype_user(1)[:name]) }
			end

			describe '#email' do
			  subject { super().email }
			  it { is_expected.to eq(prototype_user(1)[:email]) }
			end

			describe '#status' do
			  subject { super().status }
			  it { is_expected.to eq(Massr::User::UNAUTHORIZED) }
			end
		end
	end

	describe '.change_status' do
		context '未承認アカウントを承認する' do
			before :all do
				Massr::User.collection.drop
				Massr::User.create_by_registration_form( prototype_user(0) ) # admin
				@user = Massr::User.create_by_registration_form( prototype_user(1) ) # unauthorized
				massr_id = @user.massr_id.to_s
				Massr::User.change_status(massr_id, Massr::User::AUTHORIZED)
				@user = Massr::User.find_by(massr_id: massr_id)
			end
			subject{ @user }

			describe '#status' do
			  subject { super().status }
			  it { is_expected.to eq(Massr::User::AUTHORIZED) }
			end
		end
	end

	describe '#update' do
		context 'すべての属性を指定して更新する' do
			before :all do
				Massr::User.collection.drop
				Massr::User.create_by_registration_form( prototype_user(0) )
				@user = Massr::User.find_by(twitter_user_id: prototype_user(0)[:twitter_user_id])
				@user.update_profile(prototype_user(1))
			end
			subject{ @user }

			describe '#twitter_user_id' do
			  subject { super().twitter_user_id }
			  it { is_expected.to eq(prototype_user(1)[:twitter_user_id]) }
			end

			describe '#twitter_id' do
			  subject { super().twitter_id }
			  it { is_expected.to eq(prototype_user(1)[:twitter_id]) }
			end

			describe '#twitter_icon_url' do
			  subject { super().twitter_icon_url }
			  it { is_expected.to eq(prototype_user(1)[:twitter_icon_url]) }
			end

			describe '#twitter_icon_url_https' do
			  subject { super().twitter_icon_url_https }
			  it { is_expected.to eq(prototype_user(1)[:twitter_icon_url_https]) }
			end

			describe '#name' do
			  subject { super().name }
			  it { is_expected.to eq(prototype_user(1)[:name]) }
			end

			describe '#email' do
			  subject { super().email }
			  it { is_expected.to eq(prototype_user(1)[:email]) }
			end

			# massr_idを変えてはいけない

			describe '#massr_id' do
			  subject { super().massr_id }
			  it { is_expected.to eq(prototype_user(0)[:massr_id]) }
			end
		end
	end

	describe 'admin?' do
		context 'ユーザが管理者の場合' do
			before :all do
				Massr::User.collection.drop
				@user = Massr::User.create_by_registration_form( prototype_user(0) )
			end
			subject{ @user }

			describe '#admin?' do
			  subject { super().admin? }
			  it { is_expected.to be }
			end
		end

		context 'ユーザが管理者でない場合' do
			before :all do
				Massr::User.collection.drop
				Massr::User.create_by_registration_form( prototype_user(1) )
				@user = Massr::User.create_by_registration_form( prototype_user(0) )
			end
			subject{ @user }

			describe '#admin?' do
			  subject { super().admin? }
			  it { is_expected.not_to be }
			end
		end
	end

	describe 'authorized?' do
		context 'ユーザが認可済の場合' do
			before :all do
				Massr::User.collection.drop
				@user = Massr::User.create_by_registration_form( prototype_user(0) )
			end
			subject{ @user }

			describe '#authorized?' do
			  subject { super().authorized? }
			  it { is_expected.to be }
			end
		end

		context 'ユーザが未認可の場合' do
			before :all do
				Massr::User.collection.drop
				Massr::User.create_by_registration_form( prototype_user(1) )
				@user = Massr::User.create_by_registration_form( prototype_user(0) )
			end
			subject{ @user }

			describe '#authorized?' do
			  subject { super().authorized? }
			  it { is_expected.not_to be }
			end
		end
	end

	describe '#to_hash' do
		before :all do
			Massr::User.collection.drop
			@user = Massr::User.create_by_registration_form(prototype_user(0))
		end
		subject{Massr::User.first.to_hash}

		it {is_expected.to be_a_kind_of(Hash)}
		it {expect(subject['id']).to be_a_kind_of(String)}
		it {expect(subject['massr_id']).to eq("wasamas")}
		it {expect(subject['twitter_user_id']).to eq("00000000")}
		it {expect(subject['twitter_id']).to eq("1234567")}
		it {expect(subject['twitter_icon_url']).to be}
		it {expect(subject['name']).to be}
		it {expect(subject['email']).to eq("wasamas@example\.com")}
		it {expect(subject['status']).to be_zero}
	end
end
