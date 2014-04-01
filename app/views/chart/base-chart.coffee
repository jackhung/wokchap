View = require 'views/base/view'

module.exports = class BaseChart extends View

  defaults:
    xaxis: true

  initialize: (options)->
    super
    @chart = @el
    @$chart = $(@el)
    @cx = @$chart.width()
    @cy = @$chart.height()
    @options = {}
    _.extend @options, @defaults, options

    @padding = 
      top:    if @options.title  then 40 else 5
      right:                 30
      bottom: if @options.xlabel then 60 else 35
      left:   if @options.ylabel then 70 else 45

    @options.zoomable = true unless @options.zoomable?

    @size = {
      "width":  @cx - @padding.left - @padding.right,
      "height": @cy - @padding.top  - @padding.bottom
    };

    @initChartElements()

  initChartElements: () ->
    throw "Already initialized error!" if $(@chart).find('svg').length

    @svg = d3.select(@chart).append("svg") .attr("width",  @cx) .attr("height", @cy)

    @bgPane = @svg.append("g")
          .attr("class", "plot-background")
          .attr("transform", "translate(" + @padding.left + "," + @padding.top + ")")
    @bgPane.append("rect") .attr("width", @size.width) .attr("height", @size.height)

    # vis is the 'g' element
    @vis = @svg.append("g")
          .attr("class", "plot-area")
          .attr("transform", "translate(" + @padding.left + "," + @padding.top + ")")

    # plot: the plot area for the data
    @plot = @vis.append("rect") .attr("width", @size.width) .attr("height", @size.height)
        .style("fill", "none")
        .attr("pointer-events", "all")
        .on("mousedown.drag", @plot_drag)
        .on("touchstart.drag", @plot_drag)

    # the line path, class='line'
    @vis.append("svg")
        .attr("top", 0) .attr("left", 0) .attr("width", @size.width) .attr("height", @size.height)
        .attr("viewBox", "0 0 "+@size.width+" "+@size.height)
        .attr("class", "line")

    
    # add Chart Title
    if (@options.title)
      @vis.append("text") .attr("class", "axis") .text(@options.title) .attr("x", @size.width/2)
          .attr("dy","-0.8em") .style("text-anchor","middle")

    # Add the x-axis label
    if (@options.xlabel) 
      @vis.append("text") .attr("class", "axis") .text(@options.xlabel) .attr("x", @size.width/2) .attr("y", @size.height)
          .attr("dy","2.4em")
          .style("text-anchor","middle");

    # add y-axis label
    if (@options.ylabel) 
      @vis.append("g").append("text") .attr("class", "axis") .text(@options.ylabel) .style("text-anchor","middle")
          .attr("transform","translate(" + -40 + " " + @size.height/2+") rotate(-90)");

    d3.select(@chart)
        .on("mousemove.drag", @mousemove)
        .on("touchmove.drag", @mousemove)
        .on("mouseup.drag",   @mouseup)
        .on("touchend.drag",  @mouseup)

  renderAxis: () =>
    tx = (d) => "translate(#{@x(d)},0)"
    ty = (d) => "translate(0,#{@y(d)})"
    stroke = (d) -> if d then "#aaa" else "#666"
    fx = @x.tickFormat(8)
    fy = @y.tickFormat(10)
    xtext = (i) => if i >= @pData.length or i < 0 then "-" else moment(@pData[+i][0]).format("MMM-DD")

    # Regenerate x-ticks
    gx = @bgPane.selectAll("g.x") .data(@x.ticks(10), String) .attr("transform", tx)
    
    gxe = gx.enter().insert("g", "a") .attr("class", "x") .attr("transform", tx)
    gxe.append("line") .attr("stroke", stroke) .attr("y1", 0) .attr("y2", @size.height)
    if @options.xaxis
      gxe.append("text") .attr("class", "axis")
          .attr("y", @size.height) .attr("dy", "1em")
          .attr("text-anchor", "middle")
          .text(xtext)
          .style("cursor", "ew-resize")
          .on("mouseover", (d) -> d3.select(this).style("font-weight", "bold"))
          .on("mouseout",  (d) -> d3.select(this).style("font-weight", "normal"))
          .on("mousedown.drag",  @xaxis_drag)
          .on("touchstart.drag", @xaxis_drag);
      gx.select("text") .text(xtext)
    gx.exit().remove();

    # Regenerate y-ticks…
    gy = @bgPane.selectAll("g.y") .data(@y.ticks(8), String) .attr("transform", ty)
    # gy.select("text") .text(fy)
    gye = gy.enter().insert("g", "a") .attr("class", "y") .attr("transform", ty) .attr("background-fill", "#FFEEB6")
    gye.append("line") .attr("stroke", stroke) .attr("x1", 0) .attr("x2", @size.width)
    gye.append("text") .attr("class", "axis")
        .attr("x", @size.width + 20) .attr("dy", ".35em")
        .attr("text-anchor", "end")
        .text(@yAxisLabel())
        .style("cursor", "ns-resize")
        .on("mouseover", (d) -> d3.select(this).style("font-weight", "bold"))
        .on("mouseout",  (d) -> d3.select(this).style("font-weight", "normal"))
        .on("mousedown.drag",  @yaxis_drag)
        .on("touchstart.drag", @yaxis_drag)
    gy.exit().remove();

    if @options.zoomable
      @zoom = d3.behavior.zoom().x(@x).on("zoom", @zoomHandler)
      @plot.call(@zoom)
    @updateChart();

  yAxisLabel: =>
    @y.tickFormat(10)

  zoomHandler: ->
    console.error "Subclass should override zoomHandler()!!"