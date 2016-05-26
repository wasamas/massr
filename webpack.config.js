var webpack = require('webpack');
var ExtractTextPlugin = require("extract-text-webpack-plugin");
const path = require('path');

module.exports = {
	entry: {
		app: [
			'./assets/app.js',
			'./assets/js/jquery.auto-link.js',
			'./assets/js/jquery.pnotify.js',
			'./assets/js/massr.js',
			'./assets/js/massr.plugin.js',
			'./assets/js/massr.templates.js',
			'./assets/js/plugins/notify/like.js'
		],
		watch: './assets/watch.js'
	},
	output: {
		path: path.join(__dirname, 'public'),
		filename: '/js/[name].js'
	},
	module: {
		loaders: [
			{
				test: /\.js$/,
				exclude: /node_modules/,
				loader: 'babel',
				query: {
					cacheDirectory: true,
					presets: ['react', 'es2015']
				}
			},
			{
				test: /\.css$/,
				loader: ExtractTextPlugin.extract("style-loader", "css-loader")
			},
			{
				test: /\.(png|jpg)$/,
				loader: "file-loader?name=/img/[name].[ext]"
			},
			{
				test: require.resolve('jquery'),
				loader: "imports?jQuery=jquery"
			}
		]
	},
	plugins: [
		new ExtractTextPlugin('/css/[name].css'),
		new webpack.ProvidePlugin({
			$: "jquery",
			jQuery: "jquery"
		})
	],
	resolve: {
		extensions: ['', '.js', '.css']
	}
};
