App.event_notifications = App.cable.subscriptions.create "EventNotificationsChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    $('#events').prepend(data['event']);
