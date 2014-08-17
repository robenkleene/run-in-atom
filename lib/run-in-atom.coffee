coffee = require 'coffee-script'
vm     = require 'vm'

module.exports =
  activate: ->
    atom.workspaceView.command 'run-in-atom:run-in-atom', =>
      editor = atom.workspace.getActivePaneItem()
      code = editor.getSelectedText()
      if code
        scope = matchingCursorScopeInEditor(editor)
      else
        code = editor.getText()
        scope = @scopeInEditor(editor)
      @runCodeInScope(code, scope)

  runCodeInScope: (code, scope) ->
    switch scope
      when 'source.coffee'
        try
          console.log vm.runInThisContext(coffee.compile(code, bare: true))
        catch e
          console.error "Run in Atom Error:", e
      when 'source.js'
        console.log code

  matchingCursorScopeInEditor: (editor) ->
    scopes = @getScopes()
    for scope in scopes
      return scope if scope in editor.getCursorScopes()

  getScopes: ->
    ['source.coffee', 'source.js']

  scopeInEditor: (editor) ->
    editor.getGrammar()?.scopeName
