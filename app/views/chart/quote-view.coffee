View = require 'views/base/view'
QuoteTmpl = require 'views/chart/quote-tmpl'

module.exports = class QuoteView extends View
  region: "pageHeader3"
  template: QuoteTmpl

  listen:
    "change model" : "render"
    "sync model" : "fetching"

  fetching: ->
    @$("#quote-pane").removeClass("highlight")

  render: ->
    super
    @$("#quote-pane").addClass("highlight")