/*
 * massr.plugin.js : plugin setup
 *
 * Copyright (C) 2015 by The wasam@s production
 *
 * Distributed under GPL
 */
import Massr from './massr'

Massr.plugin_setup = function(name, opts){
	var plugin = name.match(/^([^\/]+)\/([^ ]+) (.*)$/) || [name];
	switch(plugin[1]){
		case "notify":
			switch(plugin[2]){
				case "information":
					break;
				case "like":
					Massr.plugin_notify_like(plugin[3], opts);
					break;
			}
			break;
	}
}
