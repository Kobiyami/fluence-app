import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["word", "timerFill", "sessionTimerFill", "progress", "done"]
  static values = { words: Array, sessionDuration: Number, studentId: Number }

  async connect() {
    this.index = 0
    this.pendingUploads = []
    this.results = []

    this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })

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

    this.currentWord = current
    this.startRecordingCurrentWord()

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

  startRecordingCurrentWord() {
    this.currentChunks = []
    this.currentRecorder = new MediaRecorder(this.stream)
    this.currentRecorder.ondataavailable = e => this.currentChunks.push(e.data)
    this.currentRecorder.start()
  }

  stopRecordingAndUpload(word) {
    if (!this.currentRecorder || this.currentRecorder.state === "inactive") return

    const recorder = this.currentRecorder
    const chunks = this.currentChunks

    const uploadPromise = new Promise((resolve) => {
      recorder.onstop = () => {
        const blob = new Blob(chunks, { type: "audio/webm" })
        const formData = new FormData()
        formData.append("audio", blob, "word.webm")
        formData.append("student_id", this.studentIdValue)
        formData.append("mot_outil_id", word.id)

        fetch("/mots_outils/transcribe_word", {
          method: "POST",
          headers: { "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content },
          body: formData
        })
          .then(r => r.json())
          .then(data => { this.results.push(data); resolve() })
          .catch(() => resolve())
      }
    })

    recorder.stop()
    this.pendingUploads.push(uploadPromise)
  }

  nextWord() {
    this.stopRecordingAndUpload(this.currentWord)

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

    if (this.currentRecorder && this.currentRecorder.state !== "inactive") {
      this.stopRecordingAndUpload(this.currentWord)
    }

    this.wordTarget.parentElement.style.display = "none"
    this.element.querySelectorAll(".word-timer-track").forEach(el => el.style.display = "none")
    this.progressTarget.style.display = "none"
    this.doneTarget.style.display = "block"
    this.doneTarget.innerHTML = "<p>Analyse en cours…</p>"

    Promise.all(this.pendingUploads).then(() => this.showSummary())
  }

  showSummary() {
    const wrongWords = this.results.filter(r => !r.correct)

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