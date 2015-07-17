/*
 * auto-link.js : make url to link automatic
 *
 * Copyright (C) 2015 by The wasam@s production
 *
 * Distributed under GPL
 */

$(function(){
	// load twitter widget
	window.twttr = (function(d, s, id) {
		var js, fjs = d.getElementsByTagName(s)[0],
			t = window.twttr || {};
		if (d.getElementById(id)) return t;
		js = d.createElement(s);
		js.id = id;
		js.src = "https://platform.twitter.com/widgets.js";
		fjs.parentNode.insertBefore(js, fjs);

		t._e = [];
		t.ready = function(f) {
			t._e.push(f);
		};

		return t;
	}(document, "script", "twitter-wjs"));

	$.fn.autoLink = function(config){
		this.each(function(){
			var re = /((https?|ftp):\/\/[\(\)%#!\/0-9a-zA-Z_$@.&+-,'"*=;?:~-]+|^#[^#\s]+|\s#[^#\s]+)/g;
			var embed = "";
			var s_id = $(this).parent().parent().attr('id');
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
							if (u.match(/https?:\/\/twitter\.com\/.+\/status\/(\d+)$/)) {
								// embed tweet
								var tweet_id = RegExp.$1;
								embed += '<div id="tw' + tweet_id + '-' + s_id + '"></div>';
								twttr.ready(function() {
									twttr.events.bind('rendered', function(ev) {
										$(ev.target).css({'width': 'auto'});
										$(ev.target).contents().find('blockquote').css({'font-size':'85%'});
									});
									twttr.widgets.createTweet(tweet_id, $('#tw'+tweet_id+'-'+s_id).get(0),{cards:'hidden'});
								});
							}
							else if (u.match(/https?:\/\/www\.youtube\.com\/watch\?v=([0-9a-zA-Z_]+)/)) {
								embed += '<div><iframe id="ytplayer" type="text/html" src="//www.youtube.com/embed/' +
										RegExp.$1 + '" frameborder="0" /></div>';
							}

							return '[<a href="'+u+'" target="_blank">'+url.attr('host')+'</a>]';
						}
					}catch(e){
						return u;
					}
				}) + embed
			);
		});
		return this;
	};
});

