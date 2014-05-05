define [ 'app' ], (App) ->

  App.module 'Glidearea', (exports) ->

    class Model extends App.Model
      virtuals: on

      defaults:
        id: i

      getters:
        thumb: ->
          return "/img/sample/thumb-#{@get 'id'}.jpg"


    class Collection extends App.Collection
      model: Model


    class ItemView extends Backbone.Marionette.ItemView
      debug: new App.Debug 'glideView'
      template: '#template_glide'
      className: 'glide'

      onRender: ->
        @debug 'onRender'


    class CompositeView extends Backbone.Marionette.CompositeView
      debug: new App.Debug 'glidesView'
      template: '#template_glides'
      className: 'glides_inside'
      itemView: ItemView
      itemViewContainer: '.glides'


    exports.collection = collection = new Collection()

    for i in [0...9]
      collection.add id: i

    exports.view = new CompositeView
      collection: collection


  return App