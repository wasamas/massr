// passkey-register.js
// Passkey登録のクライアント側実装

$(function() {
	const registerBtn = $('#register-passkey-btn');
	const nicknameInput = $('#credential-nickname');
	const statusDiv = $('#passkey-status');

	// ブラウザサポートチェック
	if (!window.PublicKeyCredential) {
		registerBtn.prop('disabled', true);
		statusDiv.html('<div class="alert alert-error">お使いのブラウザはPasskeyに対応していません。</div>');
		return;
	}

	registerBtn.on('click', async function(e) {
		e.preventDefault();

		const nickname = nicknameInput.val().trim() || 'Default';

		try {
			statusDiv.html('<div class="alert alert-info">Passkeyを登録しています...</div>');

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
				statusDiv.html('<div class="alert alert-success">Passkeyの登録が完了しました！<br><a href="/" class="btn btn-primary">ホームへ</a></div>');
				registerBtn.prop('disabled', true);
			} else {
				throw new Error(result.error || '登録に失敗しました');
			}

		} catch (error) {
			console.error('Passkey registration error:', error);
			statusDiv.html('<div class="alert alert-error">登録に失敗しました: ' + error.message + '</div>');
		}
	});

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
