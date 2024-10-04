import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="console"
export default class extends Controller {
  static targets = ['console']

  connect() {
    this.element.addEventListener('console-updated', this.handleConsoleUpdated.bind(this));
    this.scrollToBottom();
  }

  disconnect() {
    this.element.removeEventListener('console-updated', this.handleConsoleUpdated.bind(this));
  }

  handleConsoleUpdated() {
    console.log('handleConsoleUpdated')
    if (this.isAtBottom()) {
      console.log('scrollToBottom handleConsoleUpdated')
      this.scrollToBottom();
    }
  }

  isAtBottom() {
    return this.consoleTarget.scrollHeight - this.consoleTarget.clientHeight <= this.consoleTarget.scrollTop + 500;
  }

  scrollToBottom() {
    this.consoleTarget.scrollTop = this.consoleTarget.scrollHeight;
  }
}
