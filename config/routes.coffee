_ = require 'lodash'
passport = require 'passport'

module.exports = (app) ->

  {User} = app.get 'models'

  app.get '/users/:id?', (req, res) ->
    switch yes
      when not req.accepts 'json'
        res.send 406
      when req.params.id?
        User.findOne(id: req.params.id).lean().exec (err, user) ->
          return res.json 500, err if err
          res.json 200, _.omit user, [ 'token' ]
      when req.isAuthenticated()
        User.findOne(id: req.user.id).lean().exec (err, user) ->
          return res.json 500, err if err
          res.json 200, _.omit user, [ 'token' ]
      else
        res.send 400
