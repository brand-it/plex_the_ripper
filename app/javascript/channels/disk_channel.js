import CableReady from 'cable_ready/javascript'
import consumer from './consumer'

consumer.subscriptions.create('DiskTitleChannel', {
  received(data) {
    if (data.cableReady) CableReady.perform(data.operations)
  }
})
