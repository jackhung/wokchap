'use strict'

initialize = ->

  # Add Davy promises if available and we are using Exoskeleton
  if Backbone.Deferred and window.Davy
    Backbone.Deferred = -> new Davy

  # Set up Rivets if available
  if window.rivets then rivets.adapters[':'] =
    subscribe: (obj, keypath, callback) ->
      obj.on("change:#{keypath}", callback)
    unsubscribe: (obj, keypath, callback) ->
      obj.off("change:#{keypath}", callback)
    read: (obj, keypath) ->
      obj.get(keypath)
    publish: (obj, keypath, value) ->
      obj.set(keypath, value)

  # handle contextPath (hack for integrating with backend)
  config = require 'config'

  # Start application
  App = require('app')

  # adjust context path for the Application (hack for backend integrated deployment)
  rpath = config.contextRoot
  matchContext = new RegExp("^#{rpath}/|^#{rpath}$")
  window.CHAP_APP = if matchContext.test(location.pathname)
      new App
       root: config.contextRoot
    else
      new App

# Initialize the application on DOM ready event.
# Use jQuery if available. Otherwise use native.
if window.$
  $(document).ready(initialize)
else
  document.addEventListener('DOMContentLoaded', initialize)
