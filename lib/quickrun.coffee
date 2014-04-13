{BufferedProcess} = require "atom"
util = require "util"
temp = require "temp"

module.exports =
  specs:
    "Ruby":
      cmd: "ruby"
      args: ["-e", "%s"]
    "Perl":
      cmd: "perl"
      args: ["-e", "%s"]
    "Python":
      cmd: "python"
      args: ["-c", "%s"]

  activate: (state) ->
    atom.workspaceView.command "quickrun:execute", => @execute()

  execute: ->
    editor = atom.workspace.getActiveEditor()
    grammar = editor.getGrammar()
    spec = @specs[grammar.name]
    return unless spec?
    command = spec.cmd
    args = spec.args
    code = editor.getBuffer().getText()
    args = (util.format arg, code for arg in args)
    @executeCore command, args

  executeCore: (command, args) ->
    options =
      env: process.env
    stdout = @handleOutput
    stderr = @hundleOutput
    new BufferedProcess({command, args, options, stdout, stderr})

  handleOutput: (output) ->
    temp.open "quickrun", (_, info) =>
      atom.workspace
        .open(info.path, split: 'right', activatePane: true)
        .done (editor) =>
          buffer = editor.getBuffer()
          buffer.append output
