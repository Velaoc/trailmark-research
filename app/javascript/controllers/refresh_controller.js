import { Controller } from "@hotwired/stimulus"

// Reloads the page on an interval while a research run is active, so the
// timeline stays live without a websocket. Stops the moment the run is no
// longer marked running (the server redirects/reloads a finished page).
export default class extends Controller {
  static values = { interval: { type: Number, default: 2000 } }

  connect() {
    this.timer = setInterval(() => {
      if (document.hidden) return
      this.element.dataset.refreshing = "true"
      window.Turbo.visit(window.location.href, { action: "replace" })
    }, this.intervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }
}
