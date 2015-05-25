marked = require '../marked'
wrap = require 'wordwrap'
chalk = require 'chalk'
Table = require 'cli-table'
_ = require 'lodash'

alignmentMap =
  left: 'left'
  center: 'middle'
  right: 'right'

indent = (text, level = 1) ->
  lines = text.split '\n'
  indented = ((_.repeat ' ', 4 * level) + line for line in lines)
  indented.join '\n'

class TerminalMarkdownRenderer
  constructor: (@_width) ->
    @_table = null
    @_tableHeader = []
    @_tableAlignments = []
    @_tableRow = []

  _wrap: (text, margin = 4) ->
    wrap(margin, @_width - margin) text

  code: (code, lang, escaped) ->
    "\n#{chalk.bgBlack "\n#{indent code, 2}\n"}\n"

  blockquote: (quote) ->
    "\n#{@_wrap chalk.italic("“#{quote.trim()}”"), 8}\n"

  html: (html) -> html

  heading: (text, level, raw) ->
    "#{@_wrap chalk.bold.underline text}\n"

  hr: ->  "\n#{indent _.repeat '─', @_width - 8}\n"

  list: (body, ordered) ->
    inner = ''
    items = body.trim().split('\n')
    for item, i in items
      if ordered
        inner += "\n#{i + 1}. #{item}"
      else
        inner += "\n• #{item}"
    "#{@_wrap inner}\n"

  listitem: (text) -> "#{text}\n"

  paragraph: (text) -> "\n#{@_wrap text}\n"

  table: (header, body) ->
    table = @_table.toString()
    @_table = null
    @_tableHeader = []
    @_tableAlignments = []
    indent "\n#{table}\n"

  tablerow: (content) ->

  tablecell: (content, flags) ->
    if flags.header
      @_tableHeader.push content
      @_tableAlignments.push alignmentMap[flags.align]
    else
      unless @_table
        @_table = new Table
          head: @_tableHeader
          colAligns: @_tableAlignments
          style:
            head: ['cyan', 'bold']
      @_tableRow.push content
      if @_tableRow.length is @_tableHeader.length
        @_table.push @_tableRow
        @_tableRow = []
    null

  strong: (text) -> chalk.bold text

  em: (text) -> chalk.italic text

  codespan: (text) -> text

  br: -> '\n'

  del: (text) -> chalk.strikethrough text

  link: (href, title, text) -> "#{text} (#{href})"

  image: (href, title, text) -> text

  text: (text) -> text

getRenderFunction = (width) ->
  renderMarkdown = (md) ->
    marked.setOptions
      renderer: new TerminalMarkdownRenderer width
    marked md

module.exports = getRenderFunction
