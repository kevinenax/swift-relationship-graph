_ = require 'lodash'
analyzer = require './analyzer.coffee'
handlebars = require 'handlebars'
fs = require 'fs'
path = require 'path'
Constants = require './constants.coffee'

legendPath = path.resolve __dirname, '../assets/legend.template'
legendSource = fs.readFileSync legendPath
legendTemplate = handlebars.compile legendSource.toString()

clustersPath = path.resolve __dirname, '../assets/clusters.template'
clustersSource = fs.readFileSync clustersPath
clustersTemplate = handlebars.compile clustersSource.toString()

dotGraphPath = path.resolve __dirname, '../assets/dotGraph.template'
dotGraphSource = fs.readFileSync dotGraphPath
dotGraphTemplate = handlebars.compile dotGraphSource.toString()

module.exports = (referenceJson, jsonToGraph, types, subtypes) ->

  referenceAnalysis = analyzer referenceJson
  
  referenceGraph =
    protocols:
      data: referenceAnalysis.protocols
    structs:
      data: referenceAnalysis.structs
    classes:
      data: referenceAnalysis.classes
  
  analysis = analyzer jsonToGraph

  graph =
    protocols:
      color: Constants.Style.Protocols.Color
      shape: Constants.Style.Protocols.Shape
      data: analysis.protocols
    structs:
      color: Constants.Style.Structs.Color
      shape: Constants.Style.Structs.Shape
      data: analysis.structs
    classes:
      color: Constants.Style.Classes.Color
      shape: Constants.Style.Classes.Shape
      data: analysis.classes
    system:
      color: Constants.Style.System.Color
      shape: Constants.Style.System.Shape
      data: []

  if _.isString types
    types = types.split ','
  
  if _.isArray types
    keys = Object.keys graph
    for key in keys
      if key not in types
        graph[key].data = []
        
  for type in graph
      for entity in type
          graph[type][entity] = referenceGraph[type][entity]
      

  entities = {}
  for type, typeInfo of graph
    for name, type of typeInfo.data
      entities[name] =
        color: typeInfo.color
        shape: typeInfo.shape
        parents: type.parents
        functions: type.functions
        variables: type.variables
        cluster: Object.keys(entities).length

  for entity, info of entities
    for parent in info.parents
      unless entities[parent]?
        entities[parent] =
          color: Constants.Style.System.Color
          shape: Constants.Style.System.Shape
          parents: []
          functions: []
          variables: []
      originalCluster = entities[parent].cluster
      for other_entity, other_info of entities
        if entities[other_entity].cluster is originalCluster
          entities[other_entity].cluster = info.cluster

  clusters = {}
  for entity, info of entities
    unless clusters[info.cluster]
      clusters[info.cluster] =
        number: info.cluster
        entities: []
        relationships: []
    label  = entity
    if info.functions.length > 0 || info.variables.length > 0
        label = "{" + entity
        if info.variables.length > 0
            label += "|"
            for variable in info.variables
                label += '\\n' + variable[Constants.Key.Definition]
        if info.functions.length > 0
            label += "|"
            for func in info.functions
                label += '\\n' + func[Constants.Key.Definition]
        label += "}"
        
    clusters[info.cluster].entities.push {
      name: entity
      label: label
      color: info.color
      shape: info.shape
    }
    for parent in info.parents
      clusters[info.cluster].relationships.push {
        source: entity
        target: parent
      }

  clusters = _.map clusters, (item) -> item

  clusters = clustersTemplate { clusters: clusters }

  legend = legendTemplate graph

  dotLines = ['digraph dependencies_diagram {']

  return dotGraphTemplate {
    clusters: clusters
    legend: legend
  }
