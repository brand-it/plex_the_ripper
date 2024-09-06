import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['showMore']

  connect() {
    if (!this.hasShowMoreTarget || this.showMoreTarget.dataset.disableWith === undefined) return
    window.addEventListener("scroll", () => {
      if (this.showMoreVisable()) this.showMoreTarget.click();
    });
    if (this.showMoreVisable()) this.showMoreTarget.click();
  }

  showMoreVisable() {
    if (!this.hasShowMoreTarget || this.disabled()) return false
    var showMoreBox = this.showMoreTarget.getBoundingClientRect();
    return showMoreBox.top + this.topOffset() <= window.innerHeight && showMoreBox.left + this.leftOffset() <= window.innerWidth
  }

  disabled() {
    return this.showMoreTarget.dataset.disableWith == this.showMoreTarget.value
  }

  topOffset() {
    return parseInt(this.showMoreTarget.dataset.topOffset) || 0
  }

  leftOffset() {
    return parseInt(this.showMoreTarget.dataset.leftOffset) || 0
  }
}
