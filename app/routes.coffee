'use strict'

module.exports = (match) ->
  # not needed anymore as the root option for router is adjusted initialize.coffee
  # match 'app', 'app#index'
  # match 'app/book/:code', 'book#show'
  # match 'app/news', 'news#list'
  # match 'app/news/:link', 'news#show'

  match '', 'app#index'
  match 'book/:code', 'book#show'
  match 'news', 'news#list'
  match 'news/:link', 'news#show'