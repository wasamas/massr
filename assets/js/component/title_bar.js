/*
 * massr - title_bar.js
 *
 * Copyright (C) 2016 by wasam@s production
 * You can modify and/or distribute this under GPL.
 */
import * as React from 'react';
import {Component} from 'flumpt';
import {MuiThemeProvider, AppBar} from 'material-ui';

export default class TitleBar extends Component {
	render() {
		return(<MuiThemeProvider>
			<AppBar title={this.props.title}/>
		</MuiThemeProvider>);
	}
};


