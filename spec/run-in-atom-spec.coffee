RunInAtom = require '../lib/run-in-atom'

describe "Run in Atom", ->
  workspaceElement = null
  editorElement = null
  editor = null
  markdownCursorPositionNoCode = [0, 0]
  markdownCursorPositionCoffeeScript = [1, 0]
  markdownCursorPositionJavaScript = [6, 0]

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    jasmine.attachToDOM(workspaceElement)
    atom.config.set('run-in-atom.openDeveloperToolsOnRun', false)

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
          editor = atom.workspace.getActiveTextEditor()

      it "scopeInEditor returns 'source.coffee'", ->
        expect(RunInAtom.scopeInEditor(editor)).toBe 'source.coffee'

      it "matchingCursorScopeInEditor returns 'source.coffee'", ->
        expect(RunInAtom.matchingCursorScopeInEditor(editor)).toBe 'source.coffee'

    describe "for a JavaScript file", ->

      beforeEach ->

        waitsForPromise ->
          atom.workspace.open("empty.js")

        runs ->
          editor = atom.workspace.getActiveTextEditor()

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
          editor = atom.workspace.getActiveTextEditor()

      describe "when the cursor is not in a code block", ->

        beforeEach ->
          editor.setCursorScreenPosition(markdownCursorPositionNoCode)

        it "scopeInEditor returns 'source.gfm'", ->
          expect(RunInAtom.scopeInEditor(editor)).toBe 'source.gfm'

        it "matchingCursorScopeInEditor returns 'source.gfm'", ->
          expect(RunInAtom.matchingCursorScopeInEditor(editor)).toBe undefined

      describe "when the cursor is in a CoffeeScript code block", ->

        beforeEach ->
          editor.setCursorScreenPosition(markdownCursorPositionCoffeeScript)

        it "scopeInEditor returns 'source.gfm'", ->
          expect(RunInAtom.scopeInEditor(editor)).toBe 'source.gfm'

        it "matchingCursorScopeInEditor returns 'source.coffee'", ->
          expect(RunInAtom.matchingCursorScopeInEditor(editor)).toBe 'source.coffee'

      describe "when the cursor is in a JavaScript code block", ->
        beforeEach ->
          editor.setCursorScreenPosition(markdownCursorPositionJavaScript)

        it "scopeInEditor returns 'source.gfm'", ->
          expect(RunInAtom.scopeInEditor(editor)).toBe 'source.gfm'

        it "matchingCursorScopeInEditor returns 'source.js'", ->
          expect(RunInAtom.matchingCursorScopeInEditor(editor)).toBe 'source.js'

  describe "running code", ->
    activationPromise = null

    coffeeScriptCode = "atom.getVersion() is undefined"
    javaScriptCode = "atom.getVersion() === undefined"
    prefix = "Run in Atom:"
    result = false

    beforeEach ->
      activationPromise = atom.packages.activatePackage('run-in-atom')
      spyOn(console, "error")
      spyOn(console, "log")
      spyOn(console, "warn")

    describe "CoffeeScript file", ->

      beforeEach ->

        waitsForPromise ->
          atom.workspace.open("empty.coffee")

        runs ->
          editor = atom.workspace.getActiveTextEditor()
          editorElement = atom.views.getView(editor)

      describe "openDeveloperToolsOnRun config option", ->
        beforeEach ->
          spyOn(atom, "openDevTools")

        it "opens the developer tools if true", ->
          atom.config.set('run-in-atom.openDeveloperToolsOnRun', true)
          editor.setText(coffeeScriptCode)
          atom.commands.dispatch editorElement, 'run-in-atom:run-in-atom'

          waitsForPromise ->
            activationPromise

          runs ->
            expect(atom.openDevTools).toHaveBeenCalled

        it "doesn't open the developer tools if false", ->
          atom.config.set('run-in-atom.openDeveloperToolsOnRun', false)
          editor.setText(coffeeScriptCode)
          atom.commands.dispatch editorElement, 'run-in-atom:run-in-atom'

          waitsForPromise ->
            activationPromise

          runs ->
            expect(atom.openDevTools).not.toHaveBeenCalled

      it "logs an error if CoffeeScript is invalid", ->
        editor.setText(javaScriptCode)
        atom.commands.dispatch editorElement, 'run-in-atom:run-in-atom'

        waitsForPromise ->
          activationPromise

        runs ->
          expect(console.log).not.toHaveBeenCalled
          expect(console.error).toHaveBeenCalled
          expect(console.warn).not.toHaveBeenCalled

      it "runs CoffeeScript and logs the result", ->
        editor.setText(coffeeScriptCode)
        atom.commands.dispatch editorElement, 'run-in-atom:run-in-atom'

        waitsForPromise ->
          activationPromise

        runs ->
          expect(console.log).toHaveBeenCalledWith(prefix, result)
          expect(console.error).not.toHaveBeenCalled
          expect(console.warn).not.toHaveBeenCalled

    describe "JavaScript file", ->

      beforeEach ->

        waitsForPromise ->
          atom.workspace.open("empty.coffee")

        runs ->
          editor = atom.workspace.getActiveTextEditor()
          editorElement = atom.views.getView(editor)

        it "logs an error if JavaScript is invalid", ->
          editor.setText(coffeeScriptCode)
          atom.commands.dispatch editorElement, 'run-in-atom:run-in-atom'

          waitsForPromise ->
            activationPromise

          runs ->
            expect(console.log).not.toHaveBeenCalled
            expect(console.error).toHaveBeenCalled
            expect(console.warn).not.toHaveBeenCalled

        it "runs JavaScript and logs the result", ->
          editor.setText(javaScriptCode)
          atom.commands.dispatch editorElement, 'run-in-atom:run-in-atom'

          waitsForPromise ->
            activationPromise

          runs ->
            expect(console.log).toHaveBeenCalledWith(prefix, result)
            expect(console.error).not.toHaveBeenCalled
            expect(console.warn).not.toHaveBeenCalled

    describe "Markdown file", ->
      beforeEach ->

        waitsForPromise ->
          atom.packages.activatePackage('language-gfm')

        waitsForPromise ->
          atom.workspace.open("code.md")

        runs ->
          editor = atom.workspace.getActiveTextEditor()
          editorElement = atom.views.getView(editor)

      it "Logs a warning if nothing is selected", ->
        editor.setCursorScreenPosition(markdownCursorPositionNoCode)
        atom.commands.dispatch editorElement, 'run-in-atom:run-in-atom'

        waitsForPromise ->
          activationPromise

        runs ->
          expect(console.log).not.toHaveBeenCalled
          expect(console.error).not.toHaveBeenCalled
          expect(console.warn).toHaveBeenCalled

      it "Logs a warning if Markdown is selected", ->
        editor.setCursorScreenPosition(markdownCursorPositionNoCode)
        editor.selectLinesContainingCursors()
        atom.commands.dispatch editorElement, 'run-in-atom:run-in-atom'

        waitsForPromise ->
          activationPromise

        runs ->
          expect(console.log).not.toHaveBeenCalled
          expect(console.error).not.toHaveBeenCalled
          expect(console.warn).toHaveBeenCalled

      it "Runs if CoffeeScript is selected", ->
        editor.setCursorScreenPosition(markdownCursorPositionCoffeeScript)
        editor.selectLinesContainingCursors()
        atom.commands.dispatch editorElement, 'run-in-atom:run-in-atom'

        waitsForPromise ->
          activationPromise

        runs ->
          expect(console.log).toHaveBeenCalledWith(prefix, result)
          expect(console.error).not.toHaveBeenCalled
          expect(console.warn).not.toHaveBeenCalled

      it "Runs if JavaScript is selected", ->
        editor.setCursorScreenPosition(markdownCursorPositionJavaScript)
        editor.selectLinesContainingCursors()
        atom.commands.dispatch editorElement, 'run-in-atom:run-in-atom'

        waitsForPromise ->
          activationPromise

        runs ->
          expect(console.log).toHaveBeenCalledWith(prefix, result)
          expect(console.error).not.toHaveBeenCalled
          expect(console.warn).not.toHaveBeenCalled
