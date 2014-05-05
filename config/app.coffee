'use strict'

path = require 'path'
http = require 'http'
express = require 'express'
session = require 'express-session'
passport = require 'passport'
mongoose = require 'mongoose'
direquire = require 'direquire'

pkg = require path.resolve 'package.json'
app = module.exports = express()

RedisStore = (require 'connect-redis')(session)
mongoose.connect "mongodb://localhost/#{pkg.name}"

app.set 'models', direquire path.resolve 'models'
app.set 'views', path.resolve 'views'
app.set 'view engine', 'jade'
app.use (require 'serve-favicon')(path.resolve('assets', 'favicon.ico'))
app.use express.static path.resolve 'public'
if 'test' isnt process.env.NODE_ENV
  app.use (require 'morgan')('dev')
app.use (require 'body-parser')()
app.use (require 'method-override')()
app.use (require 'cookie-parser')()
app.use session
  store: new RedisStore prefix: "sess:#{pkg.name}:"
  secret: process.env.SESSION_SECRET
  cookie: expires: no
app.use passport.initialize()
app.use passport.session()
app.use (require 'connect-stream')('.')
app.use (req, res, next) ->
  app.locals.req = req
  return next null

(require path.resolve 'config', 'session')(app)
(require path.resolve 'config', 'routes')(app)
(require path.resolve 'config', 'engine')(app)

if 'production' isnt process.env.NODE_ENV
  app.get /^\/assets\/.*?/, (req, res) ->
    res.stream req.url

app.get '*', (req, res, next) ->
  res.render 'index'
