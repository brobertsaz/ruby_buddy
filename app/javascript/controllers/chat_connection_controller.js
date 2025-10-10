import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["connectionStatus", "reconnectButton", "messageList"]
  static values = {
    mentorshipRequestId: Number,
    currentUserId: Number,
    currentUserName: String
  }

  connect() {
    console.log("✨ Chat connection controller connected - ready for real-time features! ✨")
    this.initializeConnectionStatus()
    this.scrollToBottom()

    // Listen for turbo stream updates to scroll to bottom
    document.addEventListener('turbo:before-stream-render', this.handleStreamRender.bind(this))
  }

  disconnect() {
    document.removeEventListener('turbo:before-stream-render', this.handleStreamRender.bind(this))
  }

  handleStreamRender(event) {
    // Auto-scroll when new messages arrive
    setTimeout(() => this.scrollToBottom(), 100)
  }

  scrollToBottom() {
    if (this.hasMessageListTarget) {
      this.messageListTarget.scrollTop = this.messageListTarget.scrollHeight
    }
  }

  // Initialize beautiful connection status indicator
  initializeConnectionStatus() {
    if (this.hasConnectionStatusTarget) {
      this.connectionStatusTarget.innerHTML = `
        <div class="connection-status connected flex items-center space-x-2 px-3 py-1.5 bg-zinc-800/50 border border-zinc-700 rounded-lg">
          <div class="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
          <span class="text-xs font-medium text-zinc-400">Live</span>
        </div>
      `
    }
  }

  // Handle message sending start
  handleMessageSending(event) {
    console.log("Message sending started...")
  }

  // Handle message sent completion
  handleMessageSent(event) {
    console.log("Message sent successfully!")
    // Clear the form after successful send
    const form = event.target
    if (form && form.tagName === 'FORM') {
      const textarea = form.querySelector('textarea')
      if (textarea) {
        textarea.value = ''
        textarea.style.height = 'auto'
      }
    }
  }

  // Manual reconnection triggered by user (placeholder)
  reconnect(event) {
    event?.preventDefault()
    console.log("Reconnect clicked - this would reconnect ActionCable")

    if (this.hasConnectionStatusTarget) {
      this.connectionStatusTarget.innerHTML = `
        <div class="connection-status connecting flex items-center space-x-2 px-3 py-2 bg-amber-50 border border-amber-200 rounded-lg">
          <div class="connection-pulse animate-pulse w-2 h-2 bg-amber-400 rounded-full"></div>
          <span class="text-sm font-medium text-amber-700">Reconnecting...</span>
        </div>
      `
    }

    // Simulate reconnection success after 1 second
    setTimeout(() => {
      this.initializeConnectionStatus()
    }, 1000)
  }
}