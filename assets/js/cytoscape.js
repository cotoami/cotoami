// Graph rendering by Cytoscape.js

import debounce from 'lodash/debounce'

const _hankakuOnly = (text) => {
  return text.match(/^[\x01-\x7E\uFF65-\uFF9F\u2019]+$/) != null
}

const _insertSpaces = (text, chunkSize) => {
  const chunks = text.match(new RegExp('.{1,' + chunkSize + '}', 'g'))
  return chunks != null ? chunks.join(" ") : text
}

const _makeTextBreakable = (text, chunkSize) => {
  if (_hankakuOnly(text)) {
    return text
  }
  else {
    return _insertSpaces(text, chunkSize)
  }
}

const color_edge = "#ddd"
const color_edgeWithPhrase = "#9AB8D1"
const color_linkingPhrase = "#3572a5"
const color_selected = "#ffa500"

const _style = cytoscape.stylesheet()
  .selector('node').css({
    'label': (node) => {
      return _makeTextBreakable(node.data('name'), 15)
    },
    'font-size': (node) => {
      return Math.min(node.data('outgoings'), 10) / 2 + 10
    },
    'color': '#666',
    'shape': 'roundrectangle',
    'width': 'label',
    'height': 'label',
    'border-width': (node) => {
      return Math.min(node.data('incomings'), 10)
    },
    'border-style': 'solid',
    'border-color': '#ddd',
    'border-opacity': 1,
    'padding': 8,
    'text-max-width': (node) => {
      return Math.min(node.data('outgoings'), 10) * 10 + 150
    },
    'text-wrap': 'wrap',
    'text-valign': 'center',
    'background-color': 'white',
    'font-family': '"Raleway", "HelveticaNeue", "Helvetica Neue", Helvetica, Arial, sans-serif'
  })
  .selector('#home').css({
    'shape': 'roundrectangle',
    'width': 20,
    'height': 20,
    'border-width': 0,
    'padding': 0,
    'background-fit': 'contain',
    'background-color': 'white',
    'background-image': '/images/home.svg',
    'background-image-opacity': 0.6
  })
  .selector('.pinned').css({
    'color': '#fff',
    'background-color': '#aaa',
    'border-color': '#666'
  })
  .selector('.cotonoma').css({
    'shape': 'roundrectangle',
    'width': 20,
    'height': 20,
    'color': '#222',
    'border-width': 0,
    'padding': 0,
    'background-fit': 'contain',
    'background-color': 'white',
    'background-image': (node) => {
      return node.data('imageUrl')
    },
    'background-image-opacity': 1,
    'text-valign': 'bottom',
    'text-margin-y': 5,
    'font-size': 10,
    'font-weight': 'bold'
  })
  .selector('edge').css({
    'label': (node) => {
      const phrase = node.data('linkingPhrase')
      return phrase ? _makeTextBreakable(phrase, 10) : ""
    },
    'color': (node) => {
      return node.data('linkingPhrase') ? color_linkingPhrase : "#fff"
    },
    'line-style': (node) => {
      return node.data('linkingPhrase') ? "solid" : "dashed"
    },
    'line-color': (node) => {
      return node.data('linkingPhrase') ? color_edgeWithPhrase : color_edge
    },
    'font-size': 10,
    'text-max-width': 100,
    'text-wrap': 'wrap',
    'curve-style': 'bezier',
    'width': 1,
    'source-arrow-shape': 'circle',
    'source-arrow-color': (node) => {
      return node.data('linkingPhrase') ? color_edgeWithPhrase : color_edge
    },
    'target-arrow-shape': 'triangle',
    'target-arrow-color': (node) => {
      return node.data('linkingPhrase') ? color_edgeWithPhrase : color_edge
    },
    'arrow-scale': 0.8
  })
  .selector(':selected').css({
    'border-color': color_selected,
    'line-color': color_selected,
    'source-arrow-color': color_selected,
    'target-arrow-color': color_selected
  })
  .selector('.faded').css({
    'opacity': 0.25,
    'text-opacity': 0,
    'border-color': '#ddd',
    'background-color': 'white'
  });

const _layout = {
  name: 'cose-bilkent',
  nodeDimensionsIncludeLabels: true,
  fit: false,
  idealEdgeLength: 100,
  animate: false,
  numIter: 30000
}

let _graph = null
let _rootNodeId = null
let _focusNodeId = null
let _resizeSensor = null

const _getCenterNodeId = () => {
  return _focusNodeId ? _focusNodeId : _rootNodeId
}

const _setFocus = (nodeId) => {
  if (_graph != null) {
    _graph.elements().addClass('faded')
    const node = _graph.getElementById(nodeId)
    node.select()
    node.neighborhood().add(node).removeClass('faded')
  }
}

export default class {
  static render(container, rootNodeId, data, onNodeClick) {
    _rootNodeId = rootNodeId
    _graph = cytoscape({
      container: container,
      elements: data,
      style: _style,
      layout: _layout,
      zoom: 1.2
    })

    _graph.on('layoutstop', (e) => {
      if (_focusNodeId != null) {
        _setFocus(_focusNodeId)
      }
      _graph.center(_graph.getElementById(_getCenterNodeId()))
    })

    _graph.on('tap', 'node', (e) => {
      const node = e.target
      _focusNodeId = node.data('id')
      _setFocus(_focusNodeId)
      onNodeClick(_focusNodeId)
    })

    _graph.on('tap', (e) => {
      if (e.target === _graph) {
        _graph.elements().removeClass('faded')
        _focusNodeId = null
      }
    })

    _resizeSensor = new ResizeSensor(container, debounce(() => {
      if (_graph != null) {
        _graph.resize()
        _graph.center(_graph.getElementById(_getCenterNodeId()))
      }
    }, 500))
  }

  static resize() {
    if (_graph != null) {
      _graph.resize()
      _graph.center(_graph.getElementById(_getCenterNodeId()))
    }
  }

  static destroy() {
    if (_graph != null) {
      _graph.destroy()
      _graph = null
    }
    _rootNodeId = null
    _focusNodeId = null
    _resizeSensor = null
  }
}
