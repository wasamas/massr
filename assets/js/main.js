/*
 * massr - main.js
 *
 * Copyright (C) 2016 by The wasam@s production
 * You can modify and/or distribute this under GPL.
 */
import 'babel-polyfill';
import 'whatwg-fetch';
import * as React from 'react';
import {render} from 'react-dom';
import injectTapEventPlugin from 'react-tap-event-plugin';
import Main from './container/main';
import {loadSetting} from './util';

require('../css/default.css');
injectTapEventPlugin();

const main = document.querySelector('#main');

const state = {
	me: main.getAttribute('data-me'),
	settings: {},
	statements: [],
	flush: false
};

const app = new Main({
	renderer: el => {
		render(el, main);
	},
	initialState: state
});

loadSetting().
then(settings => {
	state.settings = settings;
	state._ = settings.local;
	/*
		$.each(settings['plugin'], function(name, opts){
			Massr.plugin_setup(name, opts);
		});
	*/
	app.update(_initialState => (state));
}).
catch(err => console.error('could not load settings:', err));
