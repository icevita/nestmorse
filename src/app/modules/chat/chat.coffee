# # Chat Module
#
# This is the main file for the `Chat` module.
@App.module "ChatModule", (ChatModule, App, Backbone, Marionette, $, _) ->

  # ## API
  #
  # Holds the methods to perform actions within the module.
  API =

    # ### Show
    #
    # Instantiates a new `Show.Controller`, with the `contentRegion`
    # of the application as the container region. The controller
    # will use this region as a rendering zone.
    show: ->
      new ChatModule.Show.Controller
        region: App.contentRegion

  # ##Initializer
  #
  # Adds an initializer which will be executed when the module is started.
  # This initializer will execute the `show()` API method, since it is
  # the action we want to perform when the module is started
  ChatModule.addInitializer ->
    API.show()
