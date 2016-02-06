# # Message Entity
#

@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # ## Message Model
  #
  # Represents a single Message. Each of them should have a `message` an `morse`
  # and a `status`
  class Entities.Message extends Entities.Model

  # ## Muppets Collection
  #
  # Represents a group of Muppets.
  class Entities.Messages extends Entities.Collection
    model: Entities.Message

  messageArray = new Entities.Messages()

  # ## API
  #
  # Holds the methods to work with the Entity.
  API =
    getMessage: (id) ->
      data = _.find array, (item) ->
        return item.id is +id

      return new Entities.Message data

    addMessage: (msg) ->
      msg['id'] = messageArray.length
      messageArray.unshift(new Entities.Message(msg))
      return messageArray.first()

    getMessages: ->
      return messageArray

  # ## Requests

  # Returns a Model instance with given `id`.
  App.reqres.setHandler "message:entity", (id) ->
    API.getMessage id if id

  # Returns a Collection instance holding all the Models.
  App.reqres.setHandler "message:entities", ->
    API.getMessages()

  App.reqres.setHandler "message:add", (msg) ->
    return API.addMessage(msg)