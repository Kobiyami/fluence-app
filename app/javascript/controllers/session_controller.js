import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timer", "duration", "aborted", "stopButton"]

  connect() {
    this.speechStarted = false
    this.startTime = null
    this.timerInterval = null
    this.audioChunks = []
  }

  async startRecording() {
    this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })
    this.mediaRecorder = new MediaRecorder(this.stream)

    this.mediaRecorder.ondataavailable = e => this.audioChunks.push(e.data)
    this.mediaRecorder.onstop = () => this.handleAudioStop()

    this.setupSpeechRecognition()
    this.startListening()
    this.startNoSpeechTimeout()

    document.getElementById("start-button").disabled = true
    document.getElementById("stop-button").disabled = false
    document.getElementById("status").textContent = "Parle quand tu es prêt…"
  }

  setupSpeechRecognition() {
    const SR = window.SpeechRecognition || window.webkitSpeechRecognition
    this.recognition = new SR()
    this.recognition.continuous = true
    this.recognition.interimResults = true
    this.recognition.lang = "fr-FR"

    this.recognition.onspeechstart = () => this.handleSpeechStart()
  }

  startListening() {
    try { this.recognition.start() } catch (e) {}
  }

  startNoSpeechTimeout() {
    this.noSpeechTimeout = setTimeout(() => {
      if (!this.speechStarted) {
        this.forceAbort("Tu n'as pas commencé à lire.")
      }
    }, 10000)
  }

  handleSpeechStart() {
  if (this.speechStarted) return
  this.speechStarted = true
  clearTimeout(this.noSpeechTimeout)
  this.startTime = performance.now()
  this.mediaRecorder.start()
  document.getElementById("status").textContent = "Enregistrement en cours…"

  // ✅ Afficher le bouton Terminer
  document.getElementById("finish-button").style.display = "inline-block"

  this.timerInterval = setInterval(() => {
    const elapsed = Math.floor((performance.now() - this.startTime) / 1000)
    this.timerTarget.textContent = elapsed
    this.durationTarget.value = elapsed
  }, 200)

  setTimeout(() => this.autoStop(), 60000)
}

manualStop() {
  this.abortedTarget.value = "true"
  document.getElementById("status").textContent = "Tu as interrompu la lecture."
  if (this.timerInterval) clearInterval(this.timerInterval)
  try { this.recognition.stop() } catch (e) {}
  // ✅ Stoppe le micro ET déclenche handleAudioStop() immédiatement
  if (this.mediaRecorder && this.mediaRecorder.state !== "inactive") {
    this.mediaRecorder.stop()
  } else {
    document.getElementById("stop-form").submit()
  }
}

finishManually() {
  this.abortedTarget.value = "false"
  document.getElementById("status").textContent = "Lecture terminée, envoi…"
  if (this.timerInterval) clearInterval(this.timerInterval)
  try { this.recognition.stop() } catch (e) {}
  // ✅ Stoppe le micro et déclenche handleAudioStop()
  if (this.mediaRecorder && this.mediaRecorder.state !== "inactive") {
    this.mediaRecorder.stop()
  }
}

  autoStop() {
    this.abortedTarget.value = false
    this.stop()
  }
  
  handleAudioStop() {
  const aborted = this.abortedTarget.value === "true"

  document.getElementById("status").textContent = aborted
    ? "Abandon enregistré, redirection…"
    : "⏳ Transcription en cours, merci de patienter…"

  // désactiver tous les boutons pour éviter un double submit
  document.getElementById("start-button").disabled = true
  document.getElementById("stop-button").disabled = true
  document.getElementById("finish-button").disabled = true

  if (aborted) {
    document.getElementById("stop-form").submit()
    return
  }

  const blob = new Blob(this.audioChunks, { type: "audio/webm" })
  const reader = new FileReader()
  reader.onloadend = () => {
    document.getElementById("audio-file-field").value = reader.result
    document.getElementById("stop-form").submit()
  }
  reader.readAsDataURL(blob)
}

forceAbort(message) {
  this.abortedTarget.value = true

  // Affiche un message visible dans la page
  const status = document.getElementById("status")
  status.textContent = message

  // Réinitialise immédiatement l'UI
  this.resetUI()

  // Soumet après 2 secondes
  setTimeout(() => {
    document.getElementById("stop-form").submit()
  }, 2000)
}

resetUI() {
  // Boutons
  document.getElementById("start-button").disabled = false
  document.getElementById("stop-button").disabled = true
  document.getElementById("finish-button").style.display = "none"

  // Timer
  this.timerTarget.textContent = "0"
  this.durationTarget.value = 0

  // État interne
  this.speechStarted = false
  this.audioChunks = []

  // Nettoyage des timers
  if (this.timerInterval) clearInterval(this.timerInterval)
  if (this.noSpeechTimeout) clearTimeout(this.noSpeechTimeout)

  // Stoppe proprement les API
  try { this.recognition.stop() } catch (e) {}
  try { this.mediaRecorder.stop() } catch (e) {}
}

stop(message = null) {
  if (message) {
    document.getElementById("status").textContent = message
  }

  if (this.timerInterval) clearInterval(this.timerInterval)
  try { this.recognition.stop() } catch (e) {}

  // Si abandon → pas d’audio → on laisse forceAbort() gérer la soumission
  if (this.abortedTarget.value === "true") {
    return
  }

  // Sinon transcription normale
  this.mediaRecorder.stop()
}

}
