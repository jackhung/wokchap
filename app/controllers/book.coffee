'use strict'

Controller = require('controllers/base/controller')
BooksView = require('views/book')
Book = require 'models/book'
SiteView = require "views/site-view"

module.exports = class BookController extends Controller

  initialize: ->
    @reuse 'site', SiteView
    console.log "BookController#initialize ... reuse site"

  show: (params) ->
    @model = new Book(code: params.code)
    @view = new BooksView( model: @model, autoRender: false, containerMethod: "html" )

    # rivets.bind(@view.$el,{book: @model})
    @model.fetch().then =>
      # @view.render()
      console.log "book#show done:", @model.attributes
      @ticker = setInterval =>
          console.error "model is undefined!!" if not @model
          @model.fetch()  #self.emit 'tick'
        , 5000

  dispose: () ->
    clearInterval @ticker
    super