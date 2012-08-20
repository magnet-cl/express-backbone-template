### This file defines the express server.

To server the content this server:
  * Uses jade for templates.
  * Uses Less for css
  * connect-assets to compile coffescript and manage js and dependencies

###

# Module dependencies.
express = require("express")
routes = require("./routes")
assets = require("connect-assets")
jade = require("jade")
path = require("path")
http = require('http')

# Server creation
app = module.exports = express.createServer()

# set up some configuration variables:
publicDir = __dirname + "/public"
srcDir = __dirname + "/assets"

# Now we attach the jade coipler to connect-assets
assets.jsCompilers.jade =
  match: /\.jst.jade$/
  compileSync: (sourcePath, source) ->
    fileName = path.basename(sourcePath, ".jst.jade")
    folderName = (path.dirname(sourcePath)).replace(srcDir + "/templates", "")
    jstPath = (if folderName then "#{folderName}/#{fileName}" else fileName)
    return [
      "(function() {",
      "  this.JST || (this.JST = {});",
      "  this.JST['#{jstPath}'] = #{jade.compile source, client: true}",
      "}).call(this);"
    ].join("\n")


# Configuration
app.configure ->
  app.set('port', process.env.PORT || 3000)
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use(express.favicon())
  app.use(express.logger('dev'))
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use(express.cookieParser('your secret here'))
  app.use(express.session())
  app.use app.router
  app.use(require('less-middleware')( src: publicDir))
  app.use express.static(publicDir)
  app.use assets(
    src: srcDir
    buildDir: 'public'
  )

app.configure "development", ->
  app.use(express.errorHandler())

# Routes
app.get "/", routes.index

# listen to the 3000 port
http.createServer(app).listen(app.get('port'), () ->
  console.log("Express server listening on port #{app.get('port')}")
)
