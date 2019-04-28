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
import isArray from 'lodash/isArray'
import sumBy from 'lodash/sumBy'
import compact from 'lodash/compact'
import Cytoscape from "js/cytoscape"

// Set up our Elm App
const elmDiv = document.querySelector("#elm-container")
const elmApp = Elm.Main.embed(elmDiv, {
  version: document.documentElement.getAttribute("data-app-version"),
  seed: Math.floor(Math.random() * 0x0FFFFFFF),
  lang: document.documentElement.lang
})

elmApp.ports.setUnreadStateInTitle.subscribe((unread) => {
  const link = document.querySelector("link[rel*='icon']")
  link.href = unread ?
    "/images/favicon/favicon-unread-32x32.png" :
    "/images/favicon/favicon-32x32.png"
})

const _convertGraphData = (nodes, edges) => {
  return map(nodes.concat(edges), element => {
    return {
      data: element,
      classes:
        compact([
          element.asCotonoma ? 'cotonoma' : null,
          element.asLinkingPhrase ? 'linking-phrase' : null,
          element.pinned ? 'pinned' : null,
          element.toLinkingPhrase ? 'to-linking-phrase' : null,
          element.fromLinkingPhrase ? 'from-linking-phrase' : null,
          element.subgraphLoaded ? null : 'subgraph-not-loaded'
        ]).join(' ')
    }
  })
}

elmApp.ports.renderGraph.subscribe(({ rootNodeId, nodes, edges }) => {
  Cytoscape.render(
    document.getElementById('coto-graph-canvas'),
    rootNodeId,
    _convertGraphData(nodes, edges),
    (nodeId) => {
      if (nodeId != 'home') {
        elmApp.ports.nodeClicked.send(nodeId)
      }
    }
  )
})

elmApp.ports.addSubgraph.subscribe(({ rootNodeId, nodes, edges }) => {
  Cytoscape.addSubgraph(_convertGraphData(nodes, edges))
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
  catch (e) { }
  elmApp.ports.receiveItem.send([key, value])
})

elmApp.ports.getAllItems.subscribe(() => {
  for (var i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i)
    var value = null
    try {
      value = JSON.parse(localStorage.getItem(key))
    }
    catch (e) { }
    elmApp.ports.receiveItem.send([key, value])
  }
})

elmApp.ports.clearStorage.subscribe((prefix) => {
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

const importFileInput = document.getElementById("import-file-input")
importFileInput.addEventListener("change", () => {
  const file = importFileInput.files[0]
  const reader = new FileReader()
  reader.onload = ((event) => {
    const content = event.target.result
    const result = {
      fileName: file.name,
      content: content,
      valid: false,
      error: "",
      amishiAvatarUrl: "",
      amishiDisplayName: "",
      cotos: 0,
      cotonomas: 0,
      connections: 0
    }
    try {
      const object = JSON.parse(content)

      // amishi
      if (object.amishi) {
        result.amishiAvatarUrl = object.amishi.avatar_url
        result.amishiDisplayName = object.amishi.display_name
      }
      else {
        throw 'Key "amishi" not found in JSON'
      }

      // cotos & cotonomas
      if (isArray(object.cotos)) {
        result.cotos = object.cotos.length
        result.cotonomas = sumBy(object.cotos, coto => (coto.as_cotonoma ? 1 : 0))
      }
      else {
        throw 'Key "cotos" not found in JSON'
      }

      // connections
      if (isArray(object.connections)) {
        result.connections = object.connections.length
      }
      else {
        throw 'Key "connections" not found in JSON'
      }

      result.valid = true
    }
    catch (e) {
      result.error = e.toString()
    }
    elmApp.ports.importFileContentRead.send(result)
  })
  reader.readAsText(file)
})

elmApp.ports.selectImportFile.subscribe(() => {
  importFileInput.click()
})

