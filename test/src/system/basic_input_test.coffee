editorModule "Basic input", template: "editor_empty"

editorTest "typing", (expectDocument) ->
  typeCharacters "abc", ->
    expectDocument "abc\n"

editorTest "backspacing", (expectDocument) ->
  typeCharacters "abc\b", ->
    assertLocationRange(index: 0, offset: 2)
    expectDocument "ab\n"

editorTest "pressing delete", (expectDocument) ->
  typeCharacters "ab", ->
    moveCursor "left", ->
      pressKey "delete", ->
        expectDocument "a\n"

editorTest "pressing return", (expectDocument) ->
  typeCharacters "ab", ->
    pressKey "return", ->
      typeCharacters "c", ->
        expectDocument "ab\nc\n"

editorTest "cursor left", (expectDocument) ->
  typeCharacters "ac", ->
    moveCursor "left", ->
      typeCharacters "b", ->
        expectDocument "abc\n"

editorTest "replace entire document", (expectDocument) ->
  typeCharacters "abc", ->
    selectAll ->
      typeCharacters "d", ->
        expectDocument "d\n"

editorTest "remove entire document", (expectDocument) ->
  typeCharacters "abc", ->
    selectAll ->
      typeCharacters "\b", ->
        expectDocument "\n"

editorTest "drag text", (expectDocument) ->
  typeCharacters "abc", ->
    moveCursor direction: "left", times: 2, (coordinates) ->
      moveCursor "right", ->
        expandSelection "right", ->
          dragToCoordinates coordinates, ->
            expectDocument "acb\n"

editorTest "deleting a line (command + backspace) in a list item", (expectDocument) ->
  clickToolbarButton attribute: "bullet", ->
    typeCharacters "a\nb", ->
      triggerEvent document.activeElement, "keydown", charCode: 0, keyCode: 8, which: 8, metaKey: true
      itemElement = document.activeElement.querySelectorAll("li")[1]
      range = rangy.getSelection().getRangeAt(0)
      range.selectNodeContents(itemElement)
      range.deleteContents()
      defer ->
        assertLocationRange index: 1, offset: 0
        expectBlockAttributes [0, 1], ["bulletList", "bullet"]
        expectBlockAttributes [2, 3], ["bulletList", "bullet"]
        expectDocument "a\n\n"
