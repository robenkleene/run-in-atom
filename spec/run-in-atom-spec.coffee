{WorkspaceView} = require 'atom'

describe "Run in Atom", ->
  editor = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()

  describe "runCoffeeScript", ->

    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('language-coffee-script')

      waitsForPromise ->
        atom.packages.activatePackage('run-in-atom')

      waitsForPromise ->
        atom.workspace.open("empty.coffee")

      runs ->
        editor = atom.workspace.getActivePaneItem()

    it "evaluates coffeescript and logs the result", ->
      spyOn(console, "log").andCallThrough()

      runs ->
        editor.setText("atom.getVersion()")
        atom.workspaceView.trigger 'run-in-atom:run-in-atom'
        expect(console.log).toHaveBeenCalledWith(atom.getVersion())
