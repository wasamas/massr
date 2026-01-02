# -*- coding: utf-8; -*-
#
# routes/webauthn.rb : Passkey (WebAuthn) authentication routes
#
# Copyright (C) 2025 by The wasam@s production
# https://github.com/wasamas/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base

		# Passkey登録画面の表示
		get '/passkey/register' do
			user = current_user
			haml :passkey_register, locals: { user: user }
		end

		# Passkey登録用のチャレンジ生成
		post '/passkey/register/options' do
			content_type :json
			user = current_user
			user.ensure_webauthn_id

			begin
				options = WebAuthn::Credential.options_for_create(
					user: {
						id: user.webauthn_id,
						name: user.massr_id,
						display_name: user.name
					},
					authenticator_selection: {
						user_verification: 'preferred',
						resident_key: 'preferred'
					},
					exclude: user.webauthn_credentials.map { |c| c['id'] }
				)

				session[:webauthn_challenge] = options.challenge
				options.as_json.to_json
			rescue => e
				halt 500, { error: e.message }.to_json
			end
		end

		# Passkey登録の検証
		post '/passkey/register' do
			content_type :json
			user = current_user
			challenge = session.delete(:webauthn_challenge)

			halt 400, { error: 'Challenge not found' }.to_json unless challenge

			begin
				request_body = request.body.read
				params_data = JSON.parse(request_body)

				webauthn_credential = WebAuthn::Credential.from_create(params_data)
				webauthn_credential.verify(challenge)

				user.add_webauthn_credential(
					id: Base64.strict_encode64(webauthn_credential.id),
					public_key: Base64.strict_encode64(webauthn_credential.public_key),
					sign_count: webauthn_credential.sign_count,
					nickname: params_data['nickname']
				)

				{ success: true }.to_json
			rescue WebAuthn::Error => e
				halt 400, { error: e.message }.to_json
			rescue => e
				halt 500, { error: e.message }.to_json
			end
		end

		# Passkey認証用のチャレンジ生成
		post '/passkey/login/options' do
			content_type :json

			begin
				options = WebAuthn::Credential.options_for_get(
					user_verification: 'preferred'
				)

				session[:webauthn_challenge] = options.challenge
				options.as_json.to_json
			rescue => e
				halt 500, { error: e.message }.to_json
			end
		end

		# Passkey認証の検証とログイン
		post '/passkey/login' do
			content_type :json
			challenge = session.delete(:webauthn_challenge)

			halt 400, { error: 'Challenge not found' }.to_json unless challenge

			begin
				request_body = request.body.read
				params_data = JSON.parse(request_body)

				webauthn_credential = WebAuthn::Credential.from_get(params_data)
				credential_id = Base64.strict_encode64(webauthn_credential.id)

				user = User.where("webauthn_credentials.id" => credential_id).first
				halt 401, { error: 'User not found' }.to_json unless user

				stored_credential = user.find_webauthn_credential(credential_id)
				halt 401, { error: 'Credential not found' }.to_json unless stored_credential

				public_key = Base64.strict_decode64(stored_credential['public_key'])
				webauthn_credential.verify(
					challenge,
					public_key: public_key,
					sign_count: stored_credential['sign_count']
				)

				user.update_sign_count(credential_id, webauthn_credential.sign_count)

				# セッションに必要なデータを設定
				session[:user_id] = user._id.to_s
				session[:twitter_user_id] = user.twitter_user_id
				session[:twitter_id] = user.twitter_id
				session[:twitter_icon_url_https] = user.twitter_icon_url_https

				{ success: true, redirect: '/' }.to_json
			rescue WebAuthn::Error => e
				halt 401, { error: e.message }.to_json
			rescue => e
				halt 500, { error: e.message }.to_json
			end
		end

		# Passkey管理画面
		get '/passkey/manage' do
			user = current_user
			haml :passkey_manage, locals: { user: user }
		end

		# Passkey削除
		delete '/passkey/:credential_id' do
			content_type :json
			user = current_user

			if user.remove_webauthn_credential(params[:credential_id])
				{ success: true }.to_json
			else
				halt 404, { error: 'Credential not found' }.to_json
			end
		end
	end
end
