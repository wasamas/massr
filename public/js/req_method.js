function doDetele(id) {
	 $.ajax({
		  url: '/entry/'+id+'/like',
		  type: 'DELETE',
		  success: function(result) {
				location.href="/";
		  }
	 });
}