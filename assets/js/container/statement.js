/*
 * massr - statement.js
 *
 * Copyright (C) 2016 by wasam@s production
 * You can modify and/or distribute this under GPL.
 */
import * as React from 'react';
import {Component} from 'flumpt';
import {MuiThemeProvider, IconButton, Avatar} from 'material-ui';
import StampButton from '../component/stamp_button';
import ResButton from '../component/res_button';
import LikeButton from '../component/like_button';
import {get_icon_url} from '../util';

export const POST_STAMP = 'post-stamp';
export const POST_RES = 'post-res';
export const POST_LIKE = 'post-like';
export const POST_UNLIKE = 'post-unlike';

export default class Statement  extends Component {
	_(str) {
		return this.props.settings.local[str];
	}

	icon(user) {
		return(<div className='statement-icon'>
			<a href={'/user/' + user.massr_id}>
				<MuiThemeProvider>
					<Avatar src={get_icon_url(user)} alt='' size={45}/>
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
					{s.body}
					{this.photo(s)}
					{this.like(s)}
					{this.action(s)}
					{this.form(s)}
				</div>
			</div>
		);
	}

	photo(s) {
		return(<div className='statement-photos'>
		</div>);
	}

	info(s) {
		return(<div className='statement-info'>
			<a className='statemenet-name' href={'/user/' + s.user.massr_id}>{s.user.name}</a>
			&nbsp;
			<a href={'/statement/' + s.id}>{s.created_at}</a>
		</div>);
	}

	action(s) {
		const style = {width: 32, height: 32, padding: 6};
		const iconStyle = {width: 20, height: 20};
		const like = s.likes.findIndex(l => {
			return(l.user.massr_id === this.props.me)
		}) == -1 ? true : false;

		return(<div className='statement-action'>
			<StampButton size={[20, 32]} label={this._('attach_stamp')} onClick={()=>this.dispatch(POST_STAMP, s.id)}/>
			<ResButton size={[20, 32]} label={this._('res')} onClick={()=>this.dispatch(POST_RES, s.id)}/>
			<LikeButton size={[20, 32]} like={like} label={this._('like')} onClick={()=>this.dispatch(like ? POST_LIKE:POST_UNLIKE, s)}/>
		</div>);
	}

	like(s) {
		const likes = s.likes.map(like => {
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
			/*
			return(<a key={like.id} href={'/user/' + like.user.massr_id}>
				<MuiThemeProvider>
					<IconButton 
					<Avatar src={get_icon_url(like.user)} alt={like.user.name} title={like.user.name} size={20} style={{padding: '6px'}}/>
				</MuiThemeProvider>
			</a>);
			*/
		});

		if (likes.length == 0) {
			return '';
		} else {
			return(<div className='statement-like'>{likes}</div>);
		}
	}

	form(s) {
		return(<div className='response'>
			<form action='/statement' className='res-form' encType='multipart/form-data' method='POST'>
				<div>
					<textarea name='body' type='text'/>
					<input name='res_id' type='hidden' value={s.id}/>
				</div>
				<div className='button'>
					<button className='btn btn-small submit' type='submit'>レスるわ</button>
					<div className='photo-items'>
						<input accept='image/*' className='photo-shadow' name='photo' tabIndex='-1' type='file'/>
						<a className='photo-button' href='#'>写真を添付</a>
						<img className='photo-preview'/>
						<span className='photo-name'/>
					</div>
				</div>
			</form>
		</div>);
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
