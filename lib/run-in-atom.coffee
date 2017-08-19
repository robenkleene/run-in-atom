coffee = require 'coffee-script'
livescript = require 'LiveScript'
typescring = require 'typestring'
vm = require 'vm'


module.exports =
  config:
    openDeveloperToolsOnRun:
      type: 'boolean'
      default: true
    clearConsoleBeforeRun:
      type: 'boolean'
      default: false

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
    switch scope
      when 'source.coffee', 'source.embedded.coffee'
        vm.runInThisContext(console.clear()) if atom.config.get 'run-in-atom.clearConsoleBeforeRun'
        try
          result = vm.runInThisContext(coffee.compile(code, bare: true))
          callback(null, null, result)
        catch error
          callback(error)
      when 'source.js', 'source.embedded.js'
        vm.runInThisContext(console.clear()) if atom.config.get 'run-in-atom.clearConsoleBeforeRun'
        try
          result = vm.runInThisContext(code)
          callback(null, null, result)
        catch error
          callback(error)
      when 'source.livescript'
        vm.runInThisContext(console.clear()) if atom.config.get 'run-in-atom.alwaysClearConsole'
        try
          result = vm.runInThisContext(livescript.compile(code, bare: true))
          callback(null, null, result)
        catch error
          callback(error)
      when 'source.ts'
        vm.runInThisContext(console.clear()) if atom.config.get 'run-in-atom.alwaysClearConsole'
        try
          result = vm.runInThisContext(typestring.compile(code))
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
    ['source.coffee', 'source.js', 'source.embedded.coffee', 'source.embedded.js', 'source.livescript', 'source.ts']

  scopeInEditor: (editor) ->
    editor.getGrammar()?.scopeName
