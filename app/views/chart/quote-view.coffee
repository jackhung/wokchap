View = require 'views/base/view'
QuoteTmpl = require 'views/chart/quote-tmpl'

module.exports = class QuoteView extends View
  region: "pageHeader3"
  template: QuoteTmpl

  listen:
    "change model" : "render"

  render: ->
    super
    console.log "QuoteView#render"
    