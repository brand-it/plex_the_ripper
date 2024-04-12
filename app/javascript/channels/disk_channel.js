import CableReady from 'cable_ready'
import consumer from './consumer'

console.log("disk_channel.js")

consumer.subscriptions.create('DiskTitleChannel', {
  // print out a connection established
  connected(data) {
    console.log("DiskTitleChannel" + data)
  },
  received(data) {
    if (data.cableReady) CableReady.perform(data.operations)
  }
})
