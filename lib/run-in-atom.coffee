coffee = require 'coffee-script'
vm     = require 'vm'

module.exports =
  activate: ->
    atom.workspaceView.command 'run-in-atom:run-in-atom', =>
      editor = atom.workspace.getActivePaneItem()
      scope = editor.getGrammar()?.scopeName
      if scope is 'source.coffee'
        @runCoffeeScript(@getCodeInEditor(editor))
      if scope is 'source.javascript'
        @runJavaScript(@getCodeInEditor(editor))

  runCoffeeScript: (code) ->
    try
      console.log vm.runInThisContext(coffee.compile(code, bare: true))
    catch e
      console.error "Run in Atom Error:", e

  runJavaScript: (code) ->
    try
      console.log code
      # vm.runInThisContext(coffee.compile(code, bare: true))
    catch e
      output = "Error:#{e}"
      console.error "Eval Error:", e

  getCodeInEditor: (editor) ->
    editor.getSelectedText() or editor.getText()
