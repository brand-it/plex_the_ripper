// Load all the channels within this directory and all subdirectories.
// Channel files must be named *_channel.js.

const channels = require.context('.', true, /_channel\.js$/)
console.log("channels", channels.keys())
channels.keys().forEach(channels)
