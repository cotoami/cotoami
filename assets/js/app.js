// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import Cytoscape from "js/cytoscape"

// Set up our Elm App
const elmDiv = document.querySelector("#elm-container")
const elmApp = Elm.Main.embed(elmDiv, {
  seed: Math.floor(Math.random() * 0x0FFFFFFF)
})

elmApp.ports.renderGraph.subscribe(() => {
  Cytoscape.render(
    document.getElementById('coto-graph-view'), 
    [
      {"data":{"id":"room","name":"Cotoami開発","root":true,"hiddenNodes":0}},
      {"data":{"id":"11512","name":"Client-side tasks","root":false,"hiddenNodes":2}},
      {"data":{"id":"11513","name":"tai2","root":false,"hiddenNodes":0}},
      {"data":{"id":"11516","name":"Server-side tasks","root":false,"hiddenNodes":3}},
      {"data":{"id":"12604","name":"a","root":false,"hiddenNodes":0}},
      {"data":{"id":"12605","name":"b","root":false,"hiddenNodes":0}},
      {"data":{"id":"12606","name":"c","root":false,"hiddenNodes":0}},
      {"data":{"id":"11535","name":"Both-sides tasks","root":false,"hiddenNodes":3}},
      {"data":{"id":"11538","name":"直接Pinツールボタン","root":false,"hiddenNodes":0}},
      {"data":{"source":"room","target":"11512"}},
      {"data":{"source":"room","target":"11513"}},
      {"data":{"source":"room","target":"11516"}},
      {"data":{"source":"room","target":"12604"}},
      {"data":{"source":"room","target":"12605"}},
      {"data":{"source":"room","target":"12606"}},
      {"data":{"source":"room","target":"11535"}},
      {"data":{"source":"11535","target":"11538"}}
    ]
  )
})
