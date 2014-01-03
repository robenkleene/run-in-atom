{WorkspaceView} = require 'atom'

describe "CoffeeEval", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()
    atom.packages.activatePackage('language-coffee-script', sync: true)
    atom.packages.activatePackage('coffee-eval', immediate: true)

  it "evaluates coffeescript and logs the result", ->
    spyOn(console, "log")
    atom.workspaceView.openSync("empty.coffee")
    editor = atom.workspaceView.getActivePaneItem()
    editor.setText("atom.getVersion()")
    atom.workspaceView.trigger 'coffee-eval:eval'

    waitsFor ->
      atom.workspaceView.getPanes().length > 1

    runs ->
      expect(console.log).toHaveBeenCalledWith(atom.getVersion())
      expect(atom.workspaceView.getPanes()[1].getActivePaneItem().getText()).toBe(atom.getVersion())
