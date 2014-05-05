passport = require 'passport'
{Strategy} = require 'passport-github'

module.exports = (app) ->

  {User} = app.get 'models'

  passport.use new Strategy
    clientID: process.env.GITHUB_CLIENT_ID
    clientSecret: process.env.GITHUB_CLIENT_SECRET
    callbackURL: process.env.GITHUB_CALLBACK_URL
  , (token, refresh, profile, done) ->
    User.findOrCreate profile._json, token, done

  passport.serializeUser (user, done) ->
    done null, user._id

  passport.deserializeUser (id, done) ->
    User.findById id, done

  app.get '/session', (req, res) ->
    if req.isAuthenticated()
      req.logout()
      return res.redirect '/'
    passport.authenticate 'github',
      failureRedirect: '/'
      successRedirect: '/'
    .apply @, arguments
