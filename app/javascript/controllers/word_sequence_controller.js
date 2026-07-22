import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["word", "timerFill", "sessionTimerFill", "progress", "done"]
  static values = { words: Array, sessionDuration: Number, studentId: Number }

  async connect() {
    this.index = 0
    this.timings = []
    this.audioChunks = []
    this.currentWordRecorded = true

    this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })
    this.mediaRecorder = new MediaRecorder(this.stream)
    this.mediaRecorder.ondataavailable = e => this.audioChunks.push(e.data)
    this.mediaRecorder.onstop = () => this.submitResults()

    await new Promise(resolve => {
  this.mediaRecorder.onstart = () => { this.recordingStart = performance.now(); resolve() }
  this.mediaRecorder.start()
})

this.sessionStart = performance.now()
this.startSessionTimer()
this.playCurrent()
  }

  startSessionTimer() {
    this.sessionTimerFillTarget.style.transition = `width ${this.sessionDurationValue}s linear`
    void this.sessionTimerFillTarget.offsetWidth
    this.sessionTimerFillTarget.style.width = "0%"

    this.sessionTimeout = setTimeout(() => this.finish(), this.sessionDurationValue * 1000)
  }

  elapsedSeconds() {
    return (performance.now() - this.sessionStart) / 1000
  }

  playCurrent() {
    if (this.index >= this.wordsValue.length) {
      this.finish()
      return
    }

    const current = this.wordsValue[this.index]
    const remaining = this.sessionDurationValue - this.elapsedSeconds()

    if (remaining < current.allowed_time) {
      this.finish()
      return
    }

    this.currentWordStart = (performance.now() - this.recordingStart) / 1000
    this.currentWordRecorded = false

    this.progressTarget.textContent = `Mot ${this.index + 1}`

    this.wordTarget.textContent = current.text
    this.wordTarget.classList.remove("word-slide-in", "word-slide-out")
    void this.wordTarget.offsetWidth
    this.wordTarget.classList.add("word-slide-in")

    this.timerFillTarget.style.transition = "none"
    this.timerFillTarget.style.width = "100%"
    void this.timerFillTarget.offsetWidth
    this.timerFillTarget.style.transition = `width ${current.allowed_time}s linear`
    this.timerFillTarget.style.width = "0%"

    this.timeout = setTimeout(() => this.nextWord(), current.allowed_time * 1000)
  }

  nextWord() {
    const currentEnd = (performance.now() - this.recordingStart) / 1000
    const current = this.wordsValue[this.index]

    this.timings.push({
      mot_outil_id: current.id,
      text: current.text,
      start: this.currentWordStart,
      end: currentEnd
    })
    this.currentWordRecorded = true

    this.wordTarget.classList.remove("word-slide-in")
    this.wordTarget.classList.add("word-slide-out")

    setTimeout(() => {
      this.index += 1
      this.playCurrent()
    }, 300)
  }

  finish() {
    if (this.timeout) clearTimeout(this.timeout)
    if (this.sessionTimeout) clearTimeout(this.sessionTimeout)

    if (this.currentWordStart !== undefined && !this.currentWordRecorded) {
      const currentEnd = (performance.now() - this.recordingStart) / 1000
      const current = this.wordsValue[this.index]
      this.timings.push({ mot_outil_id: current.id, text: current.text, start: this.currentWordStart, end: currentEnd })
      this.currentWordRecorded = true
    }

    this.wordTarget.parentElement.style.display = "none"
    this.element.querySelectorAll(".word-timer-track").forEach(el => el.style.display = "none")
    this.progressTarget.style.display = "none"
    this.doneTarget.style.display = "block"
    this.doneTarget.innerHTML = "<p>Analyse en cours…</p>"

    if (this.mediaRecorder && this.mediaRecorder.state !== "inactive") {
      this.mediaRecorder.stop()
    } else {
      this.submitResults()
    }
  }

  submitResults() {
    const blob = new Blob(this.audioChunks, { type: "audio/webm" })
    const reader = new FileReader()
    reader.onloadend = () => {
      fetch("/mots_outils/finish", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          student_id: this.studentIdValue,
          audio_file: reader.result,
          word_timings: this.timings
        })
      })
        .then(r => r.json())
        .then(data => this.showSummary(data))
    }
    reader.readAsDataURL(blob)
  }

  showSummary(data) {
    const wrongWords = data.results.filter(r => !r.correct)

    let wordsHtml = ""
    if (wrongWords.length > 0) {
      wordsHtml = `
        <p class="word-progress">À revoir :</p>
        <ul class="word-review-list">
          ${wrongWords.map(w => `
            <li>
              <span>${w.text}</span>
              <button type="button" class="btn-listen" data-word="${w.text}">
                <i class="ti ti-volume"></i> Écouter
              </button>
            </li>
          `).join("")}
        </ul>
      `
    }

    this.doneTarget.innerHTML = `
      <i class="ti ti-check"></i>
      <p>Séquence terminée !</p>
      ${wordsHtml}
      <a href="/students/${this.studentIdValue}" class="btn-reading btn-reading--start">Retour au profil</a>
    `

    this.doneTarget.querySelectorAll(".btn-listen").forEach(btn => {
      btn.addEventListener("click", () => {
        const audio = new Audio(`/mots_outils/pronounce?text=${encodeURIComponent(btn.dataset.word)}`)
        audio.play()
      })
    })
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
    if (this.sessionTimeout) clearTimeout(this.sessionTimeout)
    if (this.stream) this.stream.getTracks().forEach(t => t.stop())
  }
}