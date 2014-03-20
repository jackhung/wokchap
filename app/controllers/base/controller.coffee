'use strict'

module.exports = class Controller extends Chaplin.Controller
  beforeAction: (params, route) ->
    # if route.controller in ['news', 'site']
    #   @reuse 'site', ThreePaneView
    #   @reuse 'header', ->
    #     @view = new InfoView region: 'header', name: 'header'
    #   @reuse 'footer', ->
    #     @view = new InfoView region: 'footer', name: 'footer'