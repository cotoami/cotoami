// Graph rendering by Cytoscape.js

import debounce from 'lodash/debounce'

const style = cytoscape.stylesheet()
  .selector('node').css({
    'content': (node) => {
      return node.data('name')
    },
    'width': 10,
    'height': 10,
    'font-size': 8,
    'text-max-width': 200,
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

const layout = {
  name: 'cose',
  padding: 30,
  nodeDimensionsIncludeLabels: true,
  fit: false
}

let graph = null

export default class {
  static render(container, rootNodeId, data) {
    graph = cytoscape({
      container: container,
      elements: data,
      style: style,
      layout: layout,
      zoom: 1.2,
      ready: () => {
        graph.center(graph.getElementById(rootNodeId))
      }
    })
    graph.on('layoutstop', (e) => {
      graph.center(graph.getElementById(rootNodeId))
    })
    graph.on('tap', 'node', (e) => {
      graph.elements().addClass('faded')
      const node = e.target
      node.neighborhood().add(node).removeClass('faded')
    })
    graph.on('tap', (e) => {
      if (e.target === graph) {
        graph.elements().removeClass('faded')
      }
    })
    new ResizeSensor(container, debounce(() => {
      if (graph != null) {
        graph.resize()
        graph.center(graph.getElementById(rootNodeId))
      }
    }, 500))
  }

  static destroy() {
    if (graph != null) {
      graph.destroy()
      graph = null
    }
  }
}
