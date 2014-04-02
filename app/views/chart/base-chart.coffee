View = require 'views/base/view'

###
  subclassing BaseChart
  * plot_drag :  to enable dragging (enable modification of point in original example)
  * [x/y]axis_drag : to handle axis dradding
  * mouse move on canvas (change point value and axis-drag)
    * mousemove : handle mousemove.drag and touchmove.drag
    * mouseup : handle mouseup.drag and touchend.drag
###
module.exports = class BaseChart extends View

  PDATE: 0
  POPEN: 1
  PHIGH: 2
  PLOW: 3
  PCLOSE: 4
  PVOL: 5

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
      top:    if @options.title  then 40 else 3
      right:                 35
      bottom: if @options.xaxis && @options.xlabel then 60 else if @options.xaxis then 10 else 3
      left:   if @options.ylabel then 70 else 20

    @options.zoomable = true unless @options.zoomable?

    @size = {
      "width":  @cx - @padding.left - @padding.right,
      "height": @cy - @padding.top  - @padding.bottom
    };

    @downx = Math.NaN
    @downy = Math.NaN
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
    if @plot_drag?
      @plot.on("mousedown.drag", @plot_drag).on("touchstart.drag", @plot_drag)

    if @doHit?
      @plot.on "mousemove", () =>
        return unless @x
        p = d3.mouse @plotArea()
        x = @x.invert p[0]
        rx = Math.round x
        @doHit rx, Math.abs(x - rx)

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
      text = gxe.append("text") .attr("class", "axis")
        .attr("y", @size.height) .attr("dy", "1em")
        .attr("text-anchor", "middle")
        .text(xtext)
        .on("mouseover", (d) -> d3.select(this).style("font-weight", "bold"))
        .on("mouseout",  (d) -> d3.select(this).style("font-weight", "normal"))
      if @xaxis_drag?
        text.style("cursor", "ew-resize")
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
        .attr("x", @size.width + 2) .attr("dy", ".35em")
        # .attr("text-anchor", "end")
        .text(@yAxisLabel())
        .style("cursor", "ns-resize")
        .on("mouseover", (d) -> d3.select(this).style("font-weight", "bold"))
        .on("mouseout",  (d) -> d3.select(this).style("font-weight", "normal"))
        .on("mousedown.drag",  @yaxis_drag)
        .on("touchstart.drag", @yaxis_drag)
    gy.exit().remove();

    if @options.zoomable
      @zoom = d3.behavior.zoom().x(@x).on("zoom", @zoomed)
      @plot.call(@zoom)
    @updateChart();

  plotArea: () ->
    @vis.node() #@vis[0][0]

  yAxisLabel: =>
    @y.tickFormat(10)

  zoomHandler: (domain) =>
    # translate = d3.event.translate
    # scale = d3.event.scale
    @x.domain(domain)
    @y.domain(@visibleYExtend()).nice()
    @renderAxis()

  zoomed: () =>
    @publishEvent "zoomed", @x.domain()

  resetZoom: (p = 150) =>
    x0 = Math.max @pData.length - @pData.length * (p / @pData.length), 60
    @x.domain([x0, @pData.length])
    @y.domain(@visibleYExtend()).nice()
    @renderAxis()

  mousemove: () =>
    p = d3.mouse @plotArea() 
    # t = d3.event.changedTouches
    
    if (@dragged)
      @dragged.y = @y.invert(Math.max(0, Math.min(@size.height, p[1])));
      @updateChart();

    @_xAxisDragged(p)
    @_yAxisDragged(p)

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

    if (@dragged) 
      @dragged = null 

  _xAxisDragged: (p) ->
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
    
  _yAxisDragged: (p) ->
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