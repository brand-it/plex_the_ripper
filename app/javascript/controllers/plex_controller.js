import { Controller } from "@hotwired/stimulus"
let debounce = require("lodash/debounce");

export default class extends Controller {
  static targets = ["username", "password", "host", "input"]
  static values = { url: String }

  initialize(){
    this.suggestion = debounce(this.suggestion, 300).bind(this)
  }

  connect() {
    // Add focusout event listener to all input targets
    this.inputTargets.forEach(input => {
      input.addEventListener('focusout', this.onFocusOut.bind(this));
    });
  }

  disconnect() {
    // Remove focusout event listener from all input targets
    this.inputTargets.forEach(input => {
      input.removeEventListener('focusout', this.onFocusOut.bind(this));
    });
  }

   onFocusOut() {
    setTimeout(() => {
      this.clearAutoComplete();
    }, 150);
  }
  // json response looks like this
  // {
  //     "dirs": [
  //         "/Media"
  //     ],
  //     "message": null,
  //     "success": true
  // }
  suggestion(event) {
    const input = event.target;
    const inputValue = input.value;

    if (inputValue) {
      const urlWithParams = this.buildUrlWithParams(inputValue);
      fetch(urlWithParams, {
        method: 'GET'
      })
        .then(response => response.json())
        .then(json => this.showAutoComplete(input, json))
        .catch(error => console.error('Fetch error:', error));
    } else {
      this.clearAutoComplete();
    }
  }

  buildUrlWithParams(query) {
    const params = {
      query: query,
      host: this.hostTarget.value,
      password: this.passwordTarget.value,
      username: this.usernameTarget.value
    };
    return this.urlValue + ".json?" + new URLSearchParams(params);
  }

  showAutoComplete(input, response) {
    let list = this.findOrCreateList(input);
    list.innerHTML = '';
    response.dirs.forEach(function (suggestion) {
      const suggestionDiv = document.createElement('div');
      suggestionDiv.textContent = suggestion;
      list.appendChild(suggestionDiv);
    })
    list.style.display = 'block';
  }

  autoCompleteClicked(event) {
    const suggestionDiv = event.target;
    const input = suggestionDiv.closest('.form-group').querySelector('input');
    input.value = suggestionDiv.textContent;
    this.clearAutoComplete();
  }

  findOrCreateList(input) {
    const parent = input.closest('.form-group');
    let list = parent.querySelector('.autocomplete-list');

    if (!list) {
      list = document.createElement('div');
      list.className = 'autocomplete-list';
      list.dataset.action = 'click->plex#autoCompleteClicked'
      parent.appendChild(list);
    }

    return list;
  }

  clearAutoComplete() {
    const lists = document.querySelectorAll('.autocomplete-list');
    lists.forEach(list => list.style.display = 'none');
  }

}
