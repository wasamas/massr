/*
 * massr - theme.js: theme of material-ui
 *
 * Copyright (C) 2016 by wasam@s production
 * You can modify and/or distribute this under GPL.
 */
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import * as colors from 'material-ui/styles/colors';

const muiTheme = getMuiTheme({
	palette: {
		primary1Color: colors.lightBlue500,
		primary2Color: colors.lightBlue700,
		primary3Color: colors.grey400,
		accent1Color: colors.pinkA200,
		accent2Color: colors.grey100,
		accent3Color: colors.grey500,
		textColor: colors.darkBlack,
		alternateTextColor: colors.white,
		canvasColor: colors.white,
		borderColor: colors.grey300,
		pickerHeaderColor: colors.lightBlue500,
		shadowColor: colors.fullBlack
	},
	appBar: {
		height: 48
	},
});

export default muiTheme;
