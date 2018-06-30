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

elmApp.ports.renderGraph.subscribe(({rootNodeId, nodes, edges}) => {
  Cytoscape.render(
    document.getElementById('coto-graph-view'),
    rootNodeId,
    map(nodes.concat(edges), element => { 
      return {
        data: element,
        classes: element.asCotonoma ? 'cotonoma' : ''
      } 
    }),
    (nodeId) => {
      if (nodeId != 'home') {
        elmApp.ports.nodeClicked.send(nodeId)
      }
    }
  )
})

elmApp.ports.resizeGraph.subscribe(() => {
  Cytoscape.resize()
})

elmApp.ports.destroyGraph.subscribe(() => {
  Cytoscape.destroy()
})

elmApp.ports.setItem.subscribe(([key, value]) => {
  if (value === null) {
    localStorage.removeItem(key)
  } 
  else {
    localStorage.setItem(key, JSON.stringify(value))
  }
})

elmApp.ports.getItem.subscribe((key) => {
  var value = null
  try {
    value = JSON.parse(localStorage.getItem(key))
  } 
  catch (e) {}
  elmApp.ports.receiveItem.send([key, value])
})

elmApp.ports.getAllItems.subscribe(() => {
  for (var i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i)
    var value = null
    try {
      value = JSON.parse(localStorage.getItem(key))
    } 
    catch (e) {}
    elmApp.ports.receiveItem.send([key, value])
  }
})

elmApp.ports.getItem.clearStorage.subscribe((prefix) => {
  if (prefix) {
    for (var i = localStorage.length - 1; i >= 0; --i) {
      var key = localStorage.key(i)
      if (key && key.startsWith(prefix)) {
        localStorage.removeItem(key)
      }
    }
  } 
  else {
    localStorage.clear()
  }
})

