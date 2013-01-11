# -*- coding: utf-8; -*-
#
# helpers/resource.rb : language resource
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base
		helpers do
			#
			# カスタマイズ可能な文字列
			#
			def _like
				'わかるわ'
			end

			def _unlike
				'わからないわ'
			end

			def _delete
				'削除'
			end

			def _clearres
				'新着レスクリア'
			end

			def _res
				'レス'
			end

			def _post
				'投稿にょわー☆'
			end

			def _post_res
				'レスるわ'
			end

			def _search
				'みつけるわ'
			end

			def _menu
				'メニュー'
			end

			def _member
				'メンバ'
			end

			def _unprivilege_user
				'管理者権限を剥奪する'
			end

			def _privilege_user
				'管理者にする'
			end

			def _unauthorize_user
				'認可を取り消す'
			end

			def _authorize_user
				'認可する'
			end

			def _unauth_count(num)
				"未認証ユーザが#{num}人います"
			end

			def _response_count(num)
				"新着レスが#{num}個あります"
			end

			def _delete_button
				'×'
			end

			def _user_info_update
				"アプリケーション更新に伴い、ユーザ情報の再登録をします"
			end
		end
	end
end
