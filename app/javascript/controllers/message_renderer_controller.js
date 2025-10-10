import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.styleMessage()
  }

  render() {
    // Called when turbo stream renders this message
    setTimeout(() => this.styleMessage(), 10)
  }

  styleMessage() {
    const senderId = parseInt(this.element.dataset.senderId)
    const currentUserId = this.getCurrentUserId()
    const isMine = senderId === currentUserId

    const inner = this.element.querySelector('.message-inner')
    const bubble = this.element.querySelector('.bubble')
    const avatarContainer = this.element.querySelector('.avatar-container')
    const senderName = this.element.querySelector('.sender-name')
    const timestamp = this.element.querySelector('.timestamp')
    const timeAgo = this.element.querySelector('.time-ago')
    const messageText = this.element.querySelector('.message-text')
    const statusIndicator = this.element.querySelector('.status-indicator')

    if (isMine) {
      // Style as "sent" message (right-aligned, blue)
      inner.classList.add('flex', 'justify-end')
      inner.querySelector('.flex').classList.add('flex-row-reverse')
      
      bubble.classList.add('bg-gradient-to-br', 'from-blue-600', 'to-blue-700', 'text-white')
      senderName.classList.add('text-blue-100')
      timestamp.classList.add('text-blue-200')
      timeAgo.classList.add('text-blue-200')
      messageText.classList.add('text-white')

      // Add status indicator for sent messages
      const isRead = this.element.dataset.isRead === 'true'
      const sentAt = this.element.dataset.sentAt

      if (isRead) {
        statusIndicator.innerHTML = `
          <div class="flex items-center space-x-1">
            <i class="fa-solid fa-check-double text-green-300 text-[10px]"></i>
            <span class="text-[9px] text-green-300 font-medium">Read</span>
          </div>
        `
      } else if (sentAt) {
        statusIndicator.innerHTML = `
          <div class="flex items-center space-x-1">
            <i class="fa-solid fa-check text-blue-300 text-[10px]"></i>
            <span class="text-[9px] text-blue-300 font-medium">Sent</span>
          </div>
        `
      } else {
        statusIndicator.innerHTML = `
          <div class="flex items-center space-x-1">
            <i class="fa-solid fa-clock text-blue-300 text-[10px]"></i>
            <span class="text-[9px] text-blue-300 font-medium">Sending...</span>
          </div>
        `
      }
    } else {
      // Style as "received" message (left-aligned, gray)
      inner.classList.add('flex', 'justify-start')
      
      bubble.classList.add('bg-gradient-to-br', 'from-zinc-700', 'to-zinc-800', 'ring-1', 'ring-zinc-600', 'text-zinc-100')
      senderName.classList.add('text-zinc-300')
      timestamp.classList.add('text-zinc-400')
      timeAgo.classList.add('text-zinc-400')
      messageText.classList.add('text-zinc-100')
    }
  }

  getCurrentUserId() {
    // Get current user ID from the chat connection controller
    const chatController = document.querySelector('[data-chat-connection-current-user-id-value]')
    return chatController ? parseInt(chatController.dataset.chatConnectionCurrentUserIdValue) : null
  }
}

