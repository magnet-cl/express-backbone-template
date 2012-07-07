### This file defines the express server.

To server the content this server: 
  * Uses ejs for templates.
  * Uses Less for css
  * connect-assets to compile coffescript and manage js and dependencies
  * adds a compiler of ejs to jst for backbone templates

###

# Module dependencies.
express = require("express")
routes = require("./routes")
assets = require("connect-assets")
ejs = require("ejs")
path = require("path")

# Server creation
app = module.exports = express.createServer()

# set up some configuration variables:
publicDir = __dirname + "/public"
srcDir = __dirname + "/assets"

#### Add a ejs to jst compiler to connect-assets

# First we define a new compile method since the one in ejs does not work
# in the client side
ejsCompile = (filename, source)->
  input = JSON.stringify(source)
  str = [
    "function(locals){",
    "var __stack = { lineno: 1, input: #{input}, filename: '#{filename}' };",
    ejs.parse(source),
    "}"
  ].join("\n")
  return str

# Now we attach the ejs coipler to connect-assets
assets.jsCompilers.ejs =
  match: /\.jst.ejs$/
  compileSync: (sourcePath, source) ->
    fileName = path.basename(sourcePath, ".jst.ejs")
    folderName = (path.dirname(sourcePath)).replace(srcDir + "/templates", "")
    jstPath = (if folderName then "#{folderName}/#{fileName}" else fileName)
    str = ["(function() {",
      "this.JST || (this.JST = {});",
      "this.JST['" + jstPath + "'] = " + (ejsCompile(jstPath, source)),
      "}).call(this);"
    ].join("\n")

# Configuration
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "ejs"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session(secret: "your secret here")
  app.use app.router
  app.use express.static(publicDir)
  app.use assets(
    src: srcDir
    buildDir: 'public'
  )

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()

# Routes
app.get "/", routes.index

# listen to the 3000 port
app.listen 3000, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
