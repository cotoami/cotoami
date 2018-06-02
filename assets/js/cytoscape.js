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
    'color': '#333'
  })
  .selector('edge').css({
    'curve-style': 'bezier',
    'width': 1,
    'line-color': '#ddd',
    'target-arrow-color': '#ddd',
    'target-arrow-shape': 'vee'
  })
  .selector(':selected').css({
    'background-color': 'black',
    'line-color': '#aaa',
    'source-arrow-color': '#aaa',
    'target-arrow-color': '#aaa'
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
    cytoscape({
      container: container,
      elements: data,
      style: style,
      layout: layout
    })
  }
}
