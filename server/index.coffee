express = require('express')
http = require('http')
path = require('path')
setupPrerender = require('./prerender')
setupRoutes = require('./routes')

exports.startServer = (port, publicPath, callback) ->
  app = express()

  # Uncomment to use Prerender
  setupPrerender(app)

  # Point to generated static files
  app.use(express.static(publicPath))

  # Uncomment to append custom routes/services/proxies/etc.
  # setupRoutes(app)

  # Set other paths to index.html for HTML5 pushState apps
  indexPath = path.resolve(publicPath, 'index.html')
  app.get '*', (request, response) ->
    response.sendfile(indexPath)

  # Start up server
  server = http.createServer(app)
  server.listen(port, callback)
  server
