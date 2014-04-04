'use strict'

ViewHelper = require('lib/view-helper')

module.exports = class View extends Chaplin.View
  autoRender: yes

  # Precompiled templates function initializer.
  getTemplateFunction: ->
    @template

  render: ->
    super
    return unless @model and window.rivets
    if @_rivets
      @_rivets.build()
    else
      @_rivets = rivets.bind(@el, {@model})

  dispose: ->
    @_rivets?.unbind()
    delete @_rivets
    super

  getTemplateData: ->
    data = super()
    data.vh = ViewHelper
    data

  vh: ViewHelper