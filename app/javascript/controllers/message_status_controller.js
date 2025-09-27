import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "status", "messageList"]
  static values = {
    messageId: Number,
    currentUserId: Number,
    mentorshipRequestId: Number
  }

  connect() {
    this.observerOptions = {
      root: null,
      rootMargin: '0px',
      threshold: 0.5
    }

    this.intersectionObserver = new IntersectionObserver(
      this.handleIntersection.bind(this),
      this.observerOptions
    )

    // Start observing all message elements for read status
    this.observeMessages()

    console.log("✨ Message status controller connected - tracking read status! ✨")
  }

  disconnect() {
    if (this.intersectionObserver) {
      this.intersectionObserver.disconnect()
    }
  }

  // Observe messages for viewport visibility to auto-mark as read
  observeMessages() {
    this.messageTargets.forEach(message => {
      const messageId = message.dataset.messageId
      const senderId = message.dataset.senderId

      // Only observe messages from other users (not current user's messages)
      if (parseInt(senderId) !== this.currentUserIdValue) {
        this.intersectionObserver.observe(message)
      }
    })
  }

  // Handle message entering/leaving viewport
  handleIntersection(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const messageElement = entry.target
        const messageId = parseInt(messageElement.dataset.messageId)
        const isRead = messageElement.dataset.isRead === 'true'

        // Auto-mark as read when message becomes visible and isn't already read
        if (!isRead) {
          this.markMessageAsRead(messageId, messageElement)
        }
      }
    })
  }

  // Mark a specific message as read
  async markMessageAsRead(messageId, messageElement) {
    try {
      const response = await fetch(`/api/messages/${messageId}/mark_read`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        }
      })

      const data = await response.json()

      if (data.success) {
        // Update the message element
        this.updateMessageReadStatus(messageElement, data.read_at)

        // Stop observing this message since it's now read
        this.intersectionObserver.unobserve(messageElement)
      }
    } catch (error) {
      console.error('Error marking message as read:', error)
    }
  }

  // Update message visual status with beautiful animation
  updateMessageReadStatus(messageElement, readAt) {
    const statusElement = messageElement.querySelector('[data-message-status-target="status"]')

    if (statusElement) {
      // Mark as read in data attributes
      messageElement.dataset.isRead = 'true'
      messageElement.dataset.readAt = readAt

      // Add beautiful read indicator with smooth animation
      statusElement.innerHTML = `
        <div class="flex items-center space-x-1 opacity-0 animate-fade-in">
          <svg class="w-4 h-4 text-green-500" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
          </svg>
          <span class="text-xs text-gray-500 font-medium">Read</span>
        </div>
      `

      // Add smooth color transition to the entire message
      messageElement.classList.add('transition-colors', 'duration-500')
      requestAnimationFrame(() => {
        messageElement.classList.add('bg-green-50', 'bg-opacity-30')
      })

      // Remove the highlight after a brief moment
      setTimeout(() => {
        messageElement.classList.remove('bg-green-50', 'bg-opacity-30')
      }, 2000)
    }
  }

  // Handle bulk marking messages as read (e.g., when conversation is opened)
  async markAllAsRead() {
    try {
      const response = await fetch('/api/messages/bulk_mark_read', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        },
        body: JSON.stringify({
          mentorship_request_id: this.mentorshipRequestIdValue
        })
      })

      const data = await response.json()

      if (data.success) {
        // Update all unread messages visually
        this.messageTargets.forEach(messageElement => {
          const isRead = messageElement.dataset.isRead === 'true'
          if (!isRead) {
            this.updateMessageReadStatus(messageElement, new Date().toISOString())
            this.intersectionObserver.unobserve(messageElement)
          }
        })

        this.showBulkReadNotification(data.marked_count)
      }
    } catch (error) {
      console.error('Error marking all messages as read:', error)
    }
  }

  // Show beautiful notification when bulk marking as read
  showBulkReadNotification(count) {
    if (count === 0) return

    const notification = document.createElement('div')
    notification.className = `
      fixed top-4 right-4 z-50 px-6 py-3 bg-gradient-to-r from-green-500 to-emerald-500
      text-white rounded-lg shadow-lg transform translate-x-full transition-transform duration-300 ease-out
    `
    notification.innerHTML = `
      <div class="flex items-center space-x-2">
        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
        </svg>
        <span class="font-medium">${count} message${count > 1 ? 's' : ''} marked as read</span>
      </div>
    `

    document.body.appendChild(notification)

    // Animate in
    requestAnimationFrame(() => {
      notification.classList.remove('translate-x-full')
    })

    // Auto-hide after 3 seconds
    setTimeout(() => {
      notification.classList.add('translate-x-full')
      setTimeout(() => notification.remove(), 300)
    }, 3000)
  }

  // Update message status from WebSocket (called by chat channel)
  updateFromWebSocket(data) {
    const { message_id, status, read_at, user_id } = data

    // Don't update status for current user's own messages
    if (user_id === this.currentUserIdValue) return

    const messageElement = this.messageTargets.find(
      el => parseInt(el.dataset.messageId) === message_id
    )

    if (messageElement && status === 'read' && read_at) {
      this.updateMessageReadStatus(messageElement, read_at)
    }
  }

  // Show sent indicator with beautiful animation (for current user's messages)
  showSentIndicator(messageElement) {
    const statusElement = messageElement.querySelector('[data-message-status-target="status"]')

    if (statusElement) {
      statusElement.innerHTML = `
        <div class="flex items-center space-x-1 opacity-0 animate-fade-in">
          <svg class="w-4 h-4 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
          </svg>
          <span class="text-xs text-gray-500 font-medium">Sent</span>
        </div>
      `

      // Add subtle pulse animation
      statusElement.classList.add('animate-pulse')
      setTimeout(() => {
        statusElement.classList.remove('animate-pulse')
      }, 1000)
    }
  }

  // Handle message delivery confirmation
  handleMessageDelivered(messageId) {
    const messageElement = this.messageTargets.find(
      el => parseInt(el.dataset.messageId) === messageId
    )

    if (messageElement) {
      this.showSentIndicator(messageElement)
    }
  }

  // Utility methods
  getCSRFToken() {
    return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
  }

  // Action to manually mark all as read (can be triggered by button click)
  markAllRead(event) {
    event.preventDefault()
    this.markAllAsRead()
  }
}