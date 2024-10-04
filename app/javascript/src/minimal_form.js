function addHasValue(input) {
  if (input.value.trim() !== '') {
    input.classList.add('has-val');
  } else {
    input.classList.remove('has-val');
  }
}

function initializeMinimalForm() {
  document.querySelectorAll('.minimal-input input').forEach(function (input) {
    addHasValue(input);
    input.addEventListener('blur', function () {
      addHasValue(this);
    });
  });
}

// Listen to Turbo events
document.addEventListener("turbo:load", initializeMinimalForm);
document.addEventListener("turbo:frame-load", initializeMinimalForm);
document.addEventListener("turbo:render", initializeMinimalForm);
document.addEventListener("turbo:before-render", initializeMinimalForm);
document.addEventListener("turbo:before-cache", initializeMinimalForm);
