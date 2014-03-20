'use strict'

routes = require('routes')
utils = require('lib/utils')
Layout = require 'views/layout'

defaultOptions = {routes, controllerSuffix: ''}

module.exports = class Application extends Chaplin.Application

  constructor: (options) ->
    super utils.extend({}, defaultOptions, options)

  initLayout: (options) ->
    @layout = new Layout options
