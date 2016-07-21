/*
 * massr - hitokoto_form.js
 *
 * Copyright (C) 2016 by wasam@s production
 * You can modify and/or distribute this under GPL.
 */
import * as React from 'react';
import {Component} from 'flumpt';
import {MuiThemeProvider, TextField, FloatingActionButton, IconButton} from 'material-ui';
import {ActionDone, ImagePhotoCamera, EditorInsertEmoticon} from 'material-ui/svg-icons';

export const POST_HITOKOTO = 'post-hitokoto';

export default class HitokotoForm extends Component {
	constructor(...args) {
		super(...args);

		let fileEnabled = false; try {if (FileReader) {fileEnabled = true}} catch(e) {};
		this.state = {
			body: this.props.value,
			showPhoto: false,
			preview: null,
			fileEnabled: fileEnabled
		}
	}

	_(str) {
		return this.props.settings.local[str];
	}

	onSubmit(e) {
		e.preventDefault();
		this.dispatch(POST_HITOKOTO, new FormData(e.nativeEvent.target));
	}

	selectPhoto() {
		this.setState({showPhoto: true});
		this.refs.photo.click();
	}

	onPhotoChange(e) {
		if (!this.state.fileEnabled) return;

		const photo = e.nativeEvent.target;
		if (photo.files.length > 0) {
			const fileReader = new FileReader();
			fileReader.onload = event => {
				this.setState({preview: 'url(' + event.target.result + ')'});
			};
			fileReader.readAsDataURL(photo.files[0]);
		} else {
			this.setState({preview: null});
		}
	}

	render() {
		const photoStyle = {display: this.state.showPhoto ? 'inline' : 'none'};
		const previewStyle = this.state.preview ? {
			backgroundImage: this.state.preview,
			display: 'inline'
		} : {display: 'none'};

		return(<div className='new-post'>
			<form ref='form' id='form-new' onSubmit={e => this.onSubmit(e)}>
				<div>
					<MuiThemeProvider>
						<TextField id='text-new' name='body'
							defaultValue={this.props.value}
							onChange={e => this.setState({body: e.target.value})}
							hintText={this._('hitokoto')}
							multiLine={true}
							fullWidth={true}
						/>
					</MuiThemeProvider>
				</div>
				<div className='button'>
					<MuiThemeProvider>
						<FloatingActionButton className='submit' type='submit' mini={true}>
							<ActionDone/>
						</FloatingActionButton>
					</MuiThemeProvider>
					<div className='photo-items'>
						<input ref='photo' accept='image/*' className='photo-shadow' name='photo' type='file' style={photoStyle} onChange={e => this.onPhotoChange(e)}/>
						<MuiThemeProvider>
							<IconButton className='photo-button'
								onClick={e => this.selectPhoto()}
								tooltip={this._('attach_photo')}
							>
								<ImagePhotoCamera/>
							</IconButton>
						</MuiThemeProvider>
						<img className='photo-preview' style={previewStyle}/>
						<span className='photo-name'/>
					</div>
					<div className='stamp-items' id='submit-stamp'>
						<MuiThemeProvider>
							<IconButton className='stamp-button'
								onClick={e => console.info('HitokotoForm#EditorInsertEmoticon', e)}
								tooltip={this._('attach_stamp')}
							>
								<EditorInsertEmoticon/>
							</IconButton>
						</MuiThemeProvider>
					</div>
				</div>
			</form>
		</div>);
	}
}
