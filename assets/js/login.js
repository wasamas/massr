/*
 * login - login.js
 *
 * Copyright (C) 2016 by The wasam@s production
 * You can modify and/or distribute this under GPL.
 */
import 'babel-polyfill';
import 'whatwg-fetch';
import * as React from 'react';
import {render} from 'react-dom';
import {Flux} from 'flumpt';
import injectTapEventPlugin from 'react-tap-event-plugin';
import {MuiThemeProvider, RaisedButton} from 'material-ui';
import ImageNavigateNext from 'material-ui/svg-icons/image/navigate-next';
import Footer from './component/footer';
import muiTheme from './theme';

require('../css/default.css');
injectTapEventPlugin();

const main = document.querySelector('#main');
const state = {
};

class Login extends Flux {
	render(state) {
		return(
			<div>
				<MuiThemeProvider muiTheme={muiTheme}>
					<RaisedButton label="Login with Twitter"
						onTouchTap={e => {location.href = "/auth/twitter"}}
						primary={true}
						icon={<ImageNavigateNext/>}
					/>
				</MuiThemeProvider>
				<Footer/>
			</div>
		);
	}
}

const app = new Login({
	renderer: el => {
		render(el, main);
	},
	initialState: state
});
app.update(_initialState => (state));

