import { Controller } from "stimulus"
import consumer from "../../channels/consumer"

export default class extends Controller {
  static targets = ["reload", "cards", "create"]
  connect() {
    let controller = this;
    consumer.subscriptions.create("DiskChannel", {
      connected() {
        console.log('connected DiskChannel')
      },

      disconnected() {
        console.log('disconnected DiskChannel')
      },

      received(html) {
        controller.replaceCards(html)
      }
    });
  }

  reload() {
    let reload_url = this.reloadTarget.dataset.url
    fetch(reload_url)
      .then(response => response.text())
      .then(html => { this.replaceCards(html) })
  }

  replaceCards(html) {
    html = new DOMParser().parseFromString(html, 'text/html')
    this.cardsTarget.innerHTML = html.body.firstElementChild.innerHTML
  }
}
