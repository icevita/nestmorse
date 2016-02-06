# # Show Controller
#
# This controller will handle everything related to the "show"
# action of the `Chat` module.
@App.module "ChatModule.Show", (Show, App, Backbone, Marionette, $, _) ->

  # Extends `App.Controllers.Application`, which in the end
  # is nothing but a custom extension of `Marionette.Controller`.
  class Show.Controller extends App.Controllers.Application

    # ##  Initialize
    #
    # Shows an instance of a `Show.ChatView` on the
    # module default region, which is `App.ChatRegion`
    # as it was passed on the instantiation of the Controller
    # on [ChatModule](../chat.html#show)
    initialize: ->

    # Instantiates the `LayoutView`
      @layout = @getLayoutView()

      @messages = App.request "message:entities"

      # When the layout is shown, the `FilterRegion`
      # and the `ContentRegion` are set up
      @listenTo @layout, "show", =>
        @handleMessageBoxRegion()
        @handleMessagesRegion()

      # Shows the `LayoutView`
      @show @layout

    #
    # Shows a `messageBoxView` on the `messageBoxRegion` of the `LayoutView`,
    # handling all the events produced by the view.
    handleMessageBoxRegion: ->

      # Instances the `MessageBoxView`
      messageBoxView = @getMessageBoxView()

      # Shows the `messageBoxView` on the `messageBoxRegion` of the `LayoutView`.
      @show messageBoxView, region: @layout.messageBoxRegion

    #
    # Shows a `messagesView` on the `messagesRegion` of the `LayoutView`,
    # handling all the events produced by the view.
    handleMessagesRegion: ->

      # Instances the `MessageBoxView`
      messagesView = @getMessagesView()

      # Shows the `messagesView` on the `messagesRegion` of the `LayoutView`.
      @show messagesView, region: @layout.messagesRegion

    # ## getLayoutView
    #
    # Returns a new instance of a `LayoutView`
    getLayoutView: ->
      new Show.Layout()

    # ## getMessageBoxView
    #
    # Creates and return a new instance of `Show.MessageBoxView`
    getMessageBoxView: ->
      new Show.MessageBoxView()

    # ## getMessagesView
    #
    # Creates and return a new instance of `Show.MessagesView`
    getMessagesView: ->
      new Show.MessagesView
        collection: @messages
