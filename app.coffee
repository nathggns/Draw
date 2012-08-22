
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

pairs = {}

io.set 'log level', 1

io.sockets.on 'connection', (socket) ->

  socket.emit 'info',
    id: socket.id

  socket.on 'data', (data) ->
    io.sockets.emit 'data', data


server.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
