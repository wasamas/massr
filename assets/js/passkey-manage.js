// passkey-manage.js
// Passkey管理画面のクライアント側実装

$(function() {
	const addBtn = $('#add-passkey-btn');
	const nicknameInput = $('#new-credential-nickname');

	// 削除ボタンのイベントハンドラ
	$('.delete-credential').on('click', async function(e) {
		e.preventDefault();

		const credentialId = $(this).data('credential-id');
		const row = $(this).closest('tr');

		if (!confirm('このPasskeyを削除しますか？')) {
			return;
		}

		try {
			const response = await fetch('/passkey/' + encodeURIComponent(credentialId), {
				method: 'DELETE',
				headers: {
					'Content-Type': 'application/json',
					'X-CSRF-TOKEN': $('meta[name="_csrf"]').attr('content')
				}
			});

			const result = await response.json();

			if (response.ok && result.success) {
				row.fadeOut(300, function() { $(this).remove(); });
			} else {
				alert('削除に失敗しました: ' + (result.error || '不明なエラー'));
			}
		} catch (error) {
			console.error('Delete error:', error);
			alert('削除に失敗しました');
		}
	});

	// 追加ボタン
	if (addBtn.length > 0) {
		addBtn.on('click', async function(e) {
			e.preventDefault();

			const nickname = nicknameInput.val().trim() || 'Default';

			try {
				// Step 1: サーバーからチャレンジを取得
				const optionsResponse = await fetch('/passkey/register/options', {
					method: 'POST',
					headers: {
						'Content-Type': 'application/json',
						'X-CSRF-TOKEN': $('meta[name="_csrf"]').attr('content')
					}
				});

				if (!optionsResponse.ok) {
					throw new Error('Failed to get registration options');
				}

				const options = await optionsResponse.json();

				// Step 2: Base64文字列をArrayBufferに変換
				options.challenge = base64urlToBuffer(options.challenge);
				options.user.id = base64urlToBuffer(options.user.id);

				if (options.excludeCredentials) {
					options.excludeCredentials = options.excludeCredentials.map(cred => ({
						...cred,
						id: base64urlToBuffer(cred.id)
					}));
				}

				// Step 3: WebAuthn登録を実行
				const credential = await navigator.credentials.create({
					publicKey: options
				});

				// Step 4: 登録結果をサーバーに送信
				const registerResponse = await fetch('/passkey/register', {
					method: 'POST',
					headers: {
						'Content-Type': 'application/json',
						'X-CSRF-TOKEN': $('meta[name="_csrf"]').attr('content')
					},
					body: JSON.stringify({
						nickname: nickname,
						id: credential.id,
						rawId: bufferToBase64url(credential.rawId),
						type: credential.type,
						response: {
							attestationObject: bufferToBase64url(credential.response.attestationObject),
							clientDataJSON: bufferToBase64url(credential.response.clientDataJSON)
						}
					})
				});

				const result = await registerResponse.json();

				if (registerResponse.ok && result.success) {
					alert('Passkeyの追加が完了しました');
					location.reload();
				} else {
					throw new Error(result.error || '登録に失敗しました');
				}

			} catch (error) {
				console.error('Passkey add error:', error);
				alert('追加に失敗しました: ' + error.message);
			}
		});
	}

	// ユーティリティ関数
	function base64urlToBuffer(base64url) {
		const base64 = base64url.replace(/-/g, '+').replace(/_/g, '/');
		const binary = atob(base64);
		const buffer = new ArrayBuffer(binary.length);
		const bytes = new Uint8Array(buffer);
		for (let i = 0; i < binary.length; i++) {
			bytes[i] = binary.charCodeAt(i);
		}
		return buffer;
	}

	function bufferToBase64url(buffer) {
		const bytes = new Uint8Array(buffer);
		let binary = '';
		for (let i = 0; i < bytes.length; i++) {
			binary += String.fromCharCode(bytes[i]);
		}
		return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
	}
});
