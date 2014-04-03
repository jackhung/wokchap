'use strict'

View = require 'views/base/view'
template = require './site'

# Site view is a top-level view which is bound to body.
module.exports = class ThreePaneView extends View
  id: 'site-pane-view'
  region: 'main'
  regions:
    header: '#header-container'
    content: '#content'
    footer: '#footer-container'

    pageHeader: "#page-head-cotainer"
  template: template
# module.exports = class SiteView extends View
#   className: 'site-view'
#   # container: '#content-container'
#   container: "body"
#   template: require('./site')


#   initialize: ->
#     console.log "SiteView@initialize"
#     super