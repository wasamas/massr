/*
 * massr - like_button.js
 *
 * Copyright (C) 2016 by wasam@s production
 * You can modify and/or distribute this under GPL.
 */
import * as React from 'react';
import {Component} from 'flumpt';
import {MuiThemeProvider, IconButton} from 'material-ui';

export default class LikeButton extends Component {
	render() {
		const s = this.props.size;
		const iconStyle = {width: s[0], height: s[0]};
		const style = {width: s[1], height: s[1], padding: (s[1]-s[0])/2}
		return(<MuiThemeProvider>
			<IconButton className='like'
				iconClassName='muidocs-icon-custom-unlike'
				onClick={(e)=>this.props.onClick(true)}
				key='like'
				iconStyle={iconStyle}
				style={style}
			/>
		</MuiThemeProvider>);
	}
};



