coffee = require 'coffee-script'
vm     = require 'vm'

module.exports =
  activate: ->
    atom.workspaceView.command 'run-in-atom:run-in-atom', =>
      editor = atom.workspace.getActivePaneItem()
      if @isEditorScopeCoffeeScript(editor)
        @runCoffeeScript(@getCodeInEditor(editor))
      if @isEditorScopeJavaScript(editor)
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

  isEditorScopeCoffeeScript: (editor) ->
    @isEditorScope(editor, 'source.coffee')

  isEditorScopeJavaScript: (editor) ->
    @isEditorScope(editor, 'source.js')

  isEditorScope: (editor, scope) ->
    return true if scope is editor.getGrammar()?.scopeName
    return true if scope in editor.getCursorScopes()
    false
