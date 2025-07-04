import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

const speakEasyModal = document.getElementById('speakEasySecretEntrance')
const speakEasyInput = document.getElementById('secretEntranceAnswer')

speakEasyModal.addEventListener('shown.bs.modal', () => {
  speakEasyInput.focus()
})