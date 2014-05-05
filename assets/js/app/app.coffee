define [
  'backbone'
  'backbone.marionette'
], (Backbone) ->

  App = new Backbone.Marionette.Application()

  App.addRegions
    HeaderbarRegion: '.headerbar_container'
    GlideareaRegion: '.glidearea_container'
    FooterbarRegion: '.footerbar_container'

  App.addInitializer ->
    # App.HeaderbarRegion.show App.Headerbar.view
    App.GlideareaRegion.show App.Glidearea.view
    App.FooterbarRegion.show App.Footerbar.view

  return App
