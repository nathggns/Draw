store = 
  data: []
  store: ->
    if window.localStorage then localStorage else store.data
  set: (name, val) ->
    store.store()[name] = val
  get: (name) ->
    store.store()[name]

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

id = store.get('id') or Math.floor Math.random() * 10000

socket.emit 'info',
  id: id

events =
  canvas: false
  mousedown: (e) ->
    e.preventDefault()

    emit {}, 'drawDown'
    store.set 'down', true

    events.draw e, this

  mouseout: (e) ->
    store.set 'down', false
    emit {}, 'drawDown'

  mousemove: (e) ->
    if store.get('down') != 'true'
      return true

    events.draw e, this

  mouseup: (e) ->
    e.preventDefault()
    store.set 'down', false

  draw: (e) ->
    emit  
      e:
        pageX: e.pageX
        pageY: e.pageY
      , 'draw'



datas = []

dataHandlers =
  'drawDown': (value) ->
    store.set 'started', false
  'opts': (value) ->
    for key, val of value
      events.canvas.ctx[key] = val
  'join': (value) ->
    for key, ev of value
      dataHandlers[ev.type] ev.value
  'draw': (value) ->
    e = value.e
    pos = lib.findPos events.canvas
    mpos = 
      left: e.pageX - pos.left
      top: e.pageY - pos.top

    ctx = events.canvas.ctx

    if store.get('started') != 'true'
      ctx.beginPath()
      ctx.moveTo mpos.left, mpos.top
      store.set 'started', true
    else
      ctx.lineTo mpos.left, mpos.top
      ctx.stroke()

socket.on 'join', (data) ->
  socket.emit 'data', 
    uniqId: data.id,
    value: datas
    type: 'join'

socket.on 'data', (data) -> 

  if !data.uniqId and data.id != id
    return false

  datas.push data
  dataHandlers[data.type] data.value;

  

$ = (id) ->
  document.getElementById id


document.addEventListener 'DOMContentLoaded', ->
  changeCode = (code) ->
    datas = []
    events.canvas.ctx.clearRect 0, 0, events.canvas.width, events.canvas.height
    code = parseInt code
    id = code
    store.set 'id', id
    socket.emit 'info', 
      id: id
    $change.value = code;

  $change = $ 'change'

  for e in ['keydown', 'keyup', 'keypress']
    $change.addEventListener e, () ->
      changeCode this.value


  $canvas = document.createElement 'canvas'
  ctx = $canvas.ctx = $canvas.getContext('2d')
  events.canvas = $canvas

  for key, func of events
    $canvas.addEventListener key, func

  document.body.addEventListener 'mouseup', (e) ->
    if store.get('down') == 'true'
      events.mouseup.call $canvas, e

  document.body.appendChild $canvas

  changeCode id

  window.changeCode = changeCode

  window.emit = (message, type = 'message') ->
    socket.emit 'data', 
      id: id,
      type: type,
      value: message