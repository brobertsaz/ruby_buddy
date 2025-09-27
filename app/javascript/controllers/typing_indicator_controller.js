import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "indicator", "userList"]
  static values = {
    mentorshipRequestId: Number,
    currentUserId: Number,
    currentUserName: String
  }

  connect() {
    this.isTyping = false
    this.typingTimer = null
    this.typingUsers = new Set()
    this.TYPING_TIMEOUT = 3000 // 3 seconds

    // Initialize with beautiful fade-in animation
    this.indicatorTarget.style.opacity = "0"
    this.indicatorTarget.style.transform = "translateY(10px)"
    this.indicatorTarget.classList.add("transition-all", "duration-300", "ease-in-out")

    console.log("✨ Typing indicator controller connected - ready for magic! ✨")
  }

  disconnect() {
    if (this.typingTimer) {
      clearTimeout(this.typingTimer)
    }
    this.stopTyping()
  }

  // Called when user starts typing
  startTyping() {
    if (!this.isTyping) {
      this.isTyping = true
      this.sendTypingStatus(true)

      // Add beautiful pulse animation while typing
      this.inputTarget.classList.add("ring-2", "ring-rose-400", "ring-opacity-50")
    }

    // Reset the timeout
    if (this.typingTimer) {
      clearTimeout(this.typingTimer)
    }

    this.typingTimer = setTimeout(() => {
      this.stopTyping()
    }, this.TYPING_TIMEOUT)
  }

  // Called when user stops typing
  stopTyping() {
    if (this.isTyping) {
      this.isTyping = false
      this.sendTypingStatus(false)

      // Remove typing animation
      this.inputTarget.classList.remove("ring-2", "ring-rose-400", "ring-opacity-50")
    }

    if (this.typingTimer) {
      clearTimeout(this.typingTimer)
      this.typingTimer = null
    }
  }

  // Handle input events with debouncing
  handleInput(event) {
    if (event.target.value.length > 0) {
      this.startTyping()
    } else {
      this.stopTyping()
    }
  }

  // Handle key events for better UX
  handleKeydown(event) {
    // Don't trigger typing for special keys
    if (this.isSpecialKey(event.key)) {
      return
    }

    this.startTyping()
  }

  // Send typing status to server
  async sendTypingStatus(typing) {
    try {
      const response = await fetch(`/api/mentorship_requests/${this.mentorshipRequestIdValue}/typing`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        },
        body: JSON.stringify({ typing })
      })

      if (!response.ok) {
        console.warn('Failed to update typing status:', response.statusText)
      }
    } catch (error) {
      console.error('Error sending typing status:', error)
    }
  }

  // Update typing indicator from WebSocket
  updateTypingUsers(data) {
    const { user_id, user_name, typing } = data

    // Don't show typing indicator for current user
    if (user_id === this.currentUserIdValue) {
      return
    }

    if (typing) {
      this.typingUsers.add({ id: user_id, name: user_name })
    } else {
      this.typingUsers = new Set(
        Array.from(this.typingUsers).filter(user => user.id !== user_id)
      )
    }

    this.renderTypingIndicator()
  }

  // Render beautiful typing indicator with animations
  renderTypingIndicator() {
    const typingArray = Array.from(this.typingUsers)

    if (typingArray.length === 0) {
      // Hide with smooth fade-out animation
      this.hideTypingIndicator()
    } else {
      // Show with smooth fade-in animation
      this.showTypingIndicator(typingArray)
    }
  }

  // Show typing indicator with beautiful animation
  showTypingIndicator(typingUsers) {
    const names = typingUsers.map(user => user.name).join(', ')
    const isPlural = typingUsers.length > 1
    const verb = isPlural ? 'are' : 'is'

    this.indicatorTarget.innerHTML = `
      <div class="flex items-center space-x-3 py-3 px-4 bg-gradient-to-r from-rose-50 to-pink-50 rounded-xl border border-rose-100 shadow-sm">
        <div class="flex space-x-1">
          <div class="typing-dot bg-rose-400"></div>
          <div class="typing-dot bg-rose-400 animation-delay-150"></div>
          <div class="typing-dot bg-rose-400 animation-delay-300"></div>
        </div>
        <span class="text-sm font-medium text-rose-700">
          <span class="font-semibold">${names}</span> ${verb} typing...
        </span>
      </div>
    `

    // Animate in
    requestAnimationFrame(() => {
      this.indicatorTarget.style.opacity = "1"
      this.indicatorTarget.style.transform = "translateY(0)"
    })
  }

  // Hide typing indicator with smooth animation
  hideTypingIndicator() {
    this.indicatorTarget.style.opacity = "0"
    this.indicatorTarget.style.transform = "translateY(-10px)"

    setTimeout(() => {
      if (this.indicatorTarget.style.opacity === "0") {
        this.indicatorTarget.innerHTML = ""
      }
    }, 300)
  }

  // Utility methods
  isSpecialKey(key) {
    const specialKeys = [
      'Shift', 'Control', 'Alt', 'Meta', 'CapsLock', 'Tab',
      'Escape', 'ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight',
      'Home', 'End', 'PageUp', 'PageDown', 'Insert', 'Delete'
    ]
    return specialKeys.includes(key)
  }

  getCSRFToken() {
    return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
  }
}