import { Controller } from "@hotwired/stimulus"
import debounce from "lodash/debounce";

// Connects to data-controller="submit-on-keyup"
export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.lastSubmittedValue = this.inputTarget.value;  // Initialize with the current input value
    this.submitWithDebounce = debounce(this.submitWithDebounce.bind(this), 300);
  }

  submitWithDebounce(event) {
    event.preventDefault();

    // Only submit if the current input value is different from the last submitted value
    if (this.inputTarget.value !== this.lastSubmittedValue) {
      this.lastSubmittedValue = this.inputTarget.value;  // Update the last submitted value
      this.element.requestSubmit();
    }
  }
}
