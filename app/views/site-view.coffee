'use strict'

View = require('views/base/view')

module.exports = class SiteView extends View
  className: 'site-view'
  # container: '#page-container'
  container: "body"
  template: require('./site')


  initialize: ->
    console.log "SiteView@initialize"