'use strict'

View = require('views/base/view')
SimpleGraph = require "views/chart/simple-graph"
SimpleGraphOrig = require "views/chart/js-simple-graph"

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
      xmax: 60, "xmin": 0
      ymax: 40, "ymin": 0 
      # title: "Simple Graph1"
      # xlabel: "X Axis"
      # ylabel: "Y Axis"  

    # @iGraph = new SimpleGraphOrig 'indicator-graph',
    #   xmax: 60, "xmin": 0
    #   ymax: 40, "ymin": 0 
    #   title: "Simple Graph1"
    #   xlabel: "X Axis"
    #   ylabel: "Y Axis" 

  listen: 
    "change model" : "render"

  render: ->
    super
    _.defer @createCandleGraph

  dispose: ->
    console.log "ChartView#dispose"
    super




