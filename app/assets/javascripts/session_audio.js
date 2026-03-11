let mediaRecorder;
let chunks = [];

document.addEventListener("DOMContentLoaded", () => {
  const startBtn = document.getElementById("start-record");
  const stopBtn = document.getElementById("stop-record");
  const status = document.getElementById("audio-status");
  const result = document.getElementById("transcription");

  if (!startBtn) return; // sécurité si on n'est pas sur la page START

  startBtn.onclick = async () => {
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    mediaRecorder = new MediaRecorder(stream);

    chunks = [];
    mediaRecorder.ondataavailable = e => chunks.push(e.data);

    mediaRecorder.onstop = () => {
      const blob = new Blob(chunks, { type: "audio/wav" });
      uploadRecording(blob);
    };

    result.textContent = "";
    mediaRecorder.start();
    status.textContent = "Enregistrement en cours…";
    stopBtn.disabled = false;
  };

  stopBtn.onclick = () => {
    mediaRecorder.stop();
    status.textContent = "Traitement…";
    stopBtn.disabled = true;
  };

  function uploadRecording(blob) {
    const formData = new FormData();
    formData.append("audio", blob, "lecture.wav");

    fetch("/transcriptions", {
      method: "POST",
      body: formData
    })
      .then(r => r.json())
      .then(data => {
        console.log("Réponse Whisper :", data);
  if (data.error) {
    status.textContent = "Erreur de transcription";
    result.textContent = "";
    return;
  }

  status.textContent = "Transcription terminée";
  result.textContent = data.text;
});

  }
});
