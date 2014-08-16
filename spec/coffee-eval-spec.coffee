{WorkspaceView} = require 'atom'

describe "CoffeeEval", ->
  editor = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()

    waitsForPromise ->
      atom.packages.activatePackage('language-coffee-script')

    waitsForPromise ->
      atom.packages.activatePackage('coffee-eval')

    waitsForPromise ->
      atom.workspace.open("empty.coffee")

    runs ->
      editor = atom.workspace.getActivePaneItem()

  it "evaluates coffeescript and logs the result", ->
    atom.config.set('coffee-eval.showOutputPane', false)
    spyOn(console, "log").andCallThrough()

    runs ->
      editor.setText("atom.getVersion()")
      atom.workspaceView.trigger 'coffee-eval:eval'
      expect(console.log).toHaveBeenCalledWith(atom.getVersion())

  describe "the output pane", ->
    coffeeEval = null

    beforeEach ->
      coffeeEval = atom.packages.getActivePackage('coffee-eval').mainModule
      spyOn(coffeeEval, 'showOutput').andCallThrough()

    it "logs the result if showOutputpane is set to true", ->
      atom.config.set('coffee-eval.showOutputPane', true)

      runs ->
        editor.setText("atom.getVersion()")
        atom.workspaceView.trigger 'coffee-eval:eval'
        expect(coffeeEval.showOutput.callCount > 1)

      waitsFor ->
        atom.workspaceView.getPaneViews().length > 1

      runs ->
        expect(atom.workspaceView.getPaneViews()[1].getActivePaneItem().getText()).toBe(atom.getVersion())

    it "doesn't show the output pane if showOutputpane is set to false", ->
      atom.config.set('coffee-eval.showOutputPane', false)

      runs ->
        editor.setText("atom.getVersion()")
        atom.workspaceView.trigger 'coffee-eval:eval'
        expect(coffeeEval.showOutput.callCount).toBe 0
