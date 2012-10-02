function del_user(id) {
	if(window.confirm('本当に削除してよろしいいですか？'))
	{
		$.ajax({
			url: '/user',
			type: 'DELETE',
			success: function(result) {
				location.href="/";
			}
		});
	}
}

$(function(){
	/*
	 * setup pnotify plugin
	 */
	$.pnotify.defaults.history = false;

	/*
	 * setup against CSRF
	 */
	jQuery.ajaxSetup({
		beforeSend: function(xhr) {
			var token = jQuery('meta[name="_csrf"]').attr('content');
			xhr.setRequestHeader('X_CSRF_TOKEN', token);
		}
	});

	/*
	 * setup auto reloading
	 *   reloading each 30sec without focused in TEXTAREA
	 */
	var reload_interval = setInterval(function(){
		if(location.pathname == '/' && location.search == ''){
			$.ajax({
				url: '/index.json',
				type: 'GET',
				dataType: 'json',
				cache: false,
				success: function(json) {
					var newest = $($('#statements .statement .statement-info a').get(1)).text().replace(/^\s*(.*?)\s*$/, "$1");
					$('#statements').each(function(){
						var $div = $(this);
						$.each(json.reverse(), function(){
							if(this.created_at > newest){
								$div.prepend(buildStatement(this));
								refreshLike(this);
							}else if($('#st-'+this.id).length > 0){
								refreshLike(this);
							}
						});
					});
				},
				error: function(XMLHttpRequest, textStatus, errorThrown) {
					message.error('最新情報の取得に失敗しました(' + textStatus + ')');
				}
			});
		}
	}, 30000);

	/*
	 * utilities
	 */
	// get ID from style "aaa-999999999"
	function getID(label){
		return label.split('-', 2)[1];
	};

	var message = new Object();

	message.success = function(text){
		$.pnotify({
			text: text,
			type: 'success'
		});
	};

	message.info = function(text){
		$.pnotify({
			text: text,
			type: 'info'
		});
	};

	message.error = function(text){
		$.pnotify({
			text: text,
			type: 'error'
		});
	};

	function escapeText(text){
		return text.
			replace(/&/g, '&amp;').
			replace(/</g, '&lt;').
			replace(/>/g, '&gt;').
			replace(/"/g, '&quot;');
	};

	function shrinkText(text){
		return text.replace(/[\r\n]+/g, ' ');
	};

	function buildStatement(s){ // s is json object of a statement
		return $('<div>').addClass('statement').attr('id', 'st-'+s.id).append(
			$('<div>').addClass('statement-icon').append(
				$('<a>').attr('href', '/user/'+s.user.massr_id).append(
					$('<img>').addClass('massr-icon').attr('src', s.user.twitter_icon_url)
				)
			)
		).append(
			$('<div>').addClass('statement-body').each(function(){
				if(s.res != null){
					$(this).append(
						$('<div>').addClass('statement-res').
							append($('<a>').attr('href', '/statement/'+s.res.id).
								append('&gt; '+escapeText(shrinkText(s.res.body))))
					)
				}
			}).append(
				$('<div>').addClass('statement-message').
					append(escapeText(shrinkText(s.body)))
			).append(
				$('<div>').addClass('statement-info').
					append('by ').
					append($('<a>').attr('href', '/user/'+s.user.massr_id).append(s.user.name)).
					append(' at ' ).
					append($('<a>').attr('href', '/statement/'+s.id).append(s.created_at))
			).append(
				$('<div>').addClass('statement-action').append(
					$('<a>').addClass('trash').attr('href', '#').
						append($('<i>').addClass('icon-trash').attr('title', '削除'))
				).append(
					$('<a>').addClass('res').attr('href', '#').append(
						$('<i>').addClass('icon-comment').attr('title', 'レス')
					)
				).append(
					$('<a>').attr('href', '#').addClass('like-button').attr('id', 'like-'+s.id).
						each(function(){
							if(s.likes.length > 0){
								$(this).addClass('unlike');
							}else{
								$(this).addClass('like');
							}
						}).
						append($('<img>').addClass('unlike').attr('src', '/img/wakaruwa.png').attr('alt', 'わからないわ').attr('title', 'わからないわ')).
						append($('<img>').addClass('like').attr('src', '/img/wakaranaiwa.png').attr('alt', 'わかるわ').attr('title', 'わかるわ'))
				)
			).append(
				$('<div>').addClass('response').attr('id', 'res-'+s.id).append(
					$('<form>').attr('method', 'POST').attr('action', '/statement').append(
						$('<textarea>').attr('name', 'body').attr('type', 'text')
					).append(
						$('<input>').attr('name', 'res_id').attr('type', 'hidden').attr('value', s.id)
					).append(
						$('<input>').attr('name', '_csrf').attr('type', 'hidden').attr('value', $('meta[name="_csrf"]').attr('content'))
					).append(
						$('<input>').addClass('btn').attr('type', 'submit').attr('value', 'レスるわ')
					)
				)
			)
		);
	};

	/*
	 * action like / unlike
	 */
	function toggleLikeButton(statement_id){
		$('#st-' + statement_id + ' a.like-button').
			toggleClass('like').
			toggleClass('unlike');
	};

	function refreshLike(statement){
		$('#st-' + statement.id + ' .statement-like').remove();

		if(statement.likes.length == 0){
			return;
		}

		$('#st-' + statement.id + ' .statement-action').
			after('<div class="statement-like">').
			next().
			append('わかるわ:');

		$.each(statement.likes, function(){
			$('#st-' + statement.id + ' .statement-like').
				append("&nbsp;").
				append( $('<a>').
					attr('href', '/user/' + this.user.massr_id).
					append( $('<img>').
						addClass('massr-icon-mini').
						attr('src', this.user.twitter_icon_url).
						attr('alt', this.user.name).
						attr('title', this.user.name)
					)
				)
		});
	};

	$(document).on('click', '.statement-action a.like-button', function(){
		var statement_id = getID($(this).attr('id'));
		var method = $(this).hasClass('like') ? 'POST' : 'DELETE';

		toggleLikeButton(statement_id);
		$.ajax('/statement/' + statement_id + '/like', {
			type: method,
			dataType: 'json',
			success: function(statement) {
				refreshLike(statement);
			},
			error: function(XMLHttpRequest, textStatus, errorThrown) {
				toggleLikeButton(statement_id);
				message.error('イイネに失敗しました(' + textStatus + ')');
			}
		});
		return false;
	});

	/*
	 * res form
	 */
	$(document).on('click', '.statement-action a.res', function(){
		var statement = getID($(this).parent().parent().parent().attr('id'));
		$("#res-" + statement).toggle().each(function(){
			if($(this).css('display') == 'block'){
				$('textarea', this).focus();
			}
		});
		return false;
	});

	/*
	 * delete statement
	 */
	$(document).on('click', '.statement-action a.trash', function(){
		var statement = getID($(this).parent().parent().parent().attr('id'));
		var owner = $('#st-' + statement + ' .statement-icon a').attr('href').match(/[^/]+$/);
		if(owner != $('#me').text()){
			message.error('削除は発言者本人にしかできません');
			return false;
		}
		if(window.confirm('本当に削除してよろしいいですか?')){
			$.ajax({
				url: '/statement/'+statement,
				type: 'DELETE',
				success: function(result) {
					location.href = "/";
				}
			});
		}
	});

	/*
	 * admin
	 */
	var ADMIN        = 0;
	var AUTHORIZED   = 1;
	var UNAUTHORIZED = 9;

	function toggleStatus(massr_id, stat, on, off){
		if($('#' + massr_id).hasClass('admin') && on == 'unauthorized'){
			message.info('管理者の認可は取り消せません')
			return false;
		}
		if($('#' + massr_id).hasClass('unauthorized') && on == 'admin'){
			message.info('未認可メンバは管理者指名できません')
			return false;
		}
		$.ajax({
			url: '/user/' + massr_id,
			type: 'PUT',
			data: "status=" + stat,
			success: function(result){
				message.success(massr_id + 'のステータスを変更しました');
				$('#' + massr_id).toggleClass(on).toggleClass(off);
			},
			error: function(XMLHttpRequest, textStatus, errorThrown){
				message.error('ステータス変更に失敗しました(' + textStatus + ')');
			}
		});
		return true;
	};

	$('ul.admin li').
		on('click', 'a.admin', function(){ // Admin権限剥奪
			toggleStatus($(this).parent().attr('id'), AUTHORIZED, 'normal', 'admin');
			return false;}).
		on('click', 'a.normal', function(){ // Admin権限付与
			toggleStatus($(this).parent().attr('id'), ADMIN, 'admin', 'normal');
			return false;}).
		on('click', 'a.authorized', function(){ // 認可取り消し
			toggleStatus($(this).parent().attr('id'), UNAUTHORIZED, 'unauthorized', 'authorized');
			return false;}).
		on('click', 'a.unauthorized', function(){ // 認可
			toggleStatus($(this).parent().attr('id'), AUTHORIZED, 'authorized', 'unauthorized');
			return false;});

	/*
	 * automatic link
	 */
	$('.statement-message').each( function(){
		var re = /((http|https|ftp):\/\/[\w?=&.\/-;#~%+,-]+(?![\w\s?&.\/;#~%"=-]*>))/g;
		$(this).html( $(this).html().replace(re, '<a href="$1" target="_blank">$1</a>') );
	});
});

