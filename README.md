# Run in Atom package [![Build Status](https://travis-ci.org/robenkleene/run-in-atom.svg?branch=master)](https://travis-ci.org/robenkleene/run-in-atom)

Run in Atom is an Atom package that allows code to be executed in the context of Atom itself. This means the code can examine and manipulate Atom's state while it's running.

For example, running the following CoffeeScript with Run in Atom will log the contents of the current document to the console.

``` coffeescript
editor = atom.workspace.activePaneItem
editor.getText()
```

![Contextual Menu](https://raw.githubusercontent.com/robenkleene/run-in-atom/master/docs/contextual-menu.gif)

Calling "Run In Atom" with asyncornous CoffeeScript with visible UI changes:

``` coffeescript
activePane = atom.workspaceView.getActivePaneView()
atom.project.open().then (editor) ->
  activePane.splitDown(editor)
```

![Command Palette](https://raw.githubusercontent.com/robenkleene/run-in-atom/master/docs/command-palette.gif)

## Documentation

Code can be run in the following ways. In all cases it runs the selection if it exists, otherwise the whole document. The code's result is logged to the console.

* `cmd-k r` keyboard shortcut
* Choosing "Run In Atom" from the [command palette](https://github.com/atom/command-palette)
* Choosing "Run in Atom" from the contextual menu

This package is based on code from [probablycorey](https://atom.io/users/probablycorey)'s [coffee-eval](https://atom.io/packages/coffee-eval), with the following differentiating features:

* Both CoffeeScript and JavaScript are supported.
* Coffee Eval's output window has been removed.
* There's a configuration option to automatically open the developer tools when code is run.
* Code can by run from the contextual menu.
* In [GitHub Flavored Markdown](https://github.com/atom/language-gfm), code can be run in fenced code blocks.
