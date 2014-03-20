'use strict'

Controller = require('controllers/base/controller')

News = require 'models/news'
NewsList = require 'models/news_list'
Pager = require 'models/pager'

NewsView = require('views/news/item')
NewsListView = require 'views/news/list'
# PagerView = require 'views/news/pager'

SiteView = require "views/site-view"

module.exports = class NewsController extends Controller

  initialize: ->
    @reuse 'site', SiteView
    console.log "NewsController#initialize ... reuse site"

  list: (params, route) ->
    @pager = new Pager()
    @collection = new NewsList()
    @collection.pager = @pager
    # @pageView = new PagerView(model: @pager)

    @view = new NewsListView( collection: @collection)
    @collection.fetch().then =>
      console.log "news list fetched"
      # @view.render()

  show: (params, route) ->
    @model = new News(link: params.link)
    @view = new BooksView( model: @model, autoRender: false, containerMethod: "html" )

    # rivets.bind(@view.$el,{book: @model})
    @model.fetch().then =>
      # @view.render()
      console.log "book#show done:", @model.attributes
      setInterval =>
          @model.fetch()  #self.emit 'tick'
        , 5000