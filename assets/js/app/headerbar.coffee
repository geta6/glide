define [ 'app' ], (App) ->

  App.module 'Headerbar', (exports) ->

    class Model extends App.Model
      url: '/users'
      defaults:
        id: null
        name: null
        icon: null


    class ItemView extends Backbone.Marionette.ItemView
      debug: new App.Debug 'headerbarView'
      template: '#template_headerbar'
      className: 'headerbar'
      ui:
        search: '.circle_find'
      events:
        'mouseenter @ui.search': 'onMouseEnterSearch'

      modelEvents:
        'change': 'render'

      onRender: ->
        @debug 'onRender'

      onClose: ->
        @debug 'onClose'

      onMouseEnterSearch: ->
        _.defer =>
          @debug 'onMouseEnterSearch'
          @ui.search.find('#search').focus()


    exports.on 'start', ->
      App.HeaderbarRegion.show new ItemView
        model: model = new Model()
      model.fetch()


  return App
