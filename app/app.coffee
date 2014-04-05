'use strict'

routes = require('routes')
utils = require('lib/utils')
Layout = require 'views/layout'
User = require 'models/user'

defaultOptions = {routes, controllerSuffix: ''}

module.exports = class Application extends Chaplin.Application

  constructor: (options) ->
    super utils.extend({}, defaultOptions, options)

  initLayout: (options) ->
    @layout = new Layout options

  initMediator: ->
    Chaplin.mediator.user = new User
    super
