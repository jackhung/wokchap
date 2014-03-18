View = require('views/base/view')

module.exports = class PagerView extends View
  container: '#pagination-container'
  containerMethod: 'html'
  template: require('./pagertmpl')

  initialize: ->
    console.log "PagerView#initialize #{@model.get('offset')}"
    super

  listen: 
    "change model" : "render"

  render: () ->
    super
    
    html = @template(@model.attributes)
    $(@container).html(html)

    console.log "PagerView#render offset=#{@model.get('offset')} #{$(@container).html()} ==== container: #{@container} ===="


