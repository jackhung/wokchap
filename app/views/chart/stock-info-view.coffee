View = require 'views/base/view'
template = require 'views/chart/stock-info'

module.exports = class StockInfoView extends View
  region: "pageHeader0"
  template: template

  listen:
    "change model" : "render"
    "sync model" : "fetching"

  fetching: ->
    @$("#quote-pane").removeClass("highlight")

  render: ->
    super
    @$("#quote-pane").addClass("highlight")