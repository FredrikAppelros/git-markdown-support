stream = require 'stream'
_ = require 'lodash'

mediumHeaderRegex = /(?:\n\n)?(?:\x1b\[\d{2}m)?commit \w{40}(?:\x1b\[m)?\n(?:Merge: \w{40}(?: \w{40})*\n)?Author: [^\n]+\nDate:   [^\n]+\n\n/g

class GitCommitMessageFormatter extends stream.Transform
  constructor: (@_render, options) ->
    super options
    @_data = ''

  _transform: (chunk, encoding, callback) ->
    @_data += chunk.toString 'utf-8'
    [headers, messages] = @_parseData()
    rendered = (@_render msg for msg in messages)
    results = (commit.join '' for commit in _.zip headers, rendered)
    callback null, results.join ''

  _parseData: ->
    offsets = []
    while match = mediumHeaderRegex.exec @_data
      offsets.push [match.index, mediumHeaderRegex.lastIndex]
    headers = (@_data[s...e].replace /^\n{2}/, '\n' for [s, e] in offsets)
    offsets.push [-1, 0]
    messages = []
    for [s, e] in offsets
      if prevEnd
        lines = @_data[prevEnd...s].split '\n'
        lines = (line[4..] for line in lines)
        msg = lines.join '\n'
        messages.push msg
      prevEnd = e
    [headers, messages]

module.exports = GitCommitMessageFormatter
