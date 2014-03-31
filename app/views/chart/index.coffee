'use strict'

View = require('views/base/view')
SimpleGraph = require "views/chart/simple-graph"
SimpleGraphOrig = require "views/chart/js-simple-graph"
PriceData = require "views/chart/stock-price-service"

module.exports = class ChartView extends View
  className: 'chart-view'
  container: '#content-container'
  template: require('./template')

  defaults: 
    height: 200;

  initialize: ->
    super
    console.log "ChartView#initialize ... #{@model.get('code')}"

  createCandleGraph: =>
    console.debug "ChartView#createCandleGraph: ", $('#candle-graph')
    @candleGraph = new SimpleGraph 'candle-graph',

    @priceData = new PriceData 
      stkCode: @model.get('code')
    @priceData.doFetch().then =>
      console.log ".............. fetched"
      @candleGraph.onPriceData @priceData
      @candleGraph.resetZoom()

  listen: 
    "change model" : "updateChart"
    # "sync model" : "updateChart"

  updateChart: ->
    @candleGraph?.updateQuote @model.attributes

  render: ->
    super
    console.debug @model.attributes, @candleGraph
    _.defer @createCandleGraph unless @candleGraph

  dispose: ->
    console.log "ChartView#dispose"
    super




