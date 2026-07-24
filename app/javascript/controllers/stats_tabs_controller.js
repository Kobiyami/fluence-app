import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel"]
  static values = { storageKey: String, default: String }

  connect() {
    const saved = localStorage.getItem(this.storageKeyValue) || this.defaultValue || "fluence"
    this.activate(saved)
  }

  switch(event) {
    const tab = event.currentTarget.dataset.tab
    localStorage.setItem(this.storageKeyValue, tab)
    this.activate(tab)
  }

  activate(tab) {
    this.buttonTargets.forEach(btn => {
      btn.classList.toggle("tab-button--active", btn.dataset.tab === tab)
    })
    this.panelTargets.forEach(panel => {
      panel.style.display = panel.dataset.tabPanel === tab ? "block" : "none"
    })
  }
}