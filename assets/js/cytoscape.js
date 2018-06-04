// Graph rendering by Cytoscape.js

import debounce from 'lodash/debounce'

const _style = cytoscape.stylesheet()
  .selector('node').css({
    'content': (node) => {
      return node.data('name')
    },
    'width': 10,
    'height': 10,
    'font-size': 8,
    'text-max-width': 150,
    'text-wrap': 'ellipsis',
    'text-valign': 'bottom',
    'text-margin-y': 5,
    'color': '#333',
    'font-family': '"Raleway", "HelveticaNeue", "Helvetica Neue", Helvetica, Arial, sans-serif'
  })
  .selector('edge').css({
    'curve-style': 'bezier',
    'width': 1,
    'line-color': '#ddd',
    'target-arrow-color': '#ddd',
    'target-arrow-shape': 'vee'
  })
  .selector(':selected').css({
    'background-color': '#ffa500',
    'line-color': '#888',
    'source-arrow-color': '#888',
    'target-arrow-color': '#888'
  })
  .selector('.faded').css({
    'opacity': 0.25,
    'text-opacity': 0
  })
  .selector('#home').css({
    'shape': 'roundrectangle',
    'width': 20,
    'height': 20,
    'background-fit': 'contain',
    'background-color': 'white',
    'background-image': '/images/home.svg',
    'background-image-opacity': 0.6
  })
  .selector('.cotonoma').css({
    'shape': 'roundrectangle',
    'width': 20,
    'height': 20,
    'background-fit': 'contain',
    'background-color': 'white',
    'background-image': (node) => {
      return node.data('imageUrl')
    },
    'background-image-opacity': 1,
    'font-size': 10,
    'font-weight': 'bold'
  });

const _layout = {
  name: 'cose',
  padding: 30,
  nodeDimensionsIncludeLabels: true,
  fit: false
}

let _graph = null
let _rootNodeId = null
let _resizeSensor = null

export default class {
  static render(container, rootNodeId, data, onNodeClick) {
    _rootNodeId = rootNodeId
    _graph = cytoscape({
      container: container,
      elements: data,
      style: _style,
      layout: _layout,
      zoom: 1.2,
      ready: () => {
        _graph.center(_graph.getElementById(_rootNodeId))
      }
    })

    _graph.on('layoutstop', (e) => {
      _graph.center(_graph.getElementById(_rootNodeId))
    })

    _graph.on('tap', 'node', (e) => {
      _graph.elements().addClass('faded')
      const node = e.target
      node.neighborhood().add(node).removeClass('faded')
      onNodeClick(node.data('id'))
    })

    _graph.on('tap', (e) => {
      if (e.target === _graph) {
        _graph.elements().removeClass('faded')
      }
    })

    _resizeSensor = new ResizeSensor(container, debounce(() => {
      if (_graph != null) {
        _graph.resize()
        _graph.center(_graph.getElementById(_rootNodeId))
      }
    }, 500))
  }

  static resize() {
    if (_graph != null) {
      _graph.resize()
      _graph.center(_graph.getElementById(_rootNodeId))
    }
  }

  static destroy() {
    if (_graph != null) {
      _graph.destroy()
      _graph = null
      _rootNodeId = null
      _resizeSensor = null
    }
  }
}
