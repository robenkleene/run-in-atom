{WorkspaceView} = require 'atom'

describe "Run in Atom", ->
  editor = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()

    waitsForPromise ->
      atom.packages.activatePackage('run-in-atom')

  describe "isEditorScope", ->

    beforeEach ->

      waitsForPromise ->
        atom.packages.activatePackage('language-coffee-script')

      describe "for a CoffeeScript file", ->
        it "isEditorScopeCoffeeScript returns true", ->
        it "isEditorScopeJavaScript returns false", ->

      describe "for a JavaScript file", ->
        it "isEditorScopeCoffeeScript returns false", ->
        it "isEditorScopeJavaScript returns true", ->

      # describe "for a Markdown file", ->
      #
      #   describe "isEditorScopeCoffeeScript", ->
      #
      #
      #   it "it returns false outside of CoffeeScript code blocks", ->
      #   it "it returns true inside a CoffeeScript code block", ->

  describe "runCoffeeScript", ->

    beforeEach ->

      waitsForPromise ->
        atom.packages.activatePackage('language-coffee-script')

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
