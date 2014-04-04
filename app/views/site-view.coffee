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

    pageHeader0: "#page-head-container-l1"
    pageHeader1: "#page-head-container-l2"
    pageHeader2: "#page-head-container-r1"
    pageHeader3: "#page-head-container-r2"
  template: template
# module.exports = class SiteView extends View
#   className: 'site-view'
#   # container: '#content-container'
#   container: "body"
#   template: require('./site')


#   initialize: ->
#     console.log "SiteView@initialize"
#     super