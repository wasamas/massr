/*
 * massr - main.js
 *
 * Copyright (C) 2016 by The wasam@s production
 * You can modify and/or distribute this under GPL.
 */
import * as React from 'react';
import {Flux} from 'flumpt';
import {MuiThemeProvider, AppBar} from 'material-ui';
import TitleBar, * as menu from './title_bar';
import Timeline, {UPDATE_STATEMENTS} from './timeline';
import {POST_HITOKOTO, POST_RES} from './hitokoto_form';
import {POST_LIKE, POST_UNLIKE, POST_STAMP, DELETE_HITOKOTO} from './statement';
import SideBar from './side_bar';
import Footer from '../component/footer';

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
		}, 30000);
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

	deleteStatement(statements, statement_id) {
		return statements.filter(statement => {
			return !(statement.id === statement_id);
		});
	}

	subscribe() {
		this.on(UPDATE_STATEMENTS, statements => {
			this.update(state => {
				state.statements = this.mergeStatement(state.statements, statements);
				return state;
			});
		});

		this.on(POST_HITOKOTO, data => {
			this.update(state => {
				return new Promise((resolve, reject) => {
					data.append('_csrf', document.querySelector('meta[name="_csrf"]').content);
					fetch('/statement.json', {
						method: 'POST',
						body: data,
						credentials: 'same-origin',
						enctype: 'multipart/form-data'
					}).
					then(res => res.json()).
					then(json => {
						state.statements = this.mergeStatement(state.statements, [json])
						return resolve(state);
					}).
					catch(err => console.error(POST_HITOKOTO, err));

				});
			});
		});

		this.on(POST_RES, ({data, res}) => {
			this.update(state => {
				return new Promise((resolve, reject) => {
					data.append('res_id', res);
					data.append('_csrf', document.querySelector('meta[name="_csrf"]').content);
					fetch('/statement.json', {
						method: 'POST',
						body: data,
						credentials: 'same-origin',
						enctype: 'multipart/form-data'
					}).
					then(res => {
						if (!res.ok) throw res;
						return res.json();
					}).
					then(json => {
						state.statements = this.mergeStatement(state.statements, [json])
						return resolve(state);
					}).
					catch(err => {
						if (err.status == 404) { // res to deleted statement
							console.error(POST_RES, ': statement not found');
						} else {
							console.error(POST_RES, err);
						}
					});
				});
			});
		});

		this.on(POST_LIKE, statement => {
			// add loading icon before receive server response
			this.update(state => {
				state.statements.forEach(s => {
					if (s.id == statement.id) {
						s.likes.push({id: '-'})
					}
				});
				return state;
			});

			this.update(state => {
				return new Promise((resolve, reject) => {
					let form = new FormData();
					form.append('_csrf', document.querySelector('meta[name="_csrf"]').content);
					fetch('/statement/' + statement.id + '/like', {method: 'POST', body: form, credentials: 'same-origin'}).
					then(res => {
						if (!res.ok) throw res;
						return res.json();
					}).
					then(json => {
						state.statements = this.mergeStatement(state.statements, [json])
						return resolve(state);
					}).
					catch(err => {
						if (err.status == 404) {
							state.statements = this.deleteStatement(state.statements, statement.id);
							return resolve(state);
						} else {
							console.error(POST_LIKE, err);
						}
					});
				});
			});
		});

		this.on(POST_UNLIKE, statement => {
			// add loading icon before receive server response
			this.update(state => {
				state.statements.forEach(s => {
					if (s.id == statement.id) {
						s.likes.push({id: '-'})
					}
				});
				return state;
			});

			this.update(state => {
				return new Promise((resolve, reject) => {
					let form = new FormData();
					form.append('_csrf', document.querySelector('meta[name="_csrf"]').content);
					fetch('/statement/' + statement.id + '/like', {method: 'DELETE', body: form, credentials: 'same-origin'}).
					then(res => {
						if (!res.ok) throw res;
						return res.json();
					}).
					then(json => {
						state.statements = this.mergeStatement(state.statements, [json])
						return resolve(state);
					}).
					catch(err => {
						if (err.status == 404) {
							state.statements = this.deleteStatement(state.statements, statement.id);
							return resolve(state);
						} else {
							console.error(POST_LIKE, err);
						}
					});
				});
			});
		});

		this.on(POST_STAMP, statement => {
			console.info('POST_STAMP', statement);
		});

		this.on(DELETE_HITOKOTO, statement_id => {
			this.update(state => {
				return new Promise((resolve, reject) => {
					let form = new FormData();
					form.append('_csrf', document.querySelector('meta[name="_csrf"]').content);
					fetch('/statement/' + statement_id, {method: 'DELETE', body: form, credentials: 'same-origin'}).
					then(res => {
						if (res.ok || res.status == 404) { // success or already deleted
							state.statements = this.deleteStatement(state.statements, statement_id);
							return resolve(state);
						} else {
							throw res;
						}
					}).
					catch(err => console.error(DELETE_HITOKOTO, err));
				});
			});
		});

		this.on(menu.MENU_RES, () => {
			window.location.href = '/user/' + this.state.me + '/res';
		});

		this.on(menu.MENU_USER_PHOTOS, () => {
			window.location.href = '/user/' + this.state.me + '/photos';
		});

		this.on(menu.MENU_ALL_PHOTOS, () => {
			window.location.href = '/user/statement/photos';
		});

		this.on(menu.MENU_STAMP_LIST, () => {
			window.location.href = '/user/stamps';
		});

		this.on(menu.MENU_LIKED, () => {
			window.location.href = '/user/' + this.state.me + '/liked';
		});

		this.on(menu.MENU_LIKES, () => {
			window.location.href = '/user/' + this.state.me + '/likes';
		});

		this.on(menu.MENU_SETTINGS, () => {
			window.location.href = '/user';
		});

		this.on(menu.MENU_ADMIN, () => {
			window.location.href = '/admin';
		});

		this.on(menu.MENU_LOGOUT, () => {
			window.location.href = '/logout';
		});
	}

	render(state) {
		return(
			<div>
				<TitleBar me={state.me} settings={state.settings}/>
				<div className='container'>
					<Timeline {...state}/>
					<SideBar {...state}/>
				</div>
				<Footer/>
			</div>
		);
	}
}
