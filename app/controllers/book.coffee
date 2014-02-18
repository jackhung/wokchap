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
    @model = new Book(code: '00175')
    @model.fetch()
    @view = new BooksView( model: @model )

    # rivets.bind(@view.$el,{book: @model});
    console.log "book#show done: #{@view.$el}"