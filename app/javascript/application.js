// Entry point for the build script in your package.json
// 🔁 Hot reload script (works even with IIFE format)
;(() =>
  (new EventSource('http://localhost:8082').onmessage = () =>
    location.reload()))()
import '@hotwired/turbo-rails'
import './controllers'

console.log('JavaScript is working!')

document.addEventListener('DOMContentLoaded', () => {
  const btn = document.getElementById('test-button')
  if (btn) {
    btn.addEventListener('click', () => {
      alert('🟢 JS works!')
    })
  }
})
