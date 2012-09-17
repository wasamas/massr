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

function toggle_response(id) {
	 $("#res"+id).toggle();
}

$(function(){
	$('.statement-body').autolink();
});

