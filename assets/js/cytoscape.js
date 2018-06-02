// Graph rendering by Cytoscape.js

const style = cytoscape.stylesheet()
  .selector('node').css({
    'content': (node) => {
      return node.data('name')
    },
    'shape': 'roundrectangle',
    'width': 10,
    'height': 10,
    'font-size': 12,
    'text-max-width': 200,
    'text-wrap': 'ellipsis',
    'text-valign': 'bottom',
    'text-margin-y': 5
  })
  .selector('edge').css({
    'curve-style': 'bezier',
    'width': 1,
    'line-color': '#eee',
    'target-arrow-color': '#eee',
    'target-arrow-shape': 'triangle'
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
