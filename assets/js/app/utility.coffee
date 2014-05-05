define [
  'app'
  'backbone'
  'backbone.stickit'
], (App, Backbone) ->

  debugConsoleCalled = 0

  class App.Debug

    production: /glide\.so/.test window.location.hostname

    colors: [
      '#2B8694'
      '#8FB320'
      '#CEB124'
      '#76B3CE'
      '#C7A0D4'
      '#C45744'
    ]

    constructor: (label) ->
      unless @production
        color = @colors[debugConsoleCalled++ % @colors.length]
        debug = console.debug || console.log
        error = console.error || console.log
        return ->
          args = Array::slice.call arguments
          args = ["%c#{label}", "color:#{color}"].concat args
          if 0 < (_.filter args, (arg) -> arg instanceof Error).length
            args = _.map args, (arg) ->
              return arg unless arg instanceof Error
              return arg.stack || arg.message
            return error.apply console, args
          debug.apply console, args
      return -> return


  class App.Model extends Backbone.Model
    getters: {}
    setters: {}

    get: (key) ->
      return @getters[key].call this if _.isFunction @getters[key]
      return Backbone.Model::get.call this, key

    set: (key, val, opt = {}) ->
      if (_.isNull key) or (_.isObject key)
        [attrs, opt] = [key, val]
      else
        (attrs = {})[key] = val
      for attr of attrs when _.isFunction @setters[attr]
        attrs[attr] = @setters[attr].call this, attrs[attr], opt
      return Backbone.Model::set.call this, attrs, opt

    virtuals: no

    toJSON: ->
      attrs = super
      return attrs unless @virtuals
      for target in _.difference (_.keys @getters), (_.keys attrs)
        if _.isFunction @getters[target]
          attrs[target] = @getters[target].call this
      return attrs

    increment: (key) ->
      if _.isNumber val = @get key
        return @set key, val + 1
      return @set key, val

    decrement: (key) ->
      if _.isNumber val = @get key
        return @set key, val - 1
      return @set key, val


  class App.Collection extends Backbone.Collection


  return App
