/*
 * auto-link.js : make url to link automatic
 *
 * Copyright (C) 2015 by The wasam@s production
 *
 * Distributed under GPL
 */

$(function(){
	$.fn.autoLink = function(config){
		this.each(function(){
			var re = /((https?|ftp):\/\/[\(\)%#!\/0-9a-zA-Z_$@.&+-,'"*=;?:~-]+|^#[^#\s]+|\s#[^#\s]+)/g;
			$(this).html(
				$(this).html().replace(re, function(u){
					try {
						if (u.match(/^\s*#/)) {
							var array = u.split('#');
							var prefix = array[0];
							var tag = '#' + array[1];
							return prefix + '<a href="/search?q='+encodeURIComponent(tag)+'">'+tag+'</a>';
						} else {
							var url = $.url(u);
							return '[<a href="'+u+'" target="_blank">'+url.attr('host')+'</a>]';
						}
					}catch(e){
						return u;
					}
				})
			);
		});
		return this;
	};
});

