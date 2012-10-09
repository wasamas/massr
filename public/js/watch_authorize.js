/*
 * watch_authorize.js : watching authorization status and redirect to top
 *
 * Copyright (C) 2012 by The wasam@s production
 *
 * Distributed under GPL
 */

$(function(){
	setInterval(function(){
		$.ajax({
			url: '/',
			type: 'GET',
			dataType: 'HTML',
			cache: false,
			success: function(data) {
				var $masao = $('#masao', data);
				if($masao.length > 0) { // not authorized yet
					$('#masao').attr('src', $masao.attr('src'));
				} else { // already authorized
					location.href = '/';
				}
			},
			error: function(XMLHttpRequest, textStatus, errorThrown) {
				location.reload();
			}
		});
	}, 60000);
});
