/*
 * massr - statement.js
 *
 * Copyright (C) 2016 by wasam@s production
 * You can modify and/or distribute this under GPL.
 */
import * as React from 'react';
import {Component} from 'flumpt';
import {MuiThemeProvider, IconButton, Avatar, RefreshIndicator} from 'material-ui';
import StampButton from '../component/stamp_button';
import ResButton from '../component/res_button';
import LikeButton from '../component/like_button';
import HitokotoForm from './hitokoto_form';
import {get_icon_url} from '../util';

export const POST_STAMP = 'post-stamp';
export const POST_RES = 'post-res';
export const POST_LIKE = 'post-like';
export const POST_UNLIKE = 'post-unlike';

export default class Statement  extends Component {
	constructor(...args) {
		super(...args);
		this.state = {
			res: false
		}
	}

	_(str) {
		return this.props.settings.local[str];
	}

	icon(user, mini = false) {
		const className = mini ? 'statement-res-icon' : 'statement-icon';
		const size = mini ? 20 : 45;

		return(<div className={className}>
			<a href={'/user/' + user.massr_id}>
				<MuiThemeProvider>
					<Avatar src={get_icon_url(user)} alt='' size={size}/>
				</MuiThemeProvider>
			</a>
		</div>);
	}

	body(s) {
		const user = s.user;
		return(
			<div className='statement-body '>
				<div className='statement-message'>
					{this.info(s)}
					{this.res(s)}
					{s.body}
					{this.photo(s)}
					{this.like(s)}
					{this.action(s)}
					{this.form(s)}
				</div>
			</div>
		);
	}

	info(s) {
		return(<div className='statement-info'>
			<a className='statement-name' href={'/user/' + s.user.massr_id}>{s.user.name}</a>
			&nbsp;
			<a href={'/statement/' + s.id}>{s.created_at}</a>
		</div>);
	}

	res(s) {
		if (!s.res) return;

		const res = s.res;
		return(<div>
			{this.icon(res.user, true)}
			<div className='statement-res'>
				<a href={'/statement/' + res.id}>&lt;{res.body}</a>
			</div>
		</div>);
	}

	photo(s) {
		let photos = '';
		if (s.photos.length > 0) {
			photos = s.photos.map(photo => {
				return(<a key={photo} className='popup-image'>
					<img className='statement-photo' src={photo} alt=''/>
				</a>);
			});
		}
		return(<div className='statement-photos'>{photos}</div>);
	}

	like(s) {
		const likes = s.likes.map(like => {
			if (like.id == '-') { // waiting server response
				return(<MuiThemeProvider key={like.id}>
					<RefreshIndicator size={32} top={0} left={0} status='loading' style={{position: 'relative', display: 'inline-block'}}/>
				</MuiThemeProvider>);
			} else {
				const iconStyle = {
					width: 20, height: 20,
					backgroundImage: 'url("' + get_icon_url(like.user) + '")',
				};
				return(<MuiThemeProvider key={like.id}>
					<IconButton href={'/user/' + like.user.massr_id}
						style={{width: 32, height: 32, padding: 6}}
						iconClassName='muidocs-icon-custom-user'
						iconStyle={iconStyle}
						tooltip={like.user.name}
					/>
				</MuiThemeProvider>);
			}
		});

		if (likes.length == 0) {
			return '';
		} else {
			return(<div className='statement-like'>{likes}</div>);
		}
	}

	action(s) {
		const style = {width: 32, height: 32, padding: 6};
		const iconStyle = {width: 20, height: 20};
		const like = s.likes.findIndex(l => {
			return(l.user && l.user.massr_id === this.props.me)
		}) == -1 ? true : false;

		return(<div className='statement-action'>
			<StampButton size={[20, 32]} label={this._('attach_stamp')}
				onClick={()=>this.dispatch(POST_STAMP, s.id)}/>
			<ResButton size={[20, 32]} label={this._('res')}
				onClick={()=>this.setState({res: !this.state.res})}/>
			<LikeButton size={[20, 32]} like={like} label={this._('like')}
				onClick={()=>this.dispatch(like ? POST_LIKE:POST_UNLIKE, s)}/>
		</div>);
	}

	form(s) {
		if (this.state.res) {
			return(<div className='response'>
				<HitokotoForm value='' settings={this.props.settings}
					res={s.id} onClose={e => this.setState({res: false})}/>
			</div>);
		} else {
			return '';
		}
	}

	render() {
		const s = this.props.statement;
		const user = s.user;

		return(<div>
			<div className='statement'>
				{this.icon(user)}
				{this.body(s)}
			</div>
			<hr/>
		</div>);
	}
}
