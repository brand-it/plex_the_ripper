const path    = require("path")
const webpack = require("webpack")


// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig } = require('shakapacker')

const webpackConfig = generateWebpackConfig()

module.exports = webpackConfig


// module.exports = {
//   mode: "production",
//   devtool: "source-map",
//   entry: {
//     application: "./app/javascript/packs/application.js"
//   },
//   output: {
//     filename: "[name].js",
//     sourceMapFilename: "[file].map",
//     chunkFormat: "module",
//     path: path.resolve(__dirname, "app/assets/builds"),
//   },
//   plugins: [
//     new webpack.optimize.LimitChunkCountPlugin({
//       maxChunks: 1
//     })
//   ]
// }
