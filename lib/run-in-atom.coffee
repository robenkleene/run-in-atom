coffee = require 'coffee-script'
vm = require 'vm'

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
      @runCodeInScope code, scope, (error, result) ->
        if error
          console.error "Run in Atom Error:", error
        else
          # console.log "Run in Atom:", result
          console.log result

  runCodeInScope: (code, scope, callback) ->
    switch scope
      when 'source.coffee'
        try
          result = vm.runInThisContext(coffee.compile(code, bare: true))
          callback(null, result)
        catch error
          callback(error)
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
