# # Auth Module
#
# Handle auth on start of application
@App.module "AuthModule", (ChatModule, App, Backbone, Marionette, $, _) ->


  # ##Initializer
  #
  # Adds an initializer which will be executed when the module is started.
  # This initializer will execute the `show()` API method, since it is
  # the action we want to perform when the module is started
  ChatModule.addInitializer ->
    App.reqres.setHandler "nest:auth", (id) ->
      nestToken = Cookies.get('nest_token')
      App.thermostat = {}
      App.structure = {}

      if nestToken
      # Simple check for token
      # Create a reference to the API using the provided token
        App.dataRef = new Firebase('ws://developer-api.nest.com')
        App.dataRef.authWithCustomToken nestToken
      # in a production client we would want to
      # handle auth errors here.
      else
      # No auth token, go get one
        window.location.replace App.request("app:option", "backend")  + '/auth/nest'

      # updating thermostat data
      App.dataRef.on 'value', (snapshot) ->
        data = snapshot.val()
        # For simplicity, we only care about the first
        # thermostat in the first structure
        App.structure = data.structures[Object.keys(data.structures)[0]]
        App.thermostat = data.devices.thermostats[App.structure.thermostats[0]]
        # TAH-361, device_id does not match the device's path ID
        App.thermostat.device_id = App.structure.thermostats[0]
        App.request("nest:initialized")