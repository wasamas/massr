/*
 * massr - title_bar.js
 *
 * Copyright (C) 2016 by wasam@s production
 * You can modify and/or distribute this under GPL.
 */
import * as React from 'react';
import {Component} from 'flumpt';
import {MuiThemeProvider, AppBar, Drawer, MenuItem} from 'material-ui';
import muiTheme from '../theme';

export const MENU_RES = 'menu-res';
export const MENU_USER_PHOTOS = 'menu-user-photos';
export const MENU_ALL_PHOTOS = 'menu-all-photos';
export const MENU_STAMP_LIST = 'menua-stamp-list';
export const MENU_LIKED = 'menu-liked';
export const MENU_LIKES = 'menu-likes';
export const MENU_SETTINGS = 'menu-settings';
export const MENU_ADMIN = 'menu-admin';
export const MENU_LOGOUT = 'menu-logout';

export default class TitleBar extends Component {
	constructor(...args) {
		super(...args);
		this.state = {menuOpen: false};
	}

	_(str, ...args) {
		return this.props.settings.local[str].replace(/%(\d)/g, (m, p) => args[p-1]);
	}

	menuItems() {
		return [
			[MENU_RES, 'res'],
			[MENU_USER_PHOTOS, 'user_photos', this.props.me],
			[MENU_ALL_PHOTOS, 'all_photos'],
			[MENU_STAMP_LIST, 'stamps'],
			[MENU_LIKED, 'liked'],
			[MENU_LIKES, 'likes'],
			[MENU_SETTINGS, 'settings'],
			[MENU_ADMIN, 'admin_menu'],
			[MENU_LOGOUT, 'logout'],
		].map(m => {
			return <MenuItem key={m[0]} onClick={() => {
				this.setState({menuOpen: false});
				this.dispatch(m[0]);
			}}>{this._(m[1], m[2])}</MenuItem>;
		});
	}

	render() {
		return(<div>
			<MuiThemeProvider muiTheme={muiTheme}>
				<AppBar title={this._('site_name')}
					onClick={() => this.setState({menuOpen: !this.state.menuOpen})}
				/>
			</MuiThemeProvider>
			<MuiThemeProvider muiTheme={muiTheme}>
				<Drawer docked={false} open={this.state.menuOpen}
						onRequestChange={(menuOpen) => this.setState({menuOpen})}>
					{this.menuItems()}
				</Drawer>
			</MuiThemeProvider>
		</div>);
	}
};


