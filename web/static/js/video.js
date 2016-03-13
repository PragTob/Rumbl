import Player from "./player"

let Video = {
  init(socket, element) {
    if(!element) { return }
    let playerId = element.getAttribute("data-player-id")
    let videoId  = element.getAttribute("data-id")
    socket.connect()
    Player.init(element.id, playerId, () => {
      this.onReady(videoId, socket)
    })
  },

onReady(videoId, socket) {
    console.log("On Ready!")
    let msgContainer = document.getElementById("msg-container")
    let msgInput     = document.getElementById("msg-input")
    let postButton   = document.getElementById("msg-submit")
    let vidChannel   = socket.channel("videos:" + videoId)

    msgContainer.addEventListener("click", (event) => {
      event.preventDefault()
      let seconds = event.target.getAttribute("data-seek") ||
                    event.target.parentNode.getAttribute("data-seek")
      if(!seconds) { return }

      Player.seekTo(seconds)
    })

    postButton.addEventListener("click", (event) => {
      console.log("clickety click")
      let payload = {body: msgInput.value, at: Player.getCurrentTime()}
      vidChannel.push("new_annotation", payload)
                .receive("error", (error) => console.log(error))
      msgInput.value = ""
    })

    vidChannel.on("new_annotation", (response) => {
      vidChannel.params.last_seen_id = response.id
      this.renderAnnotation(msgContainer, response)
    })

    vidChannel.join()
      .receive("ok", ({annotations}) => {
        let ids = annotations.map((annotation) => annotation.id)
        vidChannel.params.last_seen_id = Math.max(...ids)
        this.scheduleMessages(msgContainer, annotations)
      })
      .receive("error", (reason) => console.log("failed to join the channel", reason))
  },

  renderAnnotation(msgContainer, {user, body, at}) {
    let template = document.createElement("div")
    template.innerHTML = `
      <a href="#" data-seek="${this.escape(at)}">
        [${this.formatTime(at)}]
        <strong>${this.escape(user.username)}</strong>: ${this.escape(body)}
      </a>
      `
    msgContainer.appendChild(template)
    msgContainer.scrollTop = msgContainer.scrollHeight
  },

  scheduleMessages(msgContainer, annotations) {
    setTimeout(() => {
      let ctime = Player.getCurrentTime()
      let remaining = this.renderAtTime(annotations, ctime, msgContainer)
      this.scheduleMessages(msgContainer, remaining)
    }, 1000)
  },

  renderAtTime(annotations, seconds, msgContainer) {
    return annotations.filter ( (annotation) => {
      // TODO: untidy... filters and modifies in one loop,
      if (annotation.at > seconds) {
        return true
      } else {
        this.renderAnnotation(msgContainer, annotation)
        return false
      }
    })
  },

  formatTime(at) {
    let date = new Date(null)
    date.setSeconds(at / 1000)
    return date.toISOString().substr(14, 5)
  },

  escape(string) {
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(string))
    return div.innerHTML
  }
}
export default Video
