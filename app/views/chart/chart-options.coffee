'use strict'

Model = require "models/base/model"

module.exports = class ChartOptions extends Model
	defaults: 
    title: "Basic Chart"
    axis:
      x:
        enable : false
        label: null
      y:
        enable : true
        label: null

  axisEnable: (axis, args) ->
    unless args.length
      return @get("axis")[axis].enable
    throw "Illegal arguments" unless args.length is 1
    @get("axis")[axis].enable = args[0]
    @

  xAxisEnable: () ->
    @axisEnable "x", arguments

  yAxisEnable: () ->
    @axisEnable "y", arguments
