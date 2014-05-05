define [ 'app' ], (App) ->

  App.module 'Footerbar', (exports) ->

    class ItemView extends Backbone.Marionette.ItemView
      debug: new App.Debug 'footerbarView'
      template: '#template_footerbar'
      className: 'footerbar'

      onRender: ->
        @debug 'onRender'

    exports.view = new ItemView()


  return App
