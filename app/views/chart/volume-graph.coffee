'use strict'

ChartOptions = require 'views/chart/chart-options'
ChartView = require 'views/chart/base-chart'

module.exports = class VolumeGraph extends ChartView

  initialize: (options) ->
    super
    selected: null

  # Real Stock Data ==============================================================
  onPriceData: (priceData) =>
    @model = priceData
    @pData = priceData.get("priceData")
    # x-scale
    @x = d3.scale.linear()
        .domain([0, @pData.length])
        .range([0, @size.width]);

    @ymin = d3.min @pData, (d) => d[@PVOL]
    @ymax = d3.max @pData, (d) => d[@PVOL]
    # y-scale (inverted domain)
    @y = d3.scale.linear()
        .domain([@ymax, @ymin])
        .range([0, @size.height])
        .nice();

    # @initChartElements()
    @renderAxis()

  # ================================================================================

  updateChart: () =>
    @drawBar()

  drawBar: ->
    rectWidth = Math.abs(@x(1) - @x(0) ) * 0.6

    @bars = @vis.select("svg").selectAll(".volume-bar").data(@pData)
    @bars
      .enter().append("rect")
      .attr("class", "volume-bar")
      .attr("x", -rectWidth/2)
      .attr("y", (d) => @y( d[@PVOL]))
      .attr("width", rectWidth)
      .attr "height", (d, i) => 
        @size.height - @y(d[@PVOL])
      .classed("down", (d) => d[@PCLOSE] < d[@POPEN])
      .on("mouseover", (d,i) -> console.log "#{i}: ", d)
    @bars
      .attr("x", -rectWidth/2)
      .attr("y", (d) => @y( d[@PVOL]))
      .attr("width", rectWidth)
      .attr "height", (d, i) => 
        @size.height - @y(d[@PVOL])

    @bars.exit().remove()
    @bars .transition() .duration(100) .attr("transform", (d, i) => "translate(#{@x(i)}, 0)")

  yaxis_drag: (d) =>
    document.onselectstart = () -> false
    p = d3.mouse @plotArea()
    @downy = @y.invert(p[1]);

  getDataIndex: (cx) ->
    Math.floor(@x.invert(cx) + 0.5)

  yAxisLabel: () =>
    (d) => f = d3.formatPrefix(d); "#{f.scale(d)}#{f.symbol}"

  visibleYExtend: -> 
    [first, last] = @x.domain()
    first = Math.floor first
    last = Math.floor last
    first = 0 if first < 0
    last = @pData.length if last > @pData.length

    ylow = Number.MAX_VALUE
    yhigh = Number.MIN_VALUE
    for i in [first...last]
      d = @pData[i]
      ylow = d[@PVOL] if d[@PVOL] < ylow
      yhigh = d[@PVOL] if d[@PVOL] > yhigh
    [yhigh * 1.01, ylow * 0.99] # NOTE: inverted order max, min!

# registerKeyboardHandler = (callback) ->
#   callback = callback
#   d3.select(window).on("keydown", callback)