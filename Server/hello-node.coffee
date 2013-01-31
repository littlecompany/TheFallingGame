http = require 'http'
websocket = require 'socket.io'
fs = require 'fs'
perlin = require './perlin-noise'
xLen = 1000
yLen = 1000
console.log perlin
genMap = (x,y) ->
	z = Math.random()
	map = []
	for cy in [0..y]
		for cx in [0..x]
			map.push (perlin.noise cx / x,cy / y,z)
	map
map = genMap xLen,yLen
app = (http.createServer (req, res) ->
	console.log "http connection"
	fs.readFile __dirname + '\\index.html', (err, html) ->
		console.log "read file " + __dirname + '\\index.html'
		if err
			res.writeHead 500
			res.end "Couldn't get index..."
		else
			console.log "writing file"
			res.writeHead 200
			res.end html
).listen 80, 'localhost'

io = websocket.listen app
io.set 'log level', 1

io.sockets.on 'connection', (socket) ->
	console.log "connection"
	console.log "all clients - ", (id for id,sock of io.sockets.sockets)
	socket.emit 'news', {'hello':'world'}
	socket.emit 'map', {'xl':xLen,'yl':yLen,'map',map}
	socket.on 'my other event', (data) ->
		console.log 'received message from client ', socket.id, ' - ',data
