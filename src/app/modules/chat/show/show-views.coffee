# Show Views
#
# Defines all views used on the "show" action of the
# `Chat` module.
@App.module "ChatModule.Show", (Show, App, Backbone, Marionette, $, _) ->

  # ## Layout
  #
  # Defines two regions for this module:
  #
  # * `messageBoxRegion`: will hold the message box
  # * `messagesRegion`: will hold the `Messages` list
  class Show.Layout extends App.Views.Layout
    template: "chat/show/layout"
    regions:
      messageBoxRegion: "#message-box"
      messagesRegion: "#messages"


  # ## ChatView
  #
  # Renders the chat section of the app. It extends
  # from App's base ItemView (which extends Marionette.ItemView)
  class Show.MessageBoxView extends App.Views.ItemView
    template: "chat/show/box"
    ui:
      submit: "input[id='send-message']"
      message: "input[id='message-input']"
    initialize:->
      App.reqres.setHandler "nest:initialized", (id) ->
        submitButton = $("input[id='send-message'")
        submitButton.val 'Submit'
        submitButton.prop "disabled", false
    events:

      "click @ui.submit": (e) ->
        e.preventDefault()
        message = @ui.message.val()
        if not message
          return false

        @ui.message.val ''
        morse = morjs.encode message
        msgEntity = App.request("message:add", { 'message': message, 'morse': morse, 'status': 'sending'})
        @sendMessage msgEntity

    increaseTime: ->
      @timeout += 1000 # give time for termostat to change value

    sendSignal: (temp_diff)->
      scale = App.thermostat.temperature_scale
      plus = if scale == 'F' then +temp_diff*2 else +temp_diff
      _this = this
      setTimeout (->
        _this.adjustTemperature plus, scale
      ), @timeout
      @increaseTime()
      minus = if scale == 'F' then -temp_diff*2 else -temp_diff
      setTimeout (->
        _this.adjustTemperature minus, scale
      ), @timeout

    sendDash:->
      @sendSignal(2)

    sendDot: ->
      @sendSignal(1)

    finsihMessage: (msgEntity) ->
      @messasge_status = 0
      msgEntity.set 'status', 'sent'

    sendMessage: (msgEntity)->
      if @message_status == 1
        msgEntity.set 'status', 'failed'
        return
      @messasge_status = 1
      # send message to nest termostat
      i = 0
      morse = msgEntity.get('morse')
      len = morse.length
      @timeout = 500 # start in .5 sec
      while i < len
        switch morse[i]
          when ' '
            #just wait 1 sec more;
            @increaseTime()
          when '·'
            # dot is +1 -1
            @sendDot()
          when '-'
            # dash is +2 -2
            @sendDash()
          else
            console.log('corrupted letter: ' + morse[i])
        @increaseTime()
        i++

      _this = this
      setTimeout (->
        _this.finsihMessage msgEntity
      ), @timeout



    ###*
    Updates the thermostat's target temperature
    by the specified number of degrees in the
    specified scale. If a type is specified, it
    will be used to set just that target temperature
    type
    @method
    @param Number degrees
    @param String temperature scale
    @param String type, high or low. Used in heat-cool mode (optional)
    @returns undefined
    ###

    adjustTemperature: (degrees, scale, type) ->
      scale = scale.toLowerCase()
      type = if type then type + '_' else ''
      newTemp = App.thermostat['target_temperature_' + scale] + degrees
      path = 'devices/thermostats/' + App.thermostat.device_id + '/target_temperature_' + type + scale
      if App.thermostat.is_using_emergency_heat
        console.error 'Can\'t adjust target temperature while using emergency heat.'
      else if App.thermostat.hvac_mode == 'heat-cool' and !type
        console.error 'Can\'t adjust target temperature while in Heat • Cool mode, use target_temperature_high/low instead.'
      else if type and App.thermostat.hvac_mode != 'heat-cool'
        console.error 'Can\'t adjust target temperature ' + type + ' while in ' + App.thermostat.hvac_mode + ' mode, use target_temperature instead.'
      else if App.structure.away.indexOf('away') > -1
        console.error 'Can\'t adjust target temperature while structure is set to Away or Auto-away.'
      else
    # ok to set target temperature
        App.dataRef.child(path).set newTemp
      return

  # ## MessageView
  #
  class Show.MessageView extends App.Views.ItemView
    tagName: "li"
    template: "chat/show/message-item"
    modelEvents:
      "change": "modelChange"

    modelChange: () ->
      console.log this.model
      @render()


  # ## MessagesView
  #
  class Show.MessagesView extends App.Views.CompositeView
    childView: Show.MessageView
    childViewContainer: "ul"
    template: "chat/show/message-list"
    collectionEvents:
      "add": "itemAdded",
      "change": "itemChanged"

    itemAdded: () ->
      console.log('Item Added');

    itemChanged: () ->
      console.log("Changed Item!");




