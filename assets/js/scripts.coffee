socket = io.connect 'http://localhost:3000'

id = false



socket.on 'info', (data) ->
  id = data.id

dataHandlers = {}

socket.on 'data', (data) ->
  if data.id != id
    return false

  if typeof dataHandlers[data.type] != 'undefined'
    dataHandlers[data.type] data.value, data

$ = (id) ->
  document.getElementById id

document.addEventListener 'DOMContentLoaded', ->

  if id == false
    return setTimeout arguments.callee, 1

  $qr = $ 'qrcode'
  $code = $ 'code'
  $change = $ 'change'
  $qr.setAttribute 'src', 'http://qr.kaywa.com/img.php?s=8&d=' + id
  $code.innerHTML = ' ' + id
  $messages = $ 'messages'

  dataHandlers['message'] = (value) ->
    li = document.createElement 'li'
    li.innerHTML = value
    $messages.appendChild li

  $change.addEventListener 'keydown', ->
      id = this.value

  $('message').addEventListener 'keypress', (e) ->
    if e.which == 13
      socket.emit 'data',
        type: 'message',
        value: this.value,
        id: id
