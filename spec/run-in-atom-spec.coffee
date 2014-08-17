{WorkspaceView} = require 'atom'

describe "Run in Atom", ->
  editor = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()

    waitsForPromise ->
      atom.packages.activatePackage('run-in-atom')

  describe "Editor scope functions", ->

    beforeEach ->

      waitsForPromise ->
        atom.packages.activatePackage('language-coffee-script')

      waitsForPromise ->
        atom.packages.activatePackage('language-javascript')

      describe "for a CoffeeScript file", ->
        it "scopeInEditor returns 'source.coffee'", ->
        it "matchingCursorScopeInEditor returns 'source.coffee'", ->

      describe "for a JavaScript file", ->
        it "scopeInEditor returns 'source.js'", ->
        it "matchingCursorScopeInEditor returns 'source.js'", ->

      describe "for a Markdown file", ->
        waitsForPromise ->
          atom.packages.activatePackage('language-gfm')

        describe "when the cursor is not in a code block", ->
          it "scopeInEditor returns 'source.gfm'", ->
          it "matchingCursorScopeInEditor returns 'source.gfm'", ->

        describe "when the cursor is in a CoffeeScript code block", ->
          it "scopeInEditor returns 'source.gfm'", ->
          it "matchingCursorScopeInEditor returns 'source.coffee'", ->

        describe "when the cursor is in a JavaScript code block", ->
          it "scopeInEditor returns 'source.gfm'", ->
          it "matchingCursorScopeInEditor returns 'source.js'", ->

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
