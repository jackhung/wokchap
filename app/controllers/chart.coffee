'use strict'

Controller = require('controllers/base/controller')
ChartView = require('views/chart')
Book = require 'models/book'
SiteView = require "views/site-view"

module.exports = class ChartController extends Controller

  initialize: ->
    @reuse 'site', SiteView
    console.log "ChartController#initialize ... reuse site"

  show: (params) ->
    @model = new Book(code: params.code)
    @view = new ChartView( model: @model, autoRender: false, containerMethod: "html" )

    @model.fetch().then =>
      console.debug "chart#fetched:", @model.attributes
      @ticker = setInterval =>
          console.error "model is undefined!!" if not @model
          @model.fetch()  #self.emit 'tick'
        , 5000

  dispose: () ->
    clearInterval @ticker
    super