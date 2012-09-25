var ADMIN        = 0;
var AUTHORIZED   = 1;
var UNAUTHORIZED = 9;

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

function authorize_user(id) {
	{
		$.ajax({
			url: '/user/'+id,
			type: 'PUT',
			data: "status="+AUTHORIZED,
			success: function(result) {
				location.href="/admin";
			}
		});
	}
}
function unauthorize_user(id) {
	if(window.confirm('本当に認可を取り消していいですか？'))
	{
		$.ajax({
			url: '/user/'+id,
			type: 'PUT',
			data: "status="+UNAUTHORIZED,
			success: function(result) {
				location.href="/admin";
			}
		});
	}
}

function privilege_user(id) {
	{
		$.ajax({
			url: '/user/'+id,
			type: 'PUT',
			data: "status="+ADMIN,
			success: function(result) {
				location.href="/admin";
			}
		});
	}
}

function unprivilege_user(id) {
	if(window.confirm('本当にAdmin権限を取り消していいですか？'))
	{
		$.ajax({
			url: '/user/'+id,
			type: 'PUT',
			data: "status="+AUTHORIZED,
			success: function(result) {
				location.href="/admin";
			}
		});
	}
}

function toggle_response(id) {
	$("#res"+id).toggle().each(function(){
		if($(this).css('display') == 'block'){
			$('textarea', this).focus();
		}
	});
	return false;
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
	 * automatic link
	 */
	$('.statement-message').each( function(){
		var re = /((http|https|ftp):\/\/[\w?=&.\/-;#~%-]+(?![\w\s?&.\/;#~%"=-]*>))/g;
		$(this).html( $(this).html().replace(re, '<a href="$1" target="_blank">$1</a> ') );
	});
});

