extractor = require 'extract-text-webpack-plugin'
webpack = require 'webpack'
uglifyer = webpack.optimize.UglifyJsPlugin

module.exports =
  entry: './src/app.coffee'
  output:
    filename: './public/app.js'
  module:
    loaders: [
      { test: /\.json$/, loader: "json" }
      { test: /\.coffee$/, loader: "coffee" }
      { test: /\.(coffee\.md|litcoffee)$/, loader: "coffee-loader?literate" }
      { test: /\.css$/, loader:  extractor.extract "style", "css" }
    ]
  plugins: [
    new extractor("./public/style.css", allChunks: true)
    new webpack.SourceMapDevToolPlugin(
      '[file].map', null,
      "[absolute-resource-path]", "[absolute-resource-path]") if process.env.NODE_ENV isnt 'production'
    new uglifyer(minimize: true, sourceMap: true) if process.env.NODE_ENV is 'production'
  ].filter(Boolean)