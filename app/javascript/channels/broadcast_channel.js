import CableReady from 'cable_ready'
import consumer from './consumer'


consumer.subscriptions.create('BroadcastChannel', {
  // // print out a connection established
  // connected(data) {
  //   console.log("BroadcastChannel" + data)
  // },
  received(data) {
    if (data.cableReady) CableReady.perform(data.operations)
  }
})
