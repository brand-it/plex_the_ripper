import CableReady from 'cable_ready'
import consumer from './consumer'


consumer.subscriptions.create('JobChannel', {
  // // print out a connection established
  // connected(data) {
  //   console.log("JobChannel" + data)
  // },
  received(data) {
    if (data.cableReady) CableReady.perform(data.operations)
    // Dispatch a custom event indicating new content has been added
    const event = new CustomEvent('console-updated', { bubbles: true });
    if (document.querySelector('[data-controller="console"]') != null) {
      console.log('Broadcast event')
      document.querySelector('[data-controller="console"]').dispatchEvent(event);
    }
  }
})
