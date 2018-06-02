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
import map from 'lodash/map'
import Cytoscape from "js/cytoscape"

// Set up our Elm App
const elmDiv = document.querySelector("#elm-container")
const elmApp = Elm.Main.embed(elmDiv, {
  seed: Math.floor(Math.random() * 0x0FFFFFFF)
})

elmApp.ports.renderGraph.subscribe(([nodes, edges]) => {
  Cytoscape.render(
    document.getElementById('coto-graph-view'), 
    map(nodes.concat(edges), element => { return {data: element} })
  )
})
