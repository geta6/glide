_ = require 'lodash'
debug = require('debug')('glide:model:user')
mongoose = require 'mongoose'

UserModel = new mongoose.Schema
  id: type: Number, unique: yes
  name: type: String
  icon: type: String
  token: type: String
,
  autoIndex: no
  versionKey: no

UserModel.statics.findOrCreate = (json, token, callback) ->
  @findOne id: json.id, (err, user) =>
    return callback err if err
    user or= new @ id: json.id
    user = _.extend user,
      name: json.name
      icon: json.avatar_url
      token: token
    return user.save callback

exports.User = mongoose.model 'users', UserModel
