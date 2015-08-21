coffee = require 'coffee-script'
vm = require 'vm'

  
module.exports =
  config:
    openDeveloperToolsOnRun:
      type: 'boolean'
      default: true

  dispatcher:
    'source.js': (code) -> vm.runInThisContext(code)
    'source.coffee': (code) -> vm.runInThisContext(coffee.compile(code, bare: true))

  activate: ->
    @disposable = atom.commands.add 'atom-text-editor', 'run-in-atom:run-in-atom', =>
      if atom.config.get 'run-in-atom.openDeveloperToolsOnRun'
        atom.openDevTools()
      editor = atom.workspace.getActiveTextEditor()
      if !editor
        console.warn "Run in Atom Warning: No text editor is active."
        return
      code = editor.getSelectedText()
      if code
        scope = @matchingCursorScopeInEditor(editor)
      else
        code = editor.getText()
        scope = @scopeInEditor(editor)
      @runCodeInScope code, scope, (error, warning, result) ->
        if error
          console.error "Run in Atom Error:", error
        else if warning
          console.warn "Run in Atom Warning:", warning
        else
          console.log "Run in Atom:", result

  deactivate: ->
    @disposable?.dispose()

  runCodeInScope: (code, scope, callback) ->
    if @dispatcher[scope]?
      try
        result = @dispatcher[scope].call(this, code)
        callback(null, null, result)
      catch error
        callback(error)
    else
      warning = "Attempted to run in scope '#{scope}', which isn't supported."
      callback(null, warning)

  matchingCursorScopeInEditor: (editor) ->
    scopes = @getScopes()

    for scope in scopes
      return scope if scope in editor.getLastCursor().getScopeDescriptor().scopes

  getScopes: ->
    ['source.coffee', 'source.js']

  scopeInEditor: (editor) ->
    editor.getGrammar()?.scopeName

  dispatchRun: ->
    add: (scope, func) => @dispatcher[scope] = func
    remove: (scope) => delete @dispatcher[scope]
