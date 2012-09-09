
###
Module dependencies.
###
express = require("express")
routes = require("./routes")
http = require("http")
path = require("path")
app = express()
app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use require('connect-assets')()
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler()

app.get "/", routes.index

server = http.createServer(app)
io = require("socket.io").listen(server)

io.set 'log level', 1

io.sockets.on 'connection', (socket) ->

  socket.on 'info', (data) ->
    socket.get 'id', (err, id) ->
      if id
        socket.leave id

      socket.set 'id', data.id
      socket.join data.id
      io.sockets.clients(data.id)[0].emit 'join',
        id: socket.id

  socket.on 'data', (data) ->

    s = if data.uniqId then io.sockets.socket(data.uniqId) else io.sockets.in(data.id)

    s.emit 'data', data


server.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
