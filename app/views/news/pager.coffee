View = require('views/base/view')

module.exports = class PagerView extends View
  containerMethod: 'html'
  template: require('./pagertmpl')
  region: "pagerContent"

  pagerSize: 9

  initialize: ->
    console.log "PagerView#initialize #{@model.get('offset')}"
    super

  listen: 
    "change model" : "render"

  render: () ->
    return if not @model.isReady()
    # super
    
    html = @template(@model.attributes)
    $(@container).html(html)
    max = @model.get("max")
    currentPage = @model.get("offset") / max
    totalPages = @model.get("totalPages")

    return if totalPages <= 0

    pStart = Math.floor(currentPage - (@pagerSize / 2))
    pStart = 0 if pStart < 0
    pEnd = pStart + @pagerSize
    if pEnd >= totalPages
      pEnd = totalPages
      s = Math.floor(pEnd - (@pagerSize / 2))
      if s >=0 and s < pStart
        pStart = s

    pages = for n in [pStart ... pEnd]
      o = n * max
      clazz = if (n is currentPage) then "class='active'" else ""
      "<li #{clazz}><a href='news?offset=#{o}&max=#{max}'>#{n+1}</a></li>"

    @$el.html("<ul class='pagination'>#{pages.join('')}</ul>")
    # console.log "PagerView#render offset=#{currentPage} #{$(@container).html()} ==== container: #{@container} ===="
    # console.log pages

