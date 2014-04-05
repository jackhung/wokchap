'use strict'

View = require 'views/base/view'
template = require './site'
mediator = Chaplin.mediator

# Site view is a top-level view which is bound to body.
module.exports = class ThreePaneView extends View
  id: 'site-pane-view'
  region: 'main'
  regions:
    header: '#header-container'
    content: '#content'
    footer: '#footer-container'

    pageHeader0: "#page-head-container-l1"
    pageHeader1: "#page-head-container-l2"
    pageHeader2: "#page-head-container-r1"
    pageHeader3: "#page-head-container-r2"
  template: template

  listen:
    "change mediator.user": "updateUser"  #will not work since mediator is not a property of this

  render: ->
    super
    @afterRender()

  afterRender: ->
    @listenTo mediator.user, "change", @updateUser
    mediator.user.fetch().then (resp) ->
      console.debug "user fetched: ", resp
    , (resp) ->
      console.debug "user fetch failed: ", resp
      mediator.user.set "userId", null


  updateUser: ->
    u = mediator.user.attributes
    console.debug "User is now: ", u.userId
    if u.userId
      @$("#app-username").html(u.displayName)
      @$("#app-signin").hide()
      @$("#app-signout").show()
    else
      @$("#app-username").html("Login")
      @$("#app-signin").show()
      @$("#app-signout").hide()