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
import {POST_RES, POST_LIKE, POST_UNLIKE, POST_STAMP} from '../container/statement';
import SideBar from '../container/side_bar';

export default class Main extends Flux {
	constructor(...args) {
		super(...args);

		setInterval(() => {
			this.update(state => {
				//state.flush = true;
				return state;
			});
			this.update(state => {
				state.flush = false;
				return state;
			});
		}, 10000);
	}

	mergeStatement(oldArray, newArray) {
		let oldObj = {}, newObj = {};
		oldArray.map(s => (oldObj[s.id] = s));
		newArray.map(s => (newObj[s.id] = s));

		const mergedObj = Object.assign(oldObj, newObj);
		return Object.keys(mergedObj).map(id => mergedObj[id]).sort((a, b) => {
			return a.created_at > b.created_at ? -1 : 1;
		});
	}

	subscribe() {
		this.on(UPDATE_STATEMENTS, statements => {
			this.update(state => {
				state.statements = this.mergeStatement(state.statements, statements);
				return state;
			});
		});

		this.on(POST_RES, res => {
			console.info('POST_RES', res);
		});

		this.on(POST_LIKE, statement => {
			this.update(state => {
				return new Promise((resolve, reject) => {
					let form = new FormData();
					form.append('_csrf', document.querySelector('meta[name="_csrf"]').content);
					fetch('/statement/' + statement.id + '/like', {method: 'POST', body: form, credentials: 'same-origin'}).
					then(res => res.json()).
					then(json => {
						state.statements = this.mergeStatement(state.statements, [json])
						return resolve(state);
					}).
					catch(err => console.error(POST_LIKE, err));
				});
			});
		});

		this.on(POST_UNLIKE, statement => {
			this.update(state => {
				return new Promise((resolve, reject) => {
					let form = new FormData();
					form.append('_csrf', document.querySelector('meta[name="_csrf"]').content);
					fetch('/statement/' + statement.id + '/like', {method: 'DELETE', body: form, credentials: 'same-origin'}).
					then(res => res.json()).
					then(json => {
						state.statements = this.mergeStatement(state.statements, [json])
						return resolve(state);
					}).
					catch(err => console.error(POST_UNLIKE, err));
				});
			});
		});

		this.on(POST_STAMP, statement => {
			console.info('POST_STAMP', statement);
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
