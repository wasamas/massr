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
		const like = this.props.like;
		const className = like ? 'like' : 'unlike';
		const iconClassName = like ? 'muidocs-icon-custom-unlike' : 'muidocs-icon-custom-like';
		const iconStyle = {width: s[0], height: s[0]};
		const style = {width: s[1], height: s[1], padding: (s[1]-s[0])/2}
		return(<MuiThemeProvider>
			<IconButton className={className}
				iconClassName={iconClassName}
				onTouchTap={(e)=>this.props.onClick()}
				key='like'
				iconStyle={iconStyle}
				style={style}
				tooltip={this.props.label}
			/>
		</MuiThemeProvider>);
	}
};



