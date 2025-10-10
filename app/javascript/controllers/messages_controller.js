import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]

  handleKeyDown(event) {
    // Ctrl+Enter or Cmd+Enter to submit
    if ((event.ctrlKey || event.metaKey) && event.key === 'Enter') {
      event.preventDefault()
      this.submitForm()
    }
  }

  submitForm() {
    // Find the submit button and click it
    if (this.hasSubmitTarget) {
      this.submitTarget.click()
    } else {
      // Fallback: find the form and submit it
      const form = this.element
      if (form.tagName === 'FORM') {
        form.requestSubmit()
      }
    }
  }
}

