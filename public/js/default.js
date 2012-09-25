function del_statement(id) {
	if(window.confirm('本当に削除してよろしいいですか？'))
	{
		$.ajax({
			url: '/statement/'+id,
			type: 'DELETE',
			success: function(result) {
				location.href="/";
			}
		});
	}
}

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
	 * setup against CSRF
	 */
	jQuery.ajaxSetup({
		beforeSend: function(xhr) {
			var token = jQuery('meta[name="_csrf"]').attr('content');
			xhr.setRequestHeader('X_CSRF_TOKEN', token);
		}
	});

	/*
	 * utilities
	 */
	// get ID from style "aaa-999999999"
	function getID(label){
		return label.split('-', 2)[1];
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

	$('.statement-action').on('click', 'a.like-button', function(){
		var statement_id = getID($(this).attr('id'));
		var method = $(this).hasClass('like') ? 'POST' : 'DELETE';

		toggleLikeButton(statement_id);
		$.ajax('/statement/' + statement_id + '/like', {
			type: method,
			dataType: 'json',
			success: function(statement) {
				refreshLike(statement);
			},
			error: function() {
				toggleLikeButton(statement_id);
			}
		});
		return false;
	});

	/*
	 * res form
	 */
	$('.statement-action').on('click', 'a.res', function(){
		var statement = getID($(this).parent().parent().parent().attr('id'));
		$("#res-" + statement).toggle().each(function(){
			if($(this).css('display') == 'block'){
				$('textarea', this).focus();
			}
		});
		return false;
	});

	/*
	 * admin
	 */
	var ADMIN        = 0;
	var AUTHORIZED   = 1;
	var UNAUTHORIZED = 9;

	function toggleStatus(massr_id, stat, on, off){
		if($('#' + massr_id).hasClass('admin') && on == 'unauthorized'){
			alert('管理者の認可は取り消せません')
			return false;
		}
		if($('#' + massr_id).hasClass('unauthorized') && on == 'admin'){
			alert('未認可メンバは管理者指名できません')
			return false;
		}
		$.ajax({
			url: '/user/' + massr_id,
			type: 'PUT',
			data: "status=" + stat,
			success: function(result){
				$('#' + massr_id).toggleClass(on).toggleClass(off);
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
		var re = /((http|https|ftp):\/\/[\w?=&.\/-;#~%-]+(?![\w\s?&.\/;#~%"=-]*>))/g;
		$(this).html( $(this).html().replace(re, '<a href="$1" target="_blank">$1</a> ') );
	});
});

