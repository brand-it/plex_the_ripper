import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['showMore']

  initalize() {
    this.loading = false
  }
  connect() {
    document.addEventListener("turbo:before-stream-render", () => {
      this.loading = false
    })
    window.addEventListener("scroll", () => {
      if (this.showMoreVisable()) this.clickShowMore();
    });
  }

  showMoreVisable() {
      if (this.loading == true || !this.hasShowMoreTarget) return false
      var showMoreBox = this.showMoreTarget.getBoundingClientRect();
      return showMoreBox.top >= 0 && showMoreBox.left >= 0 && showMoreBox.right <= window.innerWidth && (showMoreBox.bottom - 2000) <= window.innerHeight
  }

  clickShowMore() {
    this.loading = true
    this.showMoreTarget.click();
    this.showMoreTarget.remove();
  }
}
