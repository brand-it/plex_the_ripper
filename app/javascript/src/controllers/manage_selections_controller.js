import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="manage-selections"
export default class extends Controller {
  static targets = ['input']

  clearInputs() {
    this.inputTargets.forEach(input => {
      if (input.type === 'text') {
        input.value = ''
      } else if (input.type === 'checkbox' || input.type === 'radio') {
        input.checked = false
      } else if (input.tagName.toLowerCase() === 'select') {
        input.selectedIndex = 0
      }
    })
  }

  
}
