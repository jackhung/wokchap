'use strict'

View = require('views/base/view')
SimpleGraph = require "views/chart/simple-graph"
VolumeGraph = require "views/chart/volume-graph"
# SimpleGraphOrig = require "views/chart/js-simple-graph"
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

  createGraphs: =>
    console.debug "ChartView#createCandleGraph: ", $('#candle-graph')
    @candleGraph = new SimpleGraph
      el: '#candle-graph' 

    @volumeGraph = new VolumeGraph
      el: '#volume-graph'
      xaxis: false
      zoomable: false

    @priceData = new PriceData 
      stkCode: @model.get('code')
    @priceData.doFetch().then =>
      console.log ".............. fetched"
      @candleGraph.onPriceData @priceData
      @candleGraph.resetZoom()
      @volumeGraph.onPriceData @priceData
      @volumeGraph.resetZoom()

    @subscribeEvent 'zoomed', @zoomed

  listen: 
    "change model" : "updateChart"
    # "sync model" : "updateChart"

  updateChart: ->
    attrs = @model.attributes
    @candleGraph?.updateQuote attrs
    @volumeGraph?.updateQuote attrs
    now = moment().format("hh:mm")
    $("#page-head-cotainer").html "#{attrs.close} #{attrs.ask} #{attrs.bid}<br> #{attrs.volume} #{now}"


  zoomed: (domain) ->
    console.debug "Somebody zoomed:", arguments
    @candleGraph.zoomHandler domain
    @volumeGraph.zoomHandler domain

  render: ->
    super
    console.debug @model.attributes, @candleGraph
    _.defer @createGraphs unless @candleGraph

  dispose: ->
    console.log "ChartView#dispose"
    super




