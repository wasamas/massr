/*
 * massr.templates.js : javascript templates
 *
 * Copyright (C) 2015 by The wasam@s production
 *
 * Distributed under GPL
 */
import Massr from './massr';

$(function(){
	// template of a statement
	Massr.buildStatement = function(s, isEmbedded){ // s is json object of a statement
		var me = Massr.me;
		var _ = Massr.settings['local'];
		return $('<div>').addClass('statement').addClass('id-st-'+s.id).append(
			$('<div>').addClass('statement-icon').append(
				$('<a>').attr('href', '/user/'+s.user.massr_id).append(
					$('<img>').addClass('massr-icon').attr('src', Massr.get_icon_url(s.user))
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
									attr('src', Massr.get_icon_url(s.res.user)).
									attr('alt', s.res.user.name).
									attr('title', s.res.user.name)
							)
						)
					).append(
						$('<div>').addClass('statement-res').append(
							$('<a>').attr('href', '/statement/'+s.res.id).
								text('< ' + Massr.shrinkText(s.res.body)).each(function(){
									if (s.res.stamp) {
										$(this).append($('<img>').attr('src', $.fn.image_size_change(s.res.stamp,16,true)).
										attr('alt', s.res.stamp).attr('title', s.res.stamp));
									}
								}))
					);
				}
			}).append(
				$('<div>').each(function(){
					if (s.body != null){
						$(this).addClass('statement-message').text(Massr.shrinkText(s.body)).autoLink().embedStatement(isEmbedded);
					} else {
						$(this).addClass('statement-stamp').
							append(($('<div>')).addClass('stamp-style').append(($('<div>').addClass('stamp').append(
								$('<img>').addClass('statement-stamp-img').attr('src',$.fn.image_size_change(s.stamp, Massr.settings['setting']['stamp_size'],true))
							))));
					}
				})
			).append(
				$('<div>').addClass('statement-photos').each(function(){
					var $parent = $(this);
					$.each(s.photos, function(){
						var $photo = this
						$parent.append(($('<a>').addClass('popup-image').attr('href', '#'+s.id).mfp()).
							append($('<img>').addClass('statement-photo').attr('src', $photo)));
						$parent.append(($('<div>').addClass('mfp-hide').addClass('popup-photo').attr('id',s.id)).
							append(($('<div>').addClass('stamp')).each(function(){
								var $f = false;
								$('#stamps').each(function(){
									$(this).find('img').each(function(){
										if ($.fn.image_size_change($(this).attr('src'),1)==$.fn.image_size_change($photo,1)){
											$f = true
										}
									});
								});
								if ($f == true) {
									$(this).append(($('<a>').addClass('unusestamp')).
											append($('<i>').addClass('icon-remove-circle').attr('title',_['unuse_stamp'])));
								} else {
									$(this).append(($('<a>').addClass('usestamp')).
											append($('<i>').addClass('icon-ok-circle').attr('title',_['use_stamp'])));
								}
							})).
							append(($('<div>').addClass('image')).
								append($('<a>').attr('href',$photo).attr('target','_blank').
									append($('<img>').attr('src',$photo)))));
					});
				})
			).append(
				$('<div>').addClass('statement-info').
					append('by ').
					append($('<a>').attr('href', '/user/'+s.user.massr_id).append(s.user.name)).
					append(' at ' ).
					append($('<a>').attr('href', '/statement/'+s.id).append(s.created_at))
			).append(
				$('<div>').each(function (){
					if (! isEmbedded) {
						$(this).addClass('statement-action').each(function () {
							if (s.user.massr_id == me) {
								$(this).append(
									$('<a>').addClass('trash').attr('href', '#').
										append($('<i>').addClass('icon-trash').attr('title', _['delete']))
								);
							}
						}).append(
							$('<div>').addClass('stamp-items').each(function () {
								$(this).append(
									$('<a>').addClass('stamp-button').attr('href', '#stamps').mfp().
										append($('<i>').addClass('icon-th').addClass('stamp-button').attr('title', _['attach_stamp']))
								);
							})
						).append(
							$('<a>').addClass('res').attr('href', '#').append(
								$('<i>').addClass('icon-comment').attr('title', _['res'])
							).append(
								s.ref_ids.length > 0 ? ' (' + s.ref_ids.length + ') ' : ' '
							)
						).append(
							$('<a>').attr('href', '#').addClass('like-button').addClass('id-like-' + s.id).
								each(function () {
									var classLike = 'like';
									$.each(s.likes, function () {
										if (this.user.massr_id == me) {
											classLike = 'unlike';
											return false;
										}
										return true;
									});
									$(this).addClass(classLike);
								}).
								append($('<img>').addClass('unlike').attr('src', '/img/wakaruwa.png').attr('alt', _['unlike']).attr('title', _['unlike'])).
								append($('<img>').addClass('like').attr('src', '/img/wakaranaiwa.png').attr('alt', _['like']).attr('title', _['like']))
						);
					}
				})
			).append(
				$('<div>').each(function () {
					if (!isEmbedded) {
						$(this).addClass('response').addClass('id-res-' + s.id).append(
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
										attr('value', $('meta[name="_csrf"]').
										attr('content'))
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
					}
				})
			)
		);
	};

	// template of a photo
	Massr.buildPhoto = function(s){ // s is json object of a photo
		var me = Massr.me;
		var _ = Massr.settings['local'];
		return $('<div>').addClass('item').addClass('id-st-'+s.id).append(
			$('<div>').addClass('item-body').each(function(){}).append(
				$('<div>').addClass('item-photos').each(function(){
					var $parent = $(this);
					$.each(s.photos, function(){
						var $photo = this;
						$parent.append(($('<a>').addClass('popup-image').attr('href', '#'+s.id).mfp()).
							append($('<img>').addClass('statement-photo').attr('src', $photo)));
						$parent.append(($('<div>').addClass('mfp-hide').addClass('popup-photo').attr('id',s.id)).
							append(($('<div>').addClass('stamp')).each(function(){
								var $f = false;
								$('#stamps').each(function(){
									$(this).find('img').each(function(){
										if ($.fn.image_size_change($(this).attr('src'),1)==$.fn.image_size_change($photo,1)){
											$f = true
										}
									});
								});
								if ($f == true) {
									$(this).append(($('<a>').addClass('unusestamp')).
											append($('<i>').addClass('icon-remove-circle').attr('title',_['unuse_stamp'])));
								} else {
									$(this).append(($('<a>').addClass('usestamp')).
											append($('<i>').addClass('icon-ok-circle').attr('title',_['use_stamp'])));
								}
							})).
							append(($('<div>').addClass('image')).
								append($('<img>').attr('src',$photo))).
							append(($('<div>').addClass('statement').addClass('id-st-'+s.id)).
								append(($('<div>').addClass('statement-icon')).
									append(($('<a>').attr('href','/user/'+s.user.massr_id)).
										append($('<img>').addClass('massr-icon').attr('src', Massr.get_icon_url(s.user))))).
							append(($('<div>').addClass('statement-body')).
								append(($('<div>').addClass('statement-massage').text(s.body)))).
							append($('<div>').addClass('statement-info').
								append('by ').
								append($('<a>').attr('href', '/user/'+s.user.massr_id).append(s.user.name)).
								append(' at ' ).
								append($('<a>').attr('href', '/statement/'+s.id).append(s.created_at)))))
					});
				})
			).append(
				$('<div>').addClass('item-info').
					append(' at ' ).
					append($('<a>').attr('href', '/statement/'+s.id).append(s.created_at))
			)
		);
	}
});

