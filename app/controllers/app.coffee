'use strict'

Controller = require('controllers/base/controller')
IndexView = require('views/index')
SiteView = require "views/site-view"

module.exports = class AppController extends Controller

  initialize: ->
    @reuse 'site', SiteView
    console.log "AppController#initialize"

  index: ->
    @view = new IndexView
