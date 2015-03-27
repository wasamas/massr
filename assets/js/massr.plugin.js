/*
 * massr.plugin.js : plugin setup
 *
 * Copyright (C) 2015 by The wasam@s production
 *
 * Distributed under GPL
 */

$(function(){
	function plugin_setup(name, opts){
		var plugin = name.match(/^([^\/]+)\/([^ ]+) (.*)$/) || [name];
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
});

