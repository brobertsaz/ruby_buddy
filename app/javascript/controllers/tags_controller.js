import { Controller } from "@hotwired/stimulus"

// Tags controller
// - Manages a tag list UI (pills) backed by a hidden comma-separated input
// - Add a tag with Enter or comma, or by leaving the field (blur)
// - Remove tags with the close button
//
// HTML API
// <div data-controller="tags">
//   <div data-tags-target="list"></div>
//   <input data-tags-target="input" data-action="keydown->tags#keydown blur->tags#commit">
//   <input type="hidden" data-tags-target="hidden" name="profile[skills]">
// </div>
export default class extends Controller {
  static targets = ["input", "hidden", "list"]

  connect() {
    this.tags = []
    this._loadFromHidden()
    this._render()
  }

  keydown(event) {
    const isEnter = event.key === "Enter"
    const isComma = event.key === ","
    if (isEnter || isComma) {
      event.preventDefault()
      this.commit()
    }
  }

  commit() {
    const raw = (this.inputTarget.value || "").replace(/,{2,}/g, ",")
    const tokens = raw.split(/[,\n]/).map(t => this._normalize(t)).filter(Boolean)
    tokens.forEach(t => this._addTag(t))
    this.inputTarget.value = ""
    this._syncHidden()
    this._render()
  }

  remove(event) {
    const idx = Number(event.currentTarget?.dataset.index)
    if (Number.isFinite(idx)) {
      this.tags.splice(idx, 1)
      this._syncHidden()
      this._render()
    }
  }

  // Private
  _normalize(t) {
    return (t || "").trim().replace(/\s+/g, " ")
  }

  _addTag(tag) {
    if (!tag) return
    const exists = this.tags.some(t => t.toLowerCase() === tag.toLowerCase())
    if (exists) return
    // Soft length limit to keep UI tidy
    if (this.tags.length >= 24) return
    this.tags.push(tag)
  }

  _loadFromHidden() {
    const value = this.hiddenTarget?.value || ""
    value.split(",").map(t => this._normalize(t)).filter(Boolean).forEach(t => this._addTag(t))
  }

  _syncHidden() {
    if (this.hiddenTarget) {
      this.hiddenTarget.value = this.tags.join(", ")
    }
  }

  _render() {
    if (!this.hasListTarget) return
    this.listTarget.innerHTML = ""
    this.tags.forEach((tag, i) => {
      const el = document.createElement("span")
      el.className = "inline-flex items-center gap-1 rounded-full bg-rose-600/90 text-white text-xs px-2 py-1 shadow-sm"
      el.innerHTML = `${this._escape(tag)} <button type="button" class="ml-1 inline-grid place-items-center w-4 h-4 rounded-full bg-white/20 hover:bg-white/30" aria-label="Remove" data-action="click->tags#remove" data-index="${i}">×</button>`
      this.listTarget.appendChild(el)
    })
  }

  _escape(s) {
    const div = document.createElement("div")
    div.textContent = s
    return div.innerHTML
  }
}

