/*
 * notify/like.js : notify like plugin for massr
 *
 * Copyright (C) 2015 by The wasam@s production
 *
 * Distributed under GPL
 */
import Massr from '../../massr';

$(function(){
	var me = Massr.me;
	var _ = Massr.settings['local'];

	Massr.plugin_notify_like = function(id, opts){
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

		Massr.intervalFunctions.push(function(){
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
});
