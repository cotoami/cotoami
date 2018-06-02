// Graph rendering by Cytoscape.js

const style = cytoscape.stylesheet()
  .selector('node').css({
    'content': (node) => {
      return node.data('name')
    },
    'shape': 'ellipse',
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
    'background-color': '#333',
    'line-color': '#888',
    'source-arrow-color': '#888',
    'target-arrow-color': '#888'
  })
  .selector('.faded').css({
    'opacity': 0.25,
    'text-opacity': 0
  })

const layout = {
  name: 'cose',
  padding: 30,
  nodeDimensionsIncludeLabels: true
}

export default class {
  static render(container, data) {
    const graph = cytoscape({
      container: container,
      elements: data,
      style: style,
      layout: layout
    })
    graph.on('tap', 'node', (e) => {
      graph.elements().addClass('faded')
      const node = e.target
      node.neighborhood().add(node).removeClass('faded')
    })
    graph.on('tap', (e) => {
      if (e.target === graph) {
        graph.elements().removeClass('faded')
        // graph.makeLayout(layout).run()
      }
    })
  }
}
