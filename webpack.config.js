var webpack = require('webpack');
var ExtractTextPlugin = require("extract-text-webpack-plugin");
const path = require('path');

module.exports = {
	entry: {
		login: './assets/js/login.js',
		main: './assets/js/main.js'
	},
	output: {
		path: path.join(__dirname, 'public'),
		filename: './js/[name].js'
	},
	module: {
		loaders: [
			{
				test: /\.js$/,
				exclude: /node_modules/,
				loader: 'babel-loader',
				query: {
					cacheDirectory: true,
					presets: ['react', 'es2015']
				}
			},
			{
				test: /\.css$/,
				loader: ExtractTextPlugin.extract({use: 'css-loader', fallback: 'style-loader'})
			},
			{
				test: /\.(png|jpg)$/,
				loader: "file-loader?name=/img/[name].[ext]"
			}
		]
	},
	plugins: [
		new ExtractTextPlugin('/css/[name].css')
	],
	resolve: {
		extensions: ['*', '.js', '.css']
	}
};

