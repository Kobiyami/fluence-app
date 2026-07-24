import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel"]
  static values = { studentId: Number }

  connect() {
    const saved = localStorage.getItem(`stats_tab_${this.studentIdValue}`) || "fluence"
    this.activate(saved)
  }

  switch(event) {
    const tab = event.currentTarget.dataset.tab
    localStorage.setItem(`stats_tab_${this.studentIdValue}`, tab)
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