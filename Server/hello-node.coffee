http = require 'http'
websocket = require 'socket.io'
fs = require 'fs'
SimplexNoise = require 'simplex-noise'
xLen = 1000
yLen = 1000

genMap = (x,y) ->
	simplex = new SimplexNoise(Math.random)
	map = []
	for cx in [0..x - 1]
		for cy in [0..y - 1]
			noise = simplex.noise2D (cx + 100) / 100, cy / 100
			map.push noise
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
