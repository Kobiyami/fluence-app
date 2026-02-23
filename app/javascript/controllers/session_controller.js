import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timer", "duration", "aborted", "stopButton"]

  connect() {
    this.startTime = null
    this.timerInterval = null
    this.speechStarted = false

    this.setupSpeechRecognition()
    this.startListening()
    this.startNoSpeechTimeout()
  }

  setupSpeechRecognition() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    this.recognition = new SpeechRecognition()

    this.recognition.continuous = true
    this.recognition.interimResults = true
    this.recognition.lang = "fr-FR"

    this.recognition.onspeechstart = () => this.handleSpeechStart()
  }

  startListening() {
    this.recognition.start()
  }

  startNoSpeechTimeout() {
    this.noSpeechTimeout = setTimeout(() => {
      if (!this.speechStarted) {
        this.abortedTarget.value = true
        this.stopButtonTarget.click()
      }
    }, 10000)
  }

  handleSpeechStart() {
    if (this.speechStarted) return

    this.speechStarted = true
    clearTimeout(this.noSpeechTimeout)

    this.startTime = performance.now()

    this.timerInterval = setInterval(() => {
      const elapsed = Math.floor((performance.now() - this.startTime) / 1000)
      this.timerTarget.textContent = elapsed
      this.durationTarget.value = elapsed
    }, 200)

    setTimeout(() => {
      this.recognition.stop()
      this.stopButtonTarget.click()
    }, 60000)
  }

  stop() {
    this.recognition.stop()
    clearInterval(this.timerInterval)
  }
}