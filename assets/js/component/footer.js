/*
 * massr - footer.js
 *
 * Copyright (C) 2016 by wasam@s production
 * You can modify and/or distribute this under GPL.
 */
import * as React from 'react';
import {Component} from 'flumpt';
import {MuiThemeProvider, AppBar} from 'material-ui';
import muiTheme from '../theme';

export default class Footer extends Component {
	render() {
		return(<footer>
			<div>
				<a href='https://github.com/tdtds/massr' target='_blank'>Massr</a>
				&nbsp;&copy; the wasam@s production
			</div>
		</footer>);
	}
};


