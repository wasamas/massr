function del_like(id) {
	$.ajax({
		url: '/statement/'+id+'/like',
		type: 'DELETE',
		success: function(result) {
			location.href="/";
		}
	});
}

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
			url: '/admin/auth/'+id,
			type: 'PUT',
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
			url: '/admin/auth/'+id,
			type: 'DELETE',
			success: function(result) {
				location.href="/admin";
			}
		});
	}
}

function privilege_user(id) {
	{
		$.ajax({
			url: '/admin/privilege/'+id,
			type: 'PUT',
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
			url: '/admin/privilege/'+id,
			type: 'DELETE',
			success: function(result) {
				location.href="/admin";
			}
		});
	}
}

function toggle_response(id) {
	 $("#res"+id).toggle();
}

$(function(){
	$('.statement-body').autolink();
});

