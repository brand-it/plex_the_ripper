import { Controller } from "stimulus"
import consumer from "../../channels/consumer"

export default class extends Controller {
  static targets = ["card"]
  connect() {
    let controller = this;
    consumer.subscriptions.create(
      {
        channel: "VideoProgressChannel",
        type: this.cardTarget.dataset.type,
        video_id: this.cardTarget.dataset.video_id
      }, {
      connected() {
        // Called when the subscription is ready for use on the server
      },

      disconnected() {
        // Called when the subscription has been terminated by the server
      },

      received(html) {
        controller.replaceCards(html)
      }
    });
  }

  replaceCards(html) {
    this.cardsTarget.innerHTML = html
  }
}
