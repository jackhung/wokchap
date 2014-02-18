'use strict'

Book = require('models/book')
Books = require('models/books')

describe 'Books', ->

  beforeEach ->
    @book = new Book
    @books = new Books

  it '', ->


  afterEach ->
    @book.dispose()
    @books.dispose()
