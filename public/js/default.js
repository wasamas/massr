/*
 * default.js : common javascript file of massr
 *
 * Copyright (C) 2012 by The wasam@s production
 *
 * Distributed under GPL
 */

/*
 * name space and defaults
 */
$Massr = {};
$Massr.intervalFunctions = [];

/*
 * massr main
 */
$(function(){
	// Use local alias
	var $ = jQuery;

	var me = $('#me').text();
	var settings = {}, _ = {};
	var fileEnabled = false; try {if (FileReader) {fileEnabled = true;}} catch (e) {}
	var posting = false;

	$.when(
		$.getJSON('/default.json'), // default setting
		(function(){ // custom setting
			if($Massr.settings){
				return $.getJSON($Massr.settings);
			}else{
				return [{plugin:{}, resource:{}, setting:{}, local:{}}];
			}
		})()
	).done(function(default_settings, custom_settings){
		$.each(default_settings[0], function(k, v){
			settings[k] = $.extend({}, default_settings[0][k], custom_settings[0][k]);
		});
		_ = settings['local'];

		$.each(settings['plugin'], function(name, opts){
			plugin_setup(name, opts);
		});
	}).fail(function(){
		message.error('loading settings');
	});

	/*
	 * setup pnotify plugin
	 */
	$.pnotify.defaults.history = false;

	/*
	 * setup against CSRF
	 */
	$.ajaxSetup({
		beforeSend: function(xhr) {
			var token = $('meta[name="_csrf"]').attr('content');
			xhr.setRequestHeader('X_CSRF_TOKEN', token);
		}
	});

	/*
	 * setup auto reloading
	 *   reloading each 30sec without focused in TEXTAREA
	 */
	var retry_count_of_reload = 0;
	var reload_interval_time = 30000;
	var reload_interval = setInterval(function(){ if (!posting) reloadDiff();}, reload_interval_time);

	/*
	 * utilities
	 */
	// get ID from style "aaa-999999999"
	function getID(label){
		return label.split('-', 2)[1];
	}

	var message = {};

	// popup notification message
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

	function isHttps(){
		return location.href.match(/^https/);
	}

	function get_icon_url(user){
		if (isHttps()) {
			return user.twitter_icon_url_https;
		} else {
			return user.twitter_icon_url;
		}
	}

	// TODO postRes()とまとめたい
	function post(form){
		var $form = $(form);

		if($('button', $form).attr('disabled') == 'disabled'){
			return false;
		}

		var $body = $form.find("[name=body]");
		if($body.val().trim()){
			var method = $form.attr('method');
			var formdata = new FormData(form);
			$form.find("button").attr("disabled", "disabled").empty().append('<img src="/img/masao_loading.gif">');
			$form.find("textarea").attr("disabled", "disabled");
			formdata.append("response", "json");

			posting = true;
			$.ajax('/statement', {
				type: method,
				processData: false,
				contentType: false,
				data: formdata,
				dataType: 'text'
			}).done(function(statement){
				var clear = function () {
					var photoShadow = $form.find(".photo-shadow");
					photoShadow.replaceWith(photoShadow.val("").clone(true));
					$form.find(".photo-name").text("");
					$form.find(".photo-preview").css("display", "none");
					$form.find("button").removeAttr("disabled").empty().append(_['post']);
					$body.val("");
					$form.find("textarea").removeAttr("disabled");
				};

				var promise = reloadDiff();
				if (promise) {
					promise.always(function () {
						clear();
					});
				} else {
					clear();
				}
				posting = false;
			}).fail(function(XMLHttpRequest, textStatus, errorThrown){
				$form.find("button").removeAttr("disabled").empty().append(_['post']);
				$form.find("textarea").removeAttr("disabled");
				// TODO エラーメッセージ
				message.error('(' + textStatus + ')');
				posting = false;
			});
		}
		return false;
	}

	function postRes(form){
		var $form = $(form);

		if($('button', $form).attr('disabled') == 'disabled'){
			return false;
		}

		var $body = $form.find("[name=body]");
		if($body.val().trim()){
			var method = $form.attr('method');
			var formdata = new FormData(form);
			$form.find("button").attr("disabled", "disabled").empty().append('<img src="/img/masao_loading.gif">');
			$form.find("textarea").slideUp();
			formdata.append("response", "json");

			posting = true;
			$.ajax('/statement', {
				type: method,
				processData: false,
				contentType: false,
				data: formdata,
				dataType: 'text'
			}).done(function(statement){
				var clear = function() {
					var photoShadow = $form.find(".photo-shadow");
					photoShadow.replaceWith(photoShadow.val("").clone(true));
					$form.find(".photo-name").text("");
					$form.find(".photo-preview").css("display", "none");
					$form.find("button").removeAttr("disabled").empty().append(_['post_res']);
					$body.val("");
					$form.parent().parent().find(".res").trigger("click");
				};

				var promise = reloadDiff();
				if (promise) {
					promise.always(function(){
						clear();
						// TODO レス数表示の更新
						// TODO 投稿結果を見せたい
					});
				} else {
					clear();
				}
				posting = false;
			}).fail(function(XMLHttpRequest, textStatus, errorThrown){
				$form.find("button").removeAttr("disabled").empty().append(_['post_res']);
				$form.find("textarea").slideDown();
				// TODO エラーメッセージ
				message.error('(' + textStatus + ')');
				posting = false;
			});
		}
		return false;
	}

	// notification popup on the desktop
	function desktopNotification(statement, timeout){
		if(localStorage['popupNotification'] !== 'true'){
			return false;
		}
		if(statement.user.massr_id == me){
			return false;
		}

		var n = new Notification(_['site_name'], {icon: get_icon_url(statement.user), body: statement.body});
		if(timeout > 0){
			setTimeout(function(){n.close();}, timeout);
		}
	}

	// replace CR/LF to single space
	function shrinkText(text){
		return text.replace(/[\r\n]+/g, '\r');
	}

	// template of a statement
	function buildStatement(s){ // s is json object of a statement
		return $('<div>').addClass('statement').attr('id', 'st-'+s.id).append(
			$('<div>').addClass('statement-icon').append(
				$('<a>').attr('href', '/user/'+s.user.massr_id).append(
					$('<img>').addClass('massr-icon').attr('src', get_icon_url(s.user))
				)
			)
		).append(
			$('<div>').addClass('statement-body').each(function(){
				if(s.user.massr_id == me){
					$(this).addClass('statement-body-me');
				}
				if(s.res !== null){
					$(this).append(
						$('<div>').addClass('statement-res-icon').append(
							$('<a>').attr('href', '/user/'+s.res.user.massr_id).append(
								$('<img>').addClass('massr-icon-mini').
									attr('src', get_icon_url(s.res.user)).
									attr('alt', s.res.user.name).
									attr('title', s.res.user.name)
							)
						)
					).append(
						$('<div>').addClass('statement-res').append(
							$('<a>').attr('href', '/statement/'+s.res.id).
								text('< '+shrinkText(s.res.body)))
					);
				}
			}).append(
				$('<div>').addClass('statement-message').text(shrinkText(s.body)).autoLink()
			).append(
				$('<div>').addClass('statement-photos').each(function(){
					var $parent = $(this);
					$.each(s.photos, function(){
						$parent.append($('<a>').attr('href', this).
							attr('rel', 'lightbox').
							append($('<img>').addClass('statement-photo').attr('src', this)));
					});
				})
			).append(
				$('<div>').addClass('statement-info').
					append('by ').
					append($('<a>').attr('href', '/user/'+s.user.massr_id).append(s.user.name)).
					append(' at ' ).
					append($('<a>').attr('href', '/statement/'+s.id).append(s.created_at))
			).append(
				$('<div>').addClass('statement-action').each(function(){
					if(s.user.massr_id == me){
						$(this).append(
							$('<a>').addClass('trash').attr('href', '#').
								append($('<i>').addClass('icon-trash').attr('title', _['delete']))
						);
					}
				}).append(
					$('<a>').addClass('res').attr('href', '#').append(
						$('<i>').addClass('icon-comment').attr('title', _['res'])
					).append(
						s.ref_ids.length > 0?' ('+s.ref_ids.length+') ':' '
						)
					).append(
						$('<a>').attr('href', '#').addClass('like-button').attr('id', 'like-'+s.id).
						each(function(){
							var classLike = 'like';
							$.each(s.likes, function(){
								if(this.user.massr_id == me){
									classLike = 'unlike';
									return false;
								}
								return true;
							});
							$(this).addClass(classLike);
						}).
						append($('<img>').addClass('unlike').attr('src', '/img/wakaruwa.png').attr('alt', _['unlike']).attr('title', _['unlike'])).
						append($('<img>').addClass('like').attr('src', '/img/wakaranaiwa.png').attr('alt', _['like']).attr('title', _['like']))
				)
			).append(
				$('<div>').addClass('response').attr('id', 'res-'+s.id).append(
					$('<form>').addClass("res-form").attr('method', 'POST').attr('action', '/statement').append(
						$('<div>').append(
							$('<textarea>').
								attr('name', 'body').
								attr('type', 'text')
						).append(
							$('<input>').
								attr('name', 'res_id').
								attr('type', 'hidden').
								attr('value', s.id)
						).append(
							$('<input>').
								attr('name', '_csrf').
								attr('type', 'hidden').
								attr('value', $('meta[name="_csrf"]').attr('content'))
						)
					).append(
						$('<div>').addClass('button').append(
							$('<button>').
								addClass('btn btn-small submit').
								attr('type', 'submit').
								text(_['post_res'])
						).append(
							$('<div>').addClass('photo-items').append(
								$('<input>').
									addClass('photo-shadow').
									attr('type', 'file').
									attr('accept', 'image/*').
									attr('name', 'photo').
									attr('tabindex', '-1')
							).append(
								$('<a>').attr('href', '#').addClass('photo-button').append(
									$('<i>').attr('title', _['attach_photo']).addClass('icon-camera').addClass('photo-button')
								)
							).append(
								$('<span>').addClass('photo-name')
							)
						)
					)
				)
			)
		);
	}

	// template of a photo
	function buildPhoto(s){ // s is json object of a photo
		return $('<div>').addClass('item').attr('id', 'st-'+s.id).append(
			$('<div>').addClass('item-body').each(function(){}).append(
				$('<div>').addClass('item-photos').each(function(){
					var $parent = $(this);
					$.each(s.photos, function(){
						$parent.append($('<a>').attr('href', this).
							attr('rel', 'lightbox').
							append($('<img>').addClass('item-photo').attr('src', this)));
					});
				})
			).append(
				$('<div>').addClass('item-info').
					append(' at ' ).
					append($('<a>').attr('href', '/statement/'+s.id).append(s.created_at))
			)
		);
	}

	function getNewestTime(){
		return $($('#statements .statement .statement-info a').get(1)).text().replace(/^\s*(.*?)\s*$/, "$1");
	}

	// reload diff of recent statements
	function reloadDiff(){
		if(location.pathname === '/' && location.search === ''){
			var promise = $.ajax({
				url: '/index.json',
				type: 'GET',
				dataType: 'json',
				cache: false
			}).done(function(json){
				retry_count_of_reload = 0;
				var newest = getNewestTime();
				$('#statements').each(function(){
					var $div = $(this);
					$.each(json.reverse(), function(){
						if(this.created_at > newest){
							var statement = this;
							var $statement = buildStatement(statement).hide();
							$div.prepend($statement);
							$statement.slideDown('slow');
							if(statement.res && statement.res.user.massr_id == me){
								desktopNotification(statement, 10000);
							}
						}
						refreshLike(this);
					});
				});
				if (newest != getNewestTime()){
					newResCheck();
				}
			}).fail(function(XMLHttpRequest, textStatus, errorThrown){
				if($('textarea:focus').length === 0){
					if(retry_count_of_reload > 30){ // over 15min
						location.reload();
					}else if(retry_count_of_reload > 10){ // over 5min
						message.error('access error, ' + retry_count_of_reload + 'th retrying...');
					}
					++retry_count_of_reload;
				}
			});

			$.each($Massr.intervalFunctions, function(){
				this();
			});

			var now = new Date();
			localStorage['lastmodified']=now.getTime();
			return promise;
		}
	}

	function updateResCount(count){
		$('.new-res-count').text(count === 0 ? '' : count);
		if(count === 0){
			$('#new-res-size-main').hide();
		}else{
			$('#new-res-size-main').show();
		}
	}

	function newResCheck(){
		$.ajax({
			url: '/ressize.json',
			type: 'GET',
			dataType: 'json',
			cache: false}
		).done(function(json) {
			updateResCount(json.size);
		}).fail(function(XMLHttpRequest, textStatus, errorThrown) {
			if($('textarea:focus').length === 0){
				location.reload();
			}
		});
	}

	// automatic link plugin
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

	$(window).on('focus', function(e){
		if (localStorage['lastmodified']==null) {
			reloadDiff();
		} else {
			var now = new Date();
			var old = localStorage['lastmodified']
			if(now - old > reload_interval_time) {
				reloadDiff();
			}
		}
	});
	/*
	 * post by Ctrl+Enter key
	 */
	$(document).on('keydown', 'textarea', function(e){
		if(e.keyCode == 13 && e.ctrlKey){
			e.preventDefault();
			$(this).parent().parent().submit();
		}
	});

	/*
	 * empty post changes to reload
	 */
	$('#form-new').on('submit', function(e){
		if($('textarea', this).val().trim().length === 0){
			location.reload();
			return false;
		}else{
			// TODO 検索の場合もajaxにしてあとからトップへ
			if ($('#query-string').length == 0) {
				post(e.target);
				return false;
			}
			return true;
		}
	});

	/*
	 * photo upload
	 */
	$(document).on('change', '.photo-shadow', function(){
		var fileName = $(this).val().replace(/\\/g, '/').replace(/.*\//, '');
		$(this).parent().find('.photo-name').first().empty().text(fileName);
		$(this).hide();
		return true;
	});

	$(document).on('click', '.photo-button', function(){
		$(this).parents('form').find('.photo-shadow').show();
		$(this).parents('form').find('.photo-shadow').trigger('click');
		return false;
	});

	var queryString = $('#query-string').attr('title');
	if (queryString) {
		$('#text-new').text(' ' + queryString + ' ');
	}

	/*
	 * action like / unlike
	 */
	function toggleLikeButton(statement_id){
		$('#st-' + statement_id + ' a.like-button').
			toggleClass('like').
			toggleClass('unlike');
	}

	function refreshLike(statement){
		var likeClasses = ['unlike', 'like'];

		$('#st-' + statement.id + ' .statement-like').remove();
		if(statement.likes.length > 0){
			$('#st-' + statement.id + ' .statement-action').
				after('<div class="statement-like">').
				next().
				append(_['like'] + ':');

			$.each(statement.likes, function(){
				$('#st-' + statement.id + ' .statement-like').
					append("&nbsp;").
					append( $('<a>').
						attr('href', '/user/' + this.user.massr_id).
						append( $('<img>').
							addClass('massr-icon-mini').
							attr('src', get_icon_url(this.user)).
							attr('alt', this.user.name).
							attr('title', this.user.name)
						)
					);
				if(this.user.massr_id == me){
					likeClasses = ['like', 'unlike'];
				}
			});
		}
		$('#like-' + statement.id).removeClass(likeClasses[0]).addClass(likeClasses[1]);
	}

	$(document).on('click', '.statement-action a.like-button', function(){
		var statement_id = getID($(this).attr('id'));
		var method = $(this).hasClass('like') ? 'POST' : 'DELETE';

		toggleLikeButton(statement_id);
		$.ajax('/statement/' + statement_id + '/like', {
			type: method,
			dataType: 'json'}).
		done(function(statement) {
				refreshLike(statement);
			}).
		fail(function(XMLHttpRequest, textStatus, errorThrown) {
				toggleLikeButton(statement_id);
				message.error(_['fail_like'] + '(' + textStatus + ')');
			});
		return false;
	});

	/*
	 * res form
	 */
	$(document).on('click', '.statement-action a.res', function(){
		var statement = getID($(this).parent().parent().parent().attr('id'));
		$("#res-" + statement).slideToggle(function(){
			$('textarea', this).show();
			if($(this).is(':visible')){
				$('textarea', this).focus();
			}
		});

		return false;
	});

	/*
	 * response
	 */
	$(document).on('submit', 'form.res-form', function() { return postRes(this); });

	/*
	 * delete statement
	 */
	$(document).on('click', '.statement-action a.trash', function(){
		var statement = getID($(this).parent().parent().parent().attr('id'));
		var owner = $('#st-' + statement + ' .statement-icon a').attr('href').match(/[^/]+$/);
		if(owner != me){
			message.error(_['deny_delete']);
			return false;
		}
		if(window.confirm(_['confirm_delete'])){
			$.ajax({
				url: '/statement/'+statement,
				type: 'DELETE'}).
			done(function(result) {
					location.href = "/";
			});
		}
	});

	/*
	 * show response-count when over zero, and wrap span.new-res-count
	 */
	$('#new-res-notice-text').each(function(){
		var notice = $(this);
		var notice_count = notice.text().match(/\d+/);
		var notice_text = notice.text();
		notice.empty().append(notice_text.replace(notice_count, '<span class="new-res-count">'+notice_count+'</span>'));
		if(notice_count != '0'){
			$('#new-res-size-main').show();
		}
	});

	/*
	 * delete new response-count
	 */
	$(document).on('click', '#new-res-notice-delete-button', function(){
		$.ajax({
			url: '/newres',
			type: 'DELETE'}).
		done(function(result) {
			updateResCount(0);
		});
		return false;
	});

	// Subjoin the next page
	$('#subjoinpage').on('click', function(str){
		var loading = $('#subjoinpage-loading');
		$(this).hide();
		loading.show();
		var oldest = (/.*photos$/.test(location.pathname))?
			$($('#items .item .item-info a').get(-1)).text().replace(/^\s*(.*?)\s*$/, "$1").replace(/[-: ]/g, ''):
			$($('#statements .statement .statement-info a').get(-1)).text().replace(/^\s*(.*?)\s*$/, "$1").replace(/[-: ]/g, '');

		if (oldest === null|| oldest === '') {
			loading.hide();
			$('#subjoinpage').show();
		} else {
			var link=$(this).attr('path') + "?date=" + oldest;
			if ($(this).attr('query')!==""){
				link = link + "&q=" + encodeURIComponent($(this).attr('query'));
			}
			$.ajax({
				url: link,
				type: 'GET',
				dataType: 'json',
				cache: false}).
			done(function(json) {
					var idname = (/.*photos$/.test(location.pathname))? '#items':'#statements';
					$(idname).each(function(){
						var $div = $(this);
						$.each(json, function(){
							var $statement = (/.*photos$/.test(location.pathname))? buildPhoto(this).hide():buildStatement(this).hide();
							if (/.*photos$/.test(location.pathname)){
								$div.append( $statement );
								$div.imagesLoaded(function(){
									$container.masonry( 'appended', $statement );
									$container.masonry( 'reload' );
								});
							}
							else {
								$div.append($statement);
							}
							$statement.slideDown('slow');
							refreshLike(this);
						});
					});
					$('#subjoinpage-loading').hide();
					$('#subjoinpage').show();
				}).
			fail(function(XMLHttpRequest, textStatus, errorThrown) {
					if($('textarea:focus').length === 0){
						location.reload();
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
		var user = $('#' + massr_id);
		if(user.hasClass('admin') && on == 'unauthorized'){
			message.info(_['deny_cancel_admin']);
			return false;
		}
		if(user.hasClass('unauthorized') && on == 'admin'){
			message.info(_['deny_nominate_admin']);
			return false;
		}
		$.ajax({
			url: '/user/' + massr_id,
			type: 'PUT',
			data: "status=" + stat}).
		done(function(result){
				message.success(massr_id + _['success_change_status']);
				$('#' + massr_id).toggleClass(on).toggleClass(off);
			}).
		fail(function(XMLHttpRequest, textStatus, errorThrown){
				message.error('(' + textStatus + ')');
			});
		return true;
	}

	function deleteUser(massr_id){
		if($('#' + massr_id).hasClass('admin')){
			message.info(_['deny_delete_admin']);
			return false;
		}
		if(window.confirm(_['confirm_delete'])){
			$('#' + massr_id + ' .delete').hide().parent().append('<img src="/img/masao_loading.gif">');
			$.ajax({
				url: '/user/' + massr_id,
				type: 'DELETE'}).
			done(function(result) {
				message.success(massr_id + _['success_delete_user']);
				$('#' + massr_id).hide();
			}).
		fail(function(XMLHttpRequest, textStatus, errorThrown){
				message.error('(' + textStatus + ')');
			});
		}
		return true;
	}

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
			return false;}).
		on('click', 'a.delete', function(){ // 削除
			deleteUser($(this).parent().attr('id'));
			return false;});
	/*
	 */
	$('#search-form').on('submit', function(event){
		try {
			new RegExp($('#search-field').val());
		} catch (e) {
			event.preventDefault();
			message.error(e);
		}
	});

	/*
	 * automatic link
	 */
	$('.statement-message').autoLink();
	var $container = $('#items');
	$container.imagesLoaded(function(){
		$container.masonry({
			itemSelector : '.item',
			columnWidth : 110
		});
	});

	/*
	 * local setting
	 */
	var notificationCheck = $('#popup-notification');
	if(window.Notification && localStorage){
		if(localStorage['popupNotification'] === 'true'){
			if(Notification.permission === 'granted'){
				notificationCheck.prop('checked', true);
			}
		}
	}else{
		notificationCheck.prop('disabled', true);
	}

	notificationCheck.on('click', function(){
		if($(this).prop('checked')){
			if(Notification.permission === 'granted'){
				localStorage['popupNotification'] = 'true';
			}else{
				Notification.requestPermission(function(){
					localStorage['popupNotification'] = 'true';
				});
			}
		}else{
			localStorage['popupNotification'] = 'false';
		}
	});

	/*
	 * share search
	 */
	function shareSearch(method, success, fail) {
		$.ajax({
			url: '/search/pin',
			type: method,
			dataType: 'json',
			data: {q: $('#query-string').attr('title')}
		}).done(function(result){
			$('a.share-search').toggleClass('hide');
			success(result);
		}).fail(function(XMLHttpRequest, textStatus, errorThrown){
			fail(XMLHttpRequest.status, textStatus);
		});
	}

	$('#share-search').on('click', function(){
		shareSearch('POST',
		function(result){
			var q = result[0]['q'];
			var l = result[0]['label'];
			var a = $('<a>').attr('href', '/search?q=' + q.replace(/#/g, '%23').replace(/\+/g, '%2B')).attr('title', q).text(l);
			$('#search-pin').prepend(
				$('<li>').addClass('search-pin').append(a.clone())
			);
			$('#search-pin-dropdown').prepend(
				$('<span>').addClass('search-pin').append(a.clone())
			);
		},
		function(status, msg){
			if(XMLHttpRequest.status != 409){
				// error without 409 (conflict)
				message.error(msg + '(' + status + ')');
			}
		});
		return false;
	});

	$('#unshare-search').on('click', function(){
		shareSearch('DELETE',
		function(result){
			$('.search-pin a').each(function(){
				if($(this).attr('title') == result[0].q){
					$(this).parent().remove();
				}
			});
		},
		function(status, msg){
			if(XMLHttpRequest.status != 404){
				// error without 404 (not found)
				message.error(msg + '(' + status + ')');
			}
		});
		return false;
	});

	/*
	 * plugins
	 */
	function plugin_setup(name, opts){
		var plugin = name.match(/^([^\/]+)\/([^ ]+) (.*)$/);
		switch(plugin[1]){
			case "notify":
				switch(plugin[2]){
					case "information":
						break;
					case "like":
						plugin_notify_like(plugin[3], opts);
						break;
				}
				break;
		}
	}

	function plugin_notify_like(id, opts){
		var del = opts['delete'] || 'owner';
		var myIcon = $('#'+id+' img[alt='+me+']').length !== 0;

		var likeButton = $('#'+id+'-like');
		var unlikeButton = $('#'+id+'-unlike');
		if(myIcon){
			likeButton.hide();
		}else{
			unlikeButton.hide();
		}

		likeButton.on('click', function(){
			$.ajax({
				url: '/plugin/notify/like/' + id,
				type: 'POST',
				dataType: 'json'
			}).done(function(result){
				plugin_notify_like_draw_icons(id, result);
			}).fail(function(XMLHttpRequest, textStatus, errorThrown){
				message.error('(' + textStatus + ')');
			});

			return false;
		});

		unlikeButton.on('click', function(){
			$.ajax({
				url: '/plugin/notify/like/' + id + '/' + me,
				type: 'DELETE',
				dataType: 'json'
			}).done(function(result){
				plugin_notify_like_draw_icons(id, result);
			}).fail(function(XMLHttpRequest, textStatus, errorThrown){
				message.error('(' + textStatus + ')');
			});

			return false;
		});

		$('#' + id).on('click', 'a.' + id + '-delete', function(){
			var name = $('img', this).attr('alt');

			$.ajax({
				url: '/plugin/notify/like/' + id + '/' + name,
				type: 'DELETE',
				dataType: 'json'
			}).done(function(result){
				plugin_notify_like_draw_icons(id, result);
			}).fail(function(XMLHttpRequest, textStatus, errorThrown){
				message.error('(' + textStatus + ')');
			});

			return false;
		});

		$Massr.intervalFunctions.push(function(){
			$.getJSON('/plugin/notify/like/' + id + '.json', function(json){
				plugin_notify_like_draw_icons(id, json);
			});
		});

		function plugin_notify_like_draw_icons(id, icons){
			var elem = $('#' + id);

			elem.empty();
			$('#'+id+'-like').show();
			$('#'+id+'-unlike').hide();
			$.each(icons, function(name, val){
				if(del == 'any'){
					elem.append(
						$('<a>').addClass(id + '-delete').attr('href', '#').append(
							$('<img>').
							addClass('massr-icon-mini').
							attr('src', val[1]).
							attr('alt', name).
							attr('title', 'delete ' + name)
						)
					).append('&nbsp;')
				}else{
					elem.append(
						$('<img>').
						addClass('massr-icon-mini').
						attr('src', val[1]).
						attr('alt', name).
						attr('title', name)
					)
				}
				if(me == name){
					$('#'+id+'-like').hide();
					$('#'+id+'-unlike').show();
				}
			});
		}
	}

	if (fileEnabled) {
		function clearPhoto(form) {
			var $form = $(form);
			var photoShadow = $form.find('.photo-shadow');
			photoShadow.replaceWith(photoShadow.val("").clone(true));
			$form.find(".photo-name").text("");
			$form.find(".photo-preview").css("display", "none");
		}

		$('.photo-shadow').change(function() {
			var shadow = $(this);
			var preview = shadow.siblings('.photo-preview');
			if (this.files.length) {
				var fileReader = new FileReader();
				fileReader.onload = function(event) {
					if (shadow.hasClass('for-icon')) {
						var icon = new Image();
						icon.src = event.target.result;
					}
					$(preview).css('background-image', "url(" + event.target.result + ")").css('display', 'inline')
				};
				fileReader.readAsDataURL(this.files[0]);
			} else {
				$(preview).css('display', 'none');
			}
		});
	}
});
