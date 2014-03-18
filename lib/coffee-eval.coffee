coffee = require 'coffee-script'
vm     = require 'vm'

module.exports =
  activate: ->
    atom.workspaceView.on 'coffee-eval:eval', => @coffeeEval()

  coffeeEval: ->
    editor = atom.workspaceView.getActivePaneItem()
    return unless editor.getGrammar()?.scopeName is 'source.coffee'

    code = editor.getSelectedText() or editor.getText()
    output = @evaluateCode(code)
    @showOutput(output)

  evaluateCode: (code) ->
    try
      output = vm.runInThisContext(coffee.compile(code, bare: true))
      console.log output
    catch e
      output = "Error:#{e}"
      console.error "Eval Error:", e

    output

  showOutput: (output, activePane) ->
    activePane ?= atom.workspaceView.getActivePane()
    unless @outputEditor?
      atom.project.open().then (@outputEditor) =>
        @outputEditor.on 'destroyed', => @outputEditor = null
        if nextPane = activePane.getNextPane()
          nextPane.showItem(@outputEditor)
        else
          activePane.splitDown(@outputEditor)
        @showOutput(output, activePane)
    else
      @outputEditor.setText(output?.toString() or "")
      activePane.focus()
