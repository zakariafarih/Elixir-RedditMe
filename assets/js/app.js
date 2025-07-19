// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Import our custom markdown editor
import "./markdown_editor"

// LiveView hooks
let Hooks = {}

Hooks.CommentForm = {
  mounted() {
    console.log("CommentForm hook mounted")
    
    // Listen for the clear form event
    this.handleEvent("clear-comment-form", () => {
      console.log("Received clear-comment-form event")
      const textarea = this.el.querySelector('textarea[name="comment[body]"]')
      if (textarea) {
        console.log("Clearing textarea, current value:", textarea.value)
        textarea.value = ''
        textarea.focus()
        // Trigger input event to ensure LiveView knows the value changed
        textarea.dispatchEvent(new Event('input', { bubbles: true }))
        console.log("Textarea cleared")
      } else {
        console.log("Textarea not found")
      }
    })
  },
  
  updated() {
    console.log("CommentForm updated")
    // Force clear the textarea if it still has content after a successful submission
    const textarea = this.el.querySelector('textarea[name="comment[body]"]')
    if (textarea && textarea.value.trim() !== '') {
      // Check if there's a success flash message, which indicates successful submission
      const flashMessages = document.querySelectorAll('[data-phx-flash]')
      const hasSuccessMessage = Array.from(flashMessages).some(msg => 
        msg.textContent.includes('Comment added!')
      )
      
      if (hasSuccessMessage) {
        console.log("Success message detected, clearing textarea")
        textarea.value = ''
        textarea.focus()
        textarea.dispatchEvent(new Event('input', { bubbles: true }))
      }
    }
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

