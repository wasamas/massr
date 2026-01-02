// passkey-login.js
// Passkey認証（ログイン）のクライアント側実装

$(function() {
	const passkeyLoginBtn = $('#passkey-login-btn');

	// ブラウザがWebAuthnをサポートしているかチェック
	if (!window.PublicKeyCredential) {
		passkeyLoginBtn.prop('disabled', true);
		passkeyLoginBtn.text('お使いのブラウザはPasskeyに対応していません');
		return;
	}

	passkeyLoginBtn.on('click', async function(e) {
		e.preventDefault();

		try {
			// Step 1: サーバーからチャレンジを取得
			const optionsResponse = await fetch('/passkey/login/options', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
					'X-CSRF-TOKEN': $('meta[name="_csrf"]').attr('content')
				}
			});

			if (!optionsResponse.ok) {
				throw new Error('Failed to get challenge');
			}

			const options = await optionsResponse.json();

			// Step 2: Base64文字列をArrayBufferに変換
			options.challenge = base64urlToBuffer(options.challenge);
			if (options.allowCredentials) {
				options.allowCredentials = options.allowCredentials.map(cred => ({
					...cred,
					id: base64urlToBuffer(cred.id)
				}));
			}

			// Step 3: WebAuthn認証を実行
			const credential = await navigator.credentials.get({
				publicKey: options
			});

			// Step 4: 認証結果をサーバーに送信
			const loginResponse = await fetch('/passkey/login', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
					'X-CSRF-TOKEN': $('meta[name="_csrf"]').attr('content')
				},
				body: JSON.stringify({
					id: credential.id,
					rawId: bufferToBase64url(credential.rawId),
					type: credential.type,
					response: {
						authenticatorData: bufferToBase64url(credential.response.authenticatorData),
						clientDataJSON: bufferToBase64url(credential.response.clientDataJSON),
						signature: bufferToBase64url(credential.response.signature),
						userHandle: credential.response.userHandle ? bufferToBase64url(credential.response.userHandle) : null
					}
				})
			});

			const result = await loginResponse.json();

			if (loginResponse.ok && result.success) {
				window.location.href = result.redirect || '/';
			} else {
				alert('認証に失敗しました: ' + (result.error || '不明なエラー'));
			}

		} catch (error) {
			console.error('Passkey login error:', error);
			alert('Passkey認証に失敗しました。Twitter認証をお試しください。');
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
