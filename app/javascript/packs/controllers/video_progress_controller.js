import { Controller } from "stimulus"
import consumer from "../../channels/consumer"

export default class extends Controller {
  static targets = ["card", "create"]
  connect() {
    let controller = this;
    consumer.subscriptions.create(
      {
        channel: "VideoProgressChannel",
        type: this.cardTarget.dataset.type,
        video_id: this.cardTarget.dataset.videoId
      }, {
      connected() {
        console.log('connected VideoProgressChannel')
      },

      disconnected() {
        // Called when the subscription has been terminated by the server
      },

      received(html) {
        controller.replaceCard(html)
      }
    });
  }

  create() {
    let createUrl = this.createTarget.dataset.url
    fetch(createUrl)
      .then(response => response.text())
      .then(html => { this.replaceCard(html) })
  }

  replaceCard(html) {
    console.log(html)
    this.cardTarget.outerHTML = html
  }
}
