'use strict'

Controller = require('controllers/base/controller')

News = require 'models/news'
NewsList = require 'models/news_list'

NewsView = require('views/news/item')
NewsListView = require 'views/news/list'

SiteView = require "views/site-view"

module.exports = class NewsController extends Controller

  initialize: ->
    @reuse 'site', SiteView
    console.log "NewsController#initialize ... reuse site"

  list: () ->
    @collection = new NewsList()
    @view = new NewsListView( collection: @collection, model: @collection.pageInfo)
    @collection.fetch().then =>
      console.log "news list fetched"
      @view.render()

  show: (params) ->
    @model = new News(code: params.code)
    @view = new BooksView( model: @model, autoRender: false, containerMethod: "html" )

    # rivets.bind(@view.$el,{book: @model})
    @model.fetch().then =>
      # @view.render()
      console.log "book#show done:", @model.attributes
      setInterval =>
          @model.fetch()  #self.emit 'tick'
        , 5000