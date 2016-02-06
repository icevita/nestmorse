# Navigation Utils
#
# All utils related to navigation.
@App.module "Utilities", (Utilities, App, Backbone, Marionette, $, _) ->

  _.extend App,

    # Set an autoInitHistory to true if not defined
    autoInitHistory: App.autoInitHistory or true

    # Methot to perform a navigation on the `Backbone.history`
    navigate: (route, options = {}) ->
      Backbone.history.navigate route, options

    # Get the current route on the `Backbone.history`
    getCurrentRoute: ->
      frag = Backbone.history.fragment
      if _.isEmpty(frag) then null else frag

    # Starts the `Backbone.history`
    startHistory: ->
      Backbone.history.start() if Backbone.history

    authUser: ->
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
          window.location.replace App.BACKEND_URL + '/auth/nest'

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

  if App.autoInitHistory
    App.on "start", ->
      # TODO: move to global config
      App.BACKEND_URL = 'http://localhost:8080'

      @authUser()

      # Starts the Backbone History
      @startHistory()

      # Navigate to the `rootRoute` of the application if there is not an active
      # route
      @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()

