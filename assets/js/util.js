/*
 * massr - util.js
 *
 * Copyright (C) 2016 by The wasam@s production
 * You can modify and/or distribute this under GPL.
 */

export function isHttps(){
	return !!location.href.match(/^https/);
}

export function get_icon_url(user){
	if (isHttps()) {
		return user.twitter_icon_url_https;
	} else {
		return user.twitter_icon_url;
	}
}

export function shrinkText(text){ // replace CR/LF to single space
	if (text != null) {
		return text.replace(/[\r\n]+/g, '\r');
	} else {
		return ""
	}
}

export function loadSetting() {
	return new Promise((resolve, reject) => {
		fetch('/settings.json', {credentials: 'same-origin'}).
		then(res => res.json()).
		then(json => resolve(json)).
		catch(err => Promise.reject(err))
	});
}
