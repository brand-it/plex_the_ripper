import consumer from "./consumer"

consumer.subscriptions.create("DiskChannel", {
  connected() {
    console.log('connected DiskChannel')
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log('disconnected DiskChannel')
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log(data)
  }
});
