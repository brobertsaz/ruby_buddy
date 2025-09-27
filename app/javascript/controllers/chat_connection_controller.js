import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["connectionStatus", "reconnectButton"]
  static values = {
    mentorshipRequestId: Number,
    currentUserId: Number,
    currentUserName: String
  }

  connect() {
    console.log("✨ Chat connection controller connected - ready for real-time features! ✨")
    this.initializeConnectionStatus()
  }

  // Initialize beautiful connection status indicator
  initializeConnectionStatus() {
    if (this.hasConnectionStatusTarget) {
      this.connectionStatusTarget.innerHTML = `
        <div class="connection-status connected flex items-center space-x-2 px-3 py-2 bg-green-50 border border-green-200 rounded-lg">
          <svg class="w-4 h-4 text-green-600" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
          </svg>
          <span class="text-sm font-medium text-green-700">Connected</span>
        </div>
      `
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