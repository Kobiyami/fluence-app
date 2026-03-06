import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timer", "duration", "aborted", "stopButton"]

  connect() {
    console.log("SESSION CONTROLLER CONNECTÉ");

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
    try {
      this.recognition.start()
    } catch (e) {
      console.warn("SpeechRecognition start error:", e)
    }
  }

  startNoSpeechTimeout() {
    this.noSpeechTimeout = setTimeout(() => {
      if (!this.speechStarted) {
        this.stop()
        this.abortedTarget.value = true
        this.stopButtonTarget.click()
      }
    }, 10000)
  }

  handleSpeechStart() {
    console.log("🎤 Speech detected !");
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
      this.stop()
      this.stopButtonTarget.click()
    }, 60000)
  }

  stop() {
    if (this.timerInterval) clearInterval(this.timerInterval)

    if (this.recognition) {
      try {
        this.recognition.stop()
      } catch (e) {
        console.warn("SpeechRecognition stop error:", e)
      }
    }
  }

  disconnect() {
    if (this.timerInterval) clearInterval(this.timerInterval)
    if (this.noSpeechTimeout) clearTimeout(this.noSpeechTimeout)

    if (this.recognition) {
      try {
        this.recognition.stop()
      } catch (e) {}
    }
  }
}
