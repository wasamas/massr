/*
 * massr - statement.js
 *
 * Copyright (C) 2016 by wasam@s production
 * You can modify and/or distribute this under GPL.
 */
import * as React from 'react';
import {Component} from 'flumpt';
import {MuiThemeProvider, IconButton} from 'material-ui';
import {CommunicationChatBubble, EditorInsertEmoticon} from 'material-ui/svg-icons';
import {get_icon_url} from '../util';

export default class Statement  extends Component {
	icon(user) {
		return(<div className='statement-icon'>
			<a href={'/user/' + user.massr_id}>
				<img className='massr-icon' src={get_icon_url(user)}/>
			</a>
		</div>);
	}

	body(s) {
		const user = s.user;
		const altClass = user.massr_id == this.props.me ? 'statemenet-body-me' : '';
		return(
			<div className={'statement-body ' + altClass}>
				<div className='statement-message'>
					{s.body}
					{this.photo(s)}
					{this.info(s)}
					{this.action(s)}
					{this.like(s)}
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
			by <a href={'/user/' + s.user.massr_id}>{s.user.name}</a>
			at <a href={'/statement/' + s.id}>{s.created_at}</a>
		</div>);
	}

	action(s) {
		return(<div className='statement-action'>
			<div className='stamp-items'>
				<MuiThemeProvider><IconButton className='stamp-button' onClick={(e)=>console.info('stamp')} key='stamp' iconStyle={{width: 20, height: 20}}>
					<EditorInsertEmoticon/>
				</IconButton></MuiThemeProvider>
				<MuiThemeProvider><IconButton className='res' onClick={(e)=>console.info('res')} key='res' iconStyle={{width: 20, height: 20}}>
					<CommunicationChatBubble/>
				</IconButton></MuiThemeProvider>
				<MuiThemeProvider>
					<IconButton className='like' iconClassName='muidocs-icon-custom-like' onClick={(e)=>console.info('like')} key='like' iconStyle={{width: 20, height: 20}}/>
				</MuiThemeProvider>
			</div>
		</div>);
	}

	like(s) {
		const likes = s.likes.map(user => {
			return(<a href={'/user/' + user.massr_id}>
				<img className='massr-icon-mini' src={get_icon_url(user)} alt={user.name} title={user.name}/>
			</a>);
		});
		return(<div className='statement-like'>
			わかるわ: {likes}
		</div>);
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

		return(<div className='statement'>
			{this.icon(user)}
			{this.body(s)}
		</div>);
	}
}
