'use strict'

ChartOptions = require 'views/chart/chart-options'
ChartView = require 'views/chart/base-chart'

module.exports = class VolumeGraph extends ChartView

  initialize: (options) ->
    super
    selected: null

  PDATE: 0
  POPEN: 1
  PHIGH: 2
  PLOW: 3
  PCLOSE: 4
  PVOL: 5

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

  mousemove: () =>
    p = d3.mouse @plotArea() 
    t = d3.event.changedTouches
    
    if (!isNaN(@downx)) 
      d3.select('body').style("cursor", "ew-resize");
      rupx = @x.invert(p[0])
      [xaxis1, xaxis2] = @x.domain()
      xaxis1 = 0 if (xaxis1 < 0)
      xaxis2 = @pData.length if xaxis2 >= @pData.length
      xextent = xaxis2 - xaxis1
      if (xextent < 30)
        xextent = 30
      if (rupx != 0)
        #changex = @downx / rupx; ?? avoid negative x? need to varify
        changex = (@downx - xaxis1) / (rupx - xaxis1);
        new_domain = [xaxis1, xaxis1 + (xextent * changex)]
        @x.domain(new_domain);
        @renderAxis();
  
      d3.event.preventDefault();
      d3.event.stopPropagation();
    
    if (!isNaN(@downy)) 
      d3.select('body').style("cursor", "ns-resize");
      rupy = @y.invert(p[1])
      yaxis1 = @y.domain()[1]
      yaxis2 = @y.domain()[0]
      yextent = yaxis2 - yaxis1
      if (rupy != 0) 
        changey = @downy / rupy;
        new_domain = [yaxis1 + (yextent * changey), yaxis1];
        @y.domain(new_domain);
        @renderAxis();
      
      d3.event.preventDefault();
      d3.event.stopPropagation();

  mouseup: () =>
    document.onselectstart = () -> return true
    d3.select('body').style("cursor", "auto");
    if (!isNaN(@downx))
      @renderAxis();
      @downx = Math.NaN;
      d3.event.preventDefault();
      d3.event.stopPropagation();

    if (!isNaN(@downy)) 
      @renderAxis();
      @downy = Math.NaN;
      d3.event.preventDefault();
      d3.event.stopPropagation();

  xaxis_drag: () =>
    document.onselectstart = () -> false
    p = d3.mouse @plotArea()
    @downx = @x.invert(p[0]);

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
    console.log "#{first} .. #{last} max, min { #{yhigh} #{ylow}"
    [yhigh * 1.05 , ylow * 0.95 ] # NOTE: inverted order max, min!

registerKeyboardHandler = (callback) ->
  callback = callback
  d3.select(window).on("keydown", callback)