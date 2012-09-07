function del_like(id) {
	 $.ajax({
		  url: '/entry/'+id+'/like',
		  type: 'DELETE',
		  success: function(result) {
				location.href="/";
		  }
	 });
}