/*
 * massr - main.js
 *
 * Copyright (C) 2016 by The wasam@s production
 * You can modify and/or distribute this under GPL.
 */
import * as React from 'react';
import {Flux} from 'flumpt';
import {MuiThemeProvider, AppBar} from 'material-ui';
import TitleBar from '../component/title_bar';
import Timeline, {UPDATE_STATEMENTS} from '../container/timeline';
import SideBar from '../container/side_bar';

export default class Main extends Flux {
	constructor(...args) {
		super(...args);

		setInterval(() => {
			this.update(state => {
				state.flush = true;
				return state;
			});
			this.update(state => {
				state.flush = false;
				return state;
			});
		}, 10000);
	}

	subscribe() {
		this.on(UPDATE_STATEMENTS, statements => {
			this.update(state => {
				state.statements = statements;
				return state;
			});
		});
	}

	render(state) {
		return(
			<div>
				<TitleBar title={state._.site_name}/>
				<Timeline {...state}/>
				<SideBar {...state}/>
			</div>
		);
	}
}
