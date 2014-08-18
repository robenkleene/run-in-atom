{WorkspaceView} = require 'atom'
RunInAtom = require '../lib/run-in-atom'

describe "Run in Atom", ->
  editor = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()

    waitsForPromise ->
      atom.packages.activatePackage('run-in-atom')

    waitsForPromise ->
      atom.packages.activatePackage('language-coffee-script')

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

  describe "Editor scope functions", ->

    describe "for a CoffeeScript file", ->

      beforeEach ->

        waitsForPromise ->
          atom.workspace.open("empty.coffee")

        runs ->
          editor = atom.workspace.getActivePaneItem()

      it "scopeInEditor returns 'source.coffee'", ->
        expect(RunInAtom.scopeInEditor(editor)).toBe 'source.coffee'

      it "matchingCursorScopeInEditor returns 'source.coffee'", ->
        expect(RunInAtom.matchingCursorScopeInEditor(editor)).toBe 'source.coffee'

    describe "for a JavaScript file", ->

      beforeEach ->

        waitsForPromise ->
          atom.workspace.open("empty.js")

        runs ->
          editor = atom.workspace.getActivePaneItem()

      it "scopeInEditor returns 'source.js'", ->
        expect(RunInAtom.scopeInEditor(editor)).toBe 'source.js'

      it "matchingCursorScopeInEditor returns 'source.js'", ->
        expect(RunInAtom.matchingCursorScopeInEditor(editor)).toBe 'source.js'

    describe "for a Markdown file", ->

      beforeEach ->
        waitsForPromise ->
          atom.packages.activatePackage('language-gfm')

        waitsForPromise ->
          atom.workspace.open("code.md")

        runs ->
          editor = atom.workspace.getActivePaneItem()

      describe "when the cursor is not in a code block", ->

        beforeEach ->
          editor.setCursorScreenPosition([0, 0])

        it "scopeInEditor returns 'source.gfm'", ->
          expect(RunInAtom.scopeInEditor(editor)).toBe 'source.gfm'

        it "matchingCursorScopeInEditor returns 'source.gfm'", ->
          expect(RunInAtom.matchingCursorScopeInEditor(editor)).toBe undefined

      describe "when the cursor is in a CoffeeScript code block", ->

        beforeEach ->
          editor.setCursorScreenPosition([1, 0])

        it "scopeInEditor returns 'source.gfm'", ->
          expect(RunInAtom.scopeInEditor(editor)).toBe 'source.gfm'

        it "matchingCursorScopeInEditor returns 'source.coffee'", ->
          expect(RunInAtom.matchingCursorScopeInEditor(editor)).toBe 'source.coffee'

      describe "when the cursor is in a JavaScript code block", ->
        beforeEach ->
          editor.setCursorScreenPosition([5, 0])

        it "scopeInEditor returns 'source.gfm'", ->
          expect(RunInAtom.scopeInEditor(editor)).toBe 'source.gfm'

        it "matchingCursorScopeInEditor returns 'source.js'", ->
          expect(RunInAtom.matchingCursorScopeInEditor(editor)).toBe 'source.js'

  describe "running code", ->

    coffeeScriptCode = "atom.getVersion() is undefined"
    javaScriptCode = "atom.getVersion() === undefined"
    prefix = "Run in Atom:"
    result = false

    beforeEach ->
      spyOn(console, "error")
      spyOn(console, "log")

    describe "CoffeeScript file", ->

      beforeEach ->

        waitsForPromise ->
          atom.workspace.open("empty.coffee")

        runs ->
          editor = atom.workspace.getActivePaneItem()

      it "logs an error if code is invalid", ->
        editor.setText(javaScriptCode)
        atom.workspaceView.trigger 'run-in-atom:run-in-atom'
        expect(console.error).toHaveBeenCalled

      it "runs CoffeeScript and logs the result", ->
        editor.setText(coffeeScriptCode)
        atom.workspaceView.trigger 'run-in-atom:run-in-atom'
        expect(console.log).toHaveBeenCalledWith(prefix, result)

    describe "JavaScript file", ->

      beforeEach ->

        waitsForPromise ->
          atom.workspace.open("empty.coffee")

        runs ->
          editor = atom.workspace.getActivePaneItem()

        it "logs an error if code is invalid", ->
          editor.setText(coffeeScriptCode)
          atom.workspaceView.trigger 'run-in-atom:run-in-atom'
          expect(console.error).toHaveBeenCalled

        it "runs JavaScript and logs the result", ->
          editor.setText(javaScriptCode)
          atom.workspaceView.trigger 'run-in-atom:run-in-atom'
          expect(console.log).toHaveBeenCalledWith(prefix, result)

    describe "Markdown file", ->
      beforeEach ->

        waitsForPromise ->
          atom.workspace.open("code.md")

        runs ->
          editor = atom.workspace.getActivePaneItem()

      it "Logs a warning if CoffeeScript isn't selected", ->
      it "Runs if CoffeeScript is selected", ->
