lib =
  findPos: (ele) ->
    left = top = 0

    if (ele.offsetParent)
      loop
        left += ele.offsetLeft;
        top += ele.offsetTop;
        break if not (ele = ele.offsetParent)

    top: top
    left: left


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

  changeCode = (code) ->
    id = code
    $qr.setAttribute 'src', 'http://qr.kaywa.com/img.php?s=8&d=' + code
    $change.value = code;

    ctx.clearRect $canvas.width, $canvas.height

  $qr = $ 'qrcode'
  $change = $ 'change'
  $canvas = document.createElement 'canvas';
  $canvas.width = $canvas.height = 300;
  document.body.appendChild $canvas
  ctx = $canvas.getContext "2d"

  dataHandlers['draw'] = (point) ->
    ctx.beginPath()
    ctx.fillStyle = '#000000'
    ctx.rect point.left, point.top, 10, 10
    ctx.fill()

  $canvas.addEventListener 'mousedown', (e) ->
    e.preventDefault()
    this.setAttribute 'data-down', true

  $canvas.addEventListener 'mouseup', (e) ->
    e.preventDefault()
    this.setAttribute 'data-down', false

  $canvas.addEventListener 'mousemove', (e) ->
    e.preventDefault()

    if this.getAttribute('data-down') == 'true'

      cPos = lib.findPos $canvas

      socket.emit 'data',
        id: id
        type: 'draw',
        value:
          top: e.pageY - cPos.top,
          left: e.pageX - cPos.left


  changeCode id

  $change.addEventListener 'keypress', (e) ->
      if e.which == 13
        changeCode this.value
