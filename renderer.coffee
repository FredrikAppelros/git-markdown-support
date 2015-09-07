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
    @_listLevel = 0
    @_table = null
    @_tableHeader = []
    @_tableAlignments = []
    @_tableRow = []

  _wrap: (text, marginLeft = 4, marginRight = 4) ->
    wrap(marginLeft, @_width - marginRight) text

  code: (code, lang, escaped) ->
    "\n#{chalk.bgBlack "\n#{indent code}\n"}\n"

  blockquote: (quote) ->
    "\n#{@_wrap chalk.italic("“#{quote.trim()}”"), 8, 8}\n"

  html: (html) -> html

  heading: (text, level, raw) ->
    "#{@_wrap chalk.bold.underline text}\n"

  hr: ->  "\n#{indent _.repeat '─', @_width - 8}\n"

  listinit: -> @_lists.push
    items: []
    lists: []

  list: (items, ordered) ->
    body = ''
    for item, i in items
      bullet = if ordered then '•' else "#{i + 1}."
      body += "\n#{bullet} #{item}"
    body = "#{body}\n" unless --@_listLevel > 0
    prevList = @_lists[@_lists.length - 2]
    ret = body
    if prevList?
      prevList.lists.push
      ret = null
    ret

  listitem: (text) ->
    list = _.last @_lists
    list.items.push
      body: text
      lists: []
    null

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
